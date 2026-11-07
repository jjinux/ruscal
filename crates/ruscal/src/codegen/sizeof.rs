//! `SizeOf`, written so the Rust says where the number comes from.
//!
//! A type's size in Turbo Pascal's layout (what `SizeOf` returns, and what
//! a typed file stores) isn't its size in Rust's memory: a `Real` is 6
//! bytes in TP and an `f64` here, and a `PString` holds any `string[n]`.
//! So it's called the *serialized* size. Rather than a bare number,
//! `SizeOf(Rec)` is `Rec::SERIALIZED_SIZE`, a constant on the record built
//! from its fields' sizes (`2 + serialized_string_size(10) + 3 *
//! Point::SERIALIZED_SIZE`), which stays right when someone editing the
//! Rust adds a field. `SizeOf` of a basic type stays a number
//! (`SizeOf(Integer)` is `2`), as do sets, files and the runtime's own
//! records (`DateTime`).

use std::collections::HashSet;

use super::Codegen;
use super::expr::{Code, prec};
use crate::ast::{Expr, ExprKind};
use crate::sema::Type;
use crate::sema::types::serialized_size;

impl Codegen<'_> {
    /// The records and objects that get a `SERIALIZED_SIZE` constant: the
    /// ones `SizeOf` measures, and the ones theirs are built from.
    pub(super) fn serialized_size_types(&self) -> HashSet<String> {
        let mut found = HashSet::new();
        let mut todo: Vec<Type> = self.a.sizeof_types.values().cloned().collect();
        while let Some(ty) = todo.pop() {
            match &ty {
                Type::Record(r) if self.declares(&r.rust_name) => {
                    if found.insert(r.rust_name.clone()) {
                        todo.extend(r.fields.iter().map(|f| f.ty.clone()));
                    }
                }
                Type::Object(o) if self.declares(&o.rust_name) => {
                    if found.insert(o.rust_name.clone()) {
                        todo.extend(o.fields.iter().map(|f| f.ty.clone()));
                        todo.extend(o.parent.iter().map(|p| Type::Object(p.clone())));
                    }
                }
                Type::Array(a) => todo.push(a.elem.clone()),
                _ => {}
            }
        }
        found
    }

    /// Is this record or object declared by the program (or one of its
    /// units), so the Rust can give it a constant? (Not the runtime's.)
    fn declares(&self, rust_name: &str) -> bool {
        self.a.type_defs.iter().any(|(ty, _)| match ty {
            Type::Record(r) => r.rust_name == rust_name,
            Type::Object(o) => o.rust_name == rust_name,
            _ => false,
        })
    }

    /// The serialized size of `ty` as Rust that names where it comes from
    /// (`Rec::SERIALIZED_SIZE`, `serialized_string_size(10)`,
    /// `3 * Point::SERIALIZED_SIZE`), or `None` if it's just a number.
    pub(super) fn size_term(&self, ty: &Type) -> Option<Code> {
        match ty {
            Type::Record(r) if self.sized_types.contains(&r.rust_name) => {
                Some((format!("{}::SERIALIZED_SIZE", r.rust_name), prec::POSTFIX))
            }
            Type::Object(o) if self.sized_types.contains(&o.rust_name) => {
                Some((format!("{}::SERIALIZED_SIZE", o.rust_name), prec::POSTFIX))
            }
            Type::Str { cap } => Some((format!("serialized_string_size({cap})"), prec::POSTFIX)),
            Type::Array(a) => {
                let (elem, _) = self.size_term(&a.elem)?;
                Some((format!("{} * {elem}", a.count()), prec::MUL))
            }
            _ => None,
        }
    }

    /// `SizeOf(x)` as Rust that names where its value comes from (a
    /// `usize`), if it isn't just a number. See [`Self::size_term`]. Only
    /// where the integer type wanted is known (`expr::coerce`, constants,
    /// `Write`), so it can be cast to it: elsewhere, inside a sum with an
    /// `i16` or as a routine's `impl Into<i32>` argument, the number stays.
    pub(super) fn sizeof_code(&self, e: &Expr) -> Option<Code> {
        self.size_term(self.a.sizeof_types.get(&e.id)?)
    }

    /// Does `e` use a `SizeOf` written as a name ([`Self::sizeof_code`])?
    pub(super) fn uses_sizeof(&self, e: &Expr) -> bool {
        match &e.kind {
            ExprKind::Call { .. } => self.sizeof_code(e).is_some(),
            ExprKind::Unary { operand, .. } => self.uses_sizeof(operand),
            ExprKind::Binary { lhs, rhs, .. } => self.uses_sizeof(lhs) || self.uses_sizeof(rhs),
            _ => false,
        }
    }

    /// `impl Rec { pub const SERIALIZED_SIZE: usize = ...; }`, if `SizeOf`
    /// needs it: one term per field, so it follows the declaration.
    pub(super) fn serialized_size_const(&mut self, ty: &Type) {
        let variant = matches!(ty, Type::Record(r) if r.variant.is_some());
        let (name, mut terms, vmt) = match ty {
            Type::Record(r) if self.sized_types.contains(&r.rust_name) => {
                let mut terms: Vec<String> = r.fixed_fields().iter().map(|f| self.field_term(&f.ty)).collect();
                // A variant part takes as much as its largest variant.
                if r.variant.is_some() {
                    terms.push(r.variant_area().unwrap_or(0).to_string());
                }
                (r.rust_name.clone(), terms, false)
            }
            Type::Object(o) if self.sized_types.contains(&o.rust_name) => {
                let mut terms: Vec<String> =
                    o.parent.iter().map(|p| format!("{}::SERIALIZED_SIZE", p.rust_name)).collect();
                terms.extend(o.fields.iter().map(|f| self.field_term(&f.ty)));
                (o.rust_name.clone(), terms, o.adds_vmt)
            }
            _ => return,
        };
        if vmt {
            terms.push("2".to_string());
        }
        if terms.is_empty() {
            terms.push("0".to_string());
        }
        self.blank();
        self.line(format!("impl {name} {{"));
        self.indent += 1;
        self.line(format!("/// Pascal's `SizeOf({name})`: its bytes in Turbo Pascal's layout."));
        if self.first_time("serialized_size") {
            self.line("/// That's also what a typed file stores, so it's called the serialized");
            self.line("/// size; the Rust value's size in memory (`std::mem::size_of`) differs.");
        }
        if variant {
            self.line("/// The last term is the variant part: the bytes of its largest variant.");
        }
        if vmt {
            self.line("/// The last `2` is TP's hidden pointer to the object's virtual method table.");
        }
        self.line(format!("pub const SERIALIZED_SIZE: usize = {};", terms.join(" + ")));
        self.indent -= 1;
        self.line("}");
    }

    /// One field's term in a `SERIALIZED_SIZE` sum.
    fn field_term(&self, ty: &Type) -> String {
        match self.size_term(ty) {
            Some((code, _)) => code,
            None => serialized_size(ty).unwrap_or(0).to_string(),
        }
    }
}
