//! The lifting analysis ("lambda lifting").
//!
//! Pascal procedures can be nested, and a nested procedure can read and
//! write its parents' local variables:
//!
//! ```pascal
//! procedure Report(list: NodePtr);
//! var total: integer;
//!   procedure Visit(p: NodePtr);
//!   begin total := total + p^.value end;   { uses Report's `total` }
//! begin ... end;
//! ```
//!
//! Rust functions can't do that (closures can, but they can't call
//! themselves recursively, and they hold their borrows for as long as they
//! exist). So every procedure becomes a top-level Rust `fn`, and each outer
//! variable it needs becomes an extra parameter:
//! `fn report_visit(total: &mut i16, p: NodePtr)`.
//!
//! "Needs" is transitive: if `A` calls `B` and `B` uses the global `x`, then
//! `A` needs `x` too, to pass it along. We compute this as a *fixed point*:
//! keep propagating needs from callees to callers until nothing changes. That
//! also handles recursion, which a single pass in call order couldn't.

use std::collections::{BTreeSet, HashMap, HashSet};

use super::*;
use crate::diag::Diagnostic;

pub(super) fn lift(a: &mut Analysis) {
    let n = a.procs.len();
    let owner = |a: &Analysis, sym: SymId| a.var(sym).owner;

    // need[p]: outer variables p must receive. write_need[p]: the subset p
    // (or something it calls) modifies.
    let mut need: Vec<BTreeSet<SymId>> = Vec::with_capacity(n);
    let mut write_need: Vec<BTreeSet<SymId>> = Vec::with_capacity(n);
    // A procedure "provides" a variable it owns, or one it receives through
    // a parameter that always stands for it (see `find_param_aliases`).
    let provided =
        |a: &Analysis, p: ProcId, v: SymId| owner(a, v) == p || a.capture_aliases.contains_key(&(p, a.canonical(v)));
    for (p, info) in a.procs.iter().enumerate() {
        need.push(info.uses.iter().copied().filter(|&v| !provided(a, p, v)).collect());
        write_need.push(info.writes.iter().copied().filter(|&v| !provided(a, p, v)).collect());
    }

    let mut changed = true;
    while changed {
        changed = false;
        for p in 0..n {
            for &q in &a.procs[p].calls {
                // Variables q needs that p doesn't own must come from p's
                // own caller, so p needs them too.
                for &v in &need[q].clone() {
                    if !provided(a, p, v) && is_ancestor(a, owner(a, v), p) && need[p].insert(v) {
                        changed = true;
                    }
                }
                for &v in &write_need[q].clone() {
                    if !provided(a, p, v) && is_ancestor(a, owner(a, v), p) && write_need[p].insert(v) {
                        changed = true;
                    }
                }
            }
        }
    }

    // Note which parameter aliases matter: those through which the procedure
    // (or something it calls) actually reaches the outer variable.
    for (&(p, target), &param) in &a.capture_aliases.clone() {
        let reaches = |v: &SymId| owner(a, *v) != p && a.canonical(*v) == target;
        let used = a.procs[p].uses.iter().any(reaches) || a.procs[p].calls.iter().any(|&q| need[q].iter().any(reaches));
        if used {
            a.used_aliases.insert((p, param));
        }
    }

    for p in 0..n {
        // `BTreeSet` iterates in sorted order, so captures come out in
        // declaration order and the generated code is deterministic.
        let captures = need[p]
            .iter()
            .filter(|&&v| is_ancestor(a, owner(a, v), p))
            .map(|&sym| {
                // A method's `self` is never copied: a read-only capture of it
                // is a shared reference, `this: &Queue`.
                let is_self = a.sym(sym).rust_name == "self";
                let mode = if write_need[p].contains(&sym) {
                    CaptureMode::RefMut
                } else if a.var(sym).ty.is_copy() && !is_self {
                    CaptureMode::Value
                } else {
                    CaptureMode::Ref
                };
                Capture { sym, mode }
            })
            .collect();
        a.procs[p].captures = captures;
    }

    rename_clashing_captures(a);

    // Which variables need `mut`: those written by their owner, or handed to
    // a callee that writes them.
    for p in 0..n {
        let mut written: BTreeSet<SymId> = a.procs[p].writes.clone();
        for &q in &a.procs[p].calls {
            written.extend(write_need[q].iter().copied());
        }
        for v in written {
            if owner(a, v) == p {
                a.mutated.insert(v);
            }
        }
    }

    // A `for` loop gets an idiomatic, loop-scoped variable when nothing else
    // ever looks at that variable: it's a plain local, used only inside the
    // loops it controls, and no other procedure captures it.
    let captured_anywhere: HashSet<SymId> = need.iter().flatten().copied().collect();
    for &(stmt_start, var, proc) in &a.for_loop_list.clone() {
        let v = a.var(var);
        let scoped = a.for_only.get(&var) == Some(&true)
            && v.owner == proc
            && v.role == VarRole::Local
            && !captured_anywhere.contains(&var);
        if scoped {
            a.scoped_for_loops.insert(stmt_start);
            a.elided_vars.insert(var);
        }
    }
}

/// A lifted procedure receives its captured variables as parameters, so
/// their Rust names must not clash with its own parameters and locals. In
/// Pascal they can't clash (an inner declaration hides the outer one), but a
/// procedure may still need to pass a hidden outer variable through to
/// something it calls. Inside that procedure, the captured variable gets
/// another name (`global_count`); everywhere else it keeps its own. Two
/// captures can share a name too (the global `count`, passed on, and the
/// parent's local `count`): as in Pascal's scopes, the innermost keeps it.
fn rename_clashing_captures(a: &mut Analysis) {
    // How deeply a procedure is nested: the main program is 0.
    let depth = |a: &Analysis, mut p: ProcId| {
        let mut n = 0;
        while let Some(parent) = a.procs[p].parent {
            n += 1;
            p = parent;
        }
        n
    };
    for p in 0..a.procs.len() {
        let own: HashSet<String> =
            a.procs[p].params.iter().chain(&a.procs[p].locals).map(|&s| a.sym(s).rust_name.clone()).collect();
        let captures = a.procs[p].captures.clone();
        for cap in &captures {
            let name = a.sym(cap.sym).rust_name.clone();
            let owner = a.var(cap.sym).owner;
            // Hidden by another capture of the same name declared further in.
            let hidden = captures.iter().any(|other| {
                other.sym != cap.sym
                    && a.sym(other.sym).rust_name == name
                    && depth(a, a.var(other.sym).owner) > depth(a, owner)
            });
            if own.contains(&name) || hidden {
                let renamed = if owner == MAIN {
                    format!("global_{name}")
                } else {
                    format!("{}_{name}", a.procs[owner].rust_name)
                };
                a.capture_names.insert((p, cap.sym), renamed);
            }
        }
    }
}

/// Is `ancestor` the same as `p` or one of the procedures enclosing it?
fn is_ancestor(a: &Analysis, ancestor: ProcId, p: ProcId) -> bool {
    let mut cur = Some(p);
    while let Some(c) = cur {
        if c == ancestor {
            return true;
        }
        cur = a.procs[c].parent;
    }
    false
}

/// Find `var` parameters that every call binds to the same variable.
///
/// `life.pas` passes the global `generations` to `Pause` as a `var`
/// parameter, and `Pause` also calls a procedure that reads the global
/// directly. In Rust, `Pause` would then hold `&mut generations` alongside a
/// second reference to it, which the borrow checker forbids. But if *every*
/// call passes that very variable, the parameter and the variable are the
/// same storage, so the procedure can simply use the parameter wherever the
/// Pascal code names the variable. That's exactly Pascal's meaning, with no
/// aliasing left for Rust to object to.
///
/// The binding can be indirect (`examples/database/filesys.pas`): `Editor`
/// receives the global `FileSystem` as a parameter and passes its parameter
/// on to a nested procedure, so every parameter in that chain is the global.
/// The chains are followed to a fixed point.
///
/// A `const` parameter TP passes by reference (`Passing::Ref`) is unified
/// the same way, but only where it has to be: when the routine, or one it
/// calls, changes the variable every call passes. Then the routine sees its
/// own change through the parameter, as in TP, and the parameter becomes
/// `&mut` (its callers pass `&mut g`). Not for a virtual method or an
/// external routine, whose signature can't follow one program's calls.
pub(super) fn find_param_aliases(a: &mut Analysis, sites: &mut [CallSite]) {
    // What each routine changes, and uses, itself or through the routines
    // it calls.
    let through_calls = |a: &Analysis, mut sets: Vec<BTreeSet<SymId>>| {
        let mut grew = true;
        while grew {
            grew = false;
            for p in 0..a.procs.len() {
                for &q in &a.procs[p].calls {
                    let theirs = sets[q].clone();
                    let before = sets[p].len();
                    sets[p].extend(theirs);
                    grew |= sets[p].len() > before;
                }
            }
        }
        sets
    };
    let changes = through_calls(a, a.procs.iter().map(|p| p.writes.clone()).collect());
    let uses = through_calls(a, a.procs.iter().map(|p| p.uses.clone()).collect());
    let unifiable_const = |a: &Analysis, p: ProcId, param: SymId| {
        a.passing(param) != super::Passing::Value
            && a.var(param).role == VarRole::Param(crate::ast::ParamMode::Const)
            && a.procs[p].has_body
            && !a.dispatched.contains(&p)
    };
    // `canon[param]` = the variable that parameter always stands for.
    let mut canon: HashMap<SymId, SymId> = HashMap::new();
    let resolve = |canon: &HashMap<SymId, SymId>, mut sym: SymId| {
        while let Some(&next) = canon.get(&sym) {
            sym = next;
        }
        sym
    };
    // Not for a procedural type's class, or a routine kept in one: they must
    // keep one signature with every global, however a call passes them.
    let in_class: HashSet<ProcId> = a
        .proc_classes
        .iter()
        .flat_map(|&class| std::iter::once(class).chain(a.procs[class].calls.iter().copied()))
        .collect();
    let mut unified_consts: Vec<SymId> = Vec::new();
    let mut changed = true;
    while changed {
        changed = false;
        for p in 0..a.procs.len() {
            let calls: Vec<&CallSite> = sites.iter().filter(|s| s.callee == p).collect();
            if calls.is_empty() || in_class.contains(&p) {
                continue;
            }
            for &param in &a.procs[p].params.clone() {
                let is_var = a.var(param).role == VarRole::Param(crate::ast::ParamMode::Var);
                if canon.contains_key(&param) || !(is_var || unifiable_const(a, p, param)) {
                    continue;
                }
                // The variable each call passes for this parameter. A
                // recursive call passing the parameter itself doesn't count.
                let mut bound_to = HashSet::new();
                let mut every_call_binds_whole_variable = true;
                for site in &calls {
                    match site.var_args.iter().find(|arg| arg.param == param) {
                        Some(arg) if arg.whole => {
                            let root = resolve(&canon, arg.root);
                            if root != param {
                                bound_to.insert(root);
                            }
                        }
                        _ => every_call_binds_whole_variable = false,
                    }
                }
                if every_call_binds_whole_variable && bound_to.len() == 1 {
                    let target = *bound_to.iter().next().unwrap();
                    // A `const` one only where Rust would see a conflict: the
                    // routine changes that variable, or uses it while it
                    // changes the parameter (a method called on it).
                    let conflict =
                        changes[p].contains(&target) || (a.const_ref_mut.contains(&param) && uses[p].contains(&target));
                    if !is_var && !conflict {
                        continue;
                    }
                    canon.insert(param, target);
                    if !is_var {
                        unified_consts.push(param);
                    }
                    changed = true;
                }
            }
        }
    }
    // A unified `const` parameter is `&mut`, and each call's argument a
    // write of its variable.
    for param in unified_consts {
        a.const_ref_mut.insert(param);
        for site in sites.iter_mut() {
            for arg in site.var_args.iter_mut().filter(|arg| arg.param == param) {
                arg.shared = false;
                a.procs[site.caller].writes.insert(arg.root);
            }
        }
    }
    for &param in canon.keys() {
        let p = a.var(param).owner;
        let target = resolve(&canon, param);
        a.capture_aliases.insert((p, target), param);
        a.param_aliases.insert(param, target);
    }
}

/// Which `const` parameters passed by reference must be `&mut` (see
/// `Passing`): one a method is called on (sema found those), one passed on
/// to such a parameter (`procedure A(const X: TBig); begin B(X) end`), and
/// one in the same place as such a parameter in a routine that shares its
/// signature: a procedural type's routines, or a virtual method's
/// overrides. A fixed point. Then each such argument counts as a write of
/// its variable, and as a mutable borrow in the alias check.
pub(super) fn const_ref_mut(a: &mut Analysis, sites: &mut [CallSite]) {
    let by_reference_const = |a: &Analysis, sym: SymId| match &a.sym(sym).kind {
        super::SymKind::Var(v) => {
            v.role == VarRole::Param(crate::ast::ParamMode::Const) && super::types::const_by_reference(&v.ty)
        }
        _ => false,
    };
    // Routines that must agree, parameter by parameter.
    let mut families: Vec<Vec<ProcId>> = a
        .proc_classes
        .iter()
        .map(|&class| std::iter::once(class).chain(a.procs[class].calls.iter().copied()).collect())
        .collect();
    let mut by_name: HashMap<(String, String), Vec<ProcId>> = HashMap::new();
    for &p in &a.dispatched {
        if let Some((object, _)) = &a.procs[p].self_param {
            let root = object.lineage().last().unwrap().0.rust_name.clone();
            let name = a.procs[p].name.rsplit('.').next().unwrap_or_default().to_ascii_lowercase();
            by_name.entry((root, name)).or_default().push(p);
        }
    }
    families.extend(by_name.into_values());
    let mut changed = true;
    while changed {
        changed = false;
        for site in sites.iter() {
            for arg in &site.var_args {
                if arg.shared
                    && a.const_ref_mut.contains(&arg.param)
                    && by_reference_const(a, arg.root)
                    && a.const_ref_mut.insert(arg.root)
                {
                    changed = true;
                }
            }
        }
        for family in &families {
            let positions = family.iter().map(|&p| a.procs[p].params.len()).max().unwrap_or(0);
            for i in 0..positions {
                let params: Vec<SymId> = family.iter().filter_map(|&p| a.procs[p].params.get(i).copied()).collect();
                if params.iter().any(|q| a.const_ref_mut.contains(q)) {
                    for q in params {
                        if by_reference_const(a, q) && a.const_ref_mut.insert(q) {
                            changed = true;
                        }
                    }
                }
            }
        }
    }
    for site in sites.iter_mut() {
        for arg in &mut site.var_args {
            if arg.shared && a.const_ref_mut.contains(&arg.param) {
                arg.shared = false;
                a.procs[site.caller].writes.insert(arg.root);
            }
        }
    }
}

/// Reject calls where Rust would see two mutable references to the same
/// variable. Pascal allows this "aliasing" (and its behaviour is subtle even
/// there); Rust's borrow checker forbids it outright.
pub(super) fn check_aliasing(a: &Analysis, sites: &[CallSite]) -> Vec<Diagnostic> {
    let mut errors = Vec::new();
    for site in sites {
        let callee = &a.procs[site.callee];
        for (i, arg) in site.var_args.iter().enumerate() {
            let VarArg { root, span, .. } = *arg;
            let name = &a.sym(root).name;
            // (Two shared borrows of one variable are fine.)
            let conflicting = |earlier: &&VarArg| earlier.overlaps(arg) && !(earlier.shared && arg.shared);
            if let Some(earlier) = site.var_args[..i].iter().find(conflicting) {
                // `a[1]` and `a[2]` may well be different elements, but Rust
                // can't tell, so say why they count as the same.
                let why = if earlier.untyped || arg.untyped {
                    " (an untyped parameter's bytes run on to the end of the whole variable, which Rust borrows)"
                } else if earlier.variant_bytes && arg.variant_bytes {
                    " (fields of a variant part without a tag field share its bytes, which Rust borrows as a whole; copy one into a local first)"
                } else if earlier.indexed && arg.indexed && earlier.fields == arg.fields {
                    " (Rust can't tell that two elements of one array, or two fields of one element, are different)"
                } else {
                    ""
                };
                let is_receiver = |v: &VarArg| callee.self_param.as_ref().is_some_and(|(_, s)| *s == v.param);
                let what = if (earlier.is_const || arg.is_const) && (is_receiver(earlier) || is_receiver(arg)) {
                    "as a `const` parameter (which Turbo Pascal passes by reference) of `{}`, which is called on it; Rust doesn't allow the method's `&mut self` alongside another reference to the object"
                } else if earlier.is_const != arg.is_const {
                    "by `var` and as a `const` parameter (which Turbo Pascal passes by reference) in this call to `{}`; Rust doesn't allow a mutable reference to a variable alongside another reference to it"
                } else if earlier.is_const {
                    "as a `const` parameter more than once in this call to `{}` (Turbo Pascal passes one by reference, and here a method is called on it); Rust doesn't allow a mutable reference to a variable alongside another reference to it"
                } else {
                    "by `var` more than once in this call to `{}`; Rust doesn't allow two mutable references to the same variable"
                };
                let what = what.replace("{}", &callee.name);
                errors.push(Diagnostic::new(
                    span,
                    format!("`{name}` is passed {what}{why}{}", super::rewrite_link("two-var-arguments")),
                ));
            } else if callee
                .captures
                .iter()
                // Through a pointer, the argument only reads the pointer
                // itself, which a callee that reads it too doesn't mind.
                // And a shared one only minds a callee that changes it.
                .any(|c| c.sym == root && !((arg.through_pointer || arg.shared) && c.mode != CaptureMode::RefMut))
            {
                let how = if arg.is_const {
                    "as a `const` parameter (which Turbo Pascal passes by reference)"
                } else {
                    "by `var`"
                };
                errors.push(Diagnostic::new(
                    span,
                    format!(
                        "`{name}` is passed {how} to `{}`, which also uses `{name}` directly; Rust doesn't allow two references to the same variable when one of them is mutable{}",
                        callee.name,
                        super::rewrite_link("var-and-global")
                    ),
                ));
            }
        }
    }
    errors
}
