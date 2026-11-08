# `const` parameters by reference: plan

The user (2026-11-07): match Turbo Pascal 7 fully, on a branch.

## What TP 7 does (checked in DOSBox: c/RUSCAL/CPASS.PAS and .OUT)

A `const` parameter is passed by reference unless it's a scalar
(Integer, LongInt, Real, Char, Boolean, an enum, a pointer...), a set
(even an 8-byte one), or a record, array or object of exactly 1, 2 or 4
bytes. A string is always passed by reference (even a 4-byte
`string[3]`). A value parameter is always a copy.

It shows in two ways:
- The routine changes, through a global, the variable it was given
  (`procedure P(const X: R6); begin G6.A := 9; Write(X.A) end; P(G6)`
  prints 9; for a 4-byte record, 1).
- A method called on a `const` object parameter of more than 4 bytes
  changes the caller's object (`X.Bump`); one of 2 bytes changes a copy.

Ruscal copies every `const` parameter today, and the first case doesn't
even compile (`p6(&mut g6, g6)`: E0503).

## Design

**Sema.** `types::const_by_reference(ty)`: true for `Str`, and for a
record, array or object whose `serialized_size` isn't 1, 2 or 4. A
`const` parameter of such a type is a *reference parameter*, as a `var`
one is, but shared. `Analysis::access` says `Reference` for it, so
codegen reads it as it reads a `var` parameter (`*x`, `x.field`). A
helper (`Var::is_reference()`) replaces the scattered
`role == Param(Var)` tests where the question is "is it a reference",
and keeps them where it's "may it be written" (the `const` rules).

It's `&mut` rather than `&` only when a method is called on it (sema's
`mutated`, through the receiver exception): then the caller's object
changes, as in TP.

**Aliasing.** A shared reference parameter is collected as a `VarArg`
with a new `shared: true`:
- Two shared arguments in one variable, or one shared and a global the
  routine only reads: fine (two `&`).
- A shared argument and a `var` argument in one variable: the existing
  "two var arguments in one variable" error (Rust can't have `&g` and
  `&mut g`), with the wording adjusted.
- A shared argument in a global the routine (or what it calls) writes:
  `find_param_aliases` unifies the parameter with the global when every
  call passes that same whole variable, so the routine reads the global
  and sees its own change, as in TP; otherwise the existing
  "var-and-global" error. A routine that only reads the global needs
  neither.
- A `&mut` (method-called) one counts as a `var` argument throughout.

**Codegen.**
- Signatures: `s: &PString`, `r: &TRec` (`&mut TRec` if a method is
  called on it). Procedural types and methods share the signature code;
  `build --lib` exports them as they are.
- Arguments: a place is `&x` (`x` if we already hold a reference, which
  Rust reborrows, `&mut` to `&` too); anything else `&value`
  (`&pstr("abc")`, `&f(x)`): a temporary that lives for the call.
  `&mut` ones need a place, or `&mut temp`.
- Reads go through the existing `Access::Reference` paths; passing one on
  to a value parameter clones/copies (`*x` for `Copy` types), to another
  `const` one passes `x`.
- Nested routines capture it by reference as they do a `var` one.

**External Rust routines** (`{$L sound.rs}`, `procedure Greet(const
Name: string); external;`): the user's Rust function today takes
`name: PString`. Option A: keep externals by value (no change for
existing Rust code; TP's reference semantics can't matter across that
boundary). Option B: `&PString` for them too (consistent, but breaks
existing external Rust). Plan: A, unless the reviewer sees a reason.

**JSON, typed files, Graph/Crt runtime calls:** unaffected (runtime
routines take their own parameter types; the codegen passes `*x` or `x`
as now).

## Tests

- Run test from CPASS.PAS (TP's output): each type and size, both the
  global and the method case.
- Translate test: signatures (`&PString`, `&TRec`, `&mut TObj`, a 4-byte
  record by value), call sites (`&g`, `&pstr(...)`, passing on), a
  nested routine, a unified global.
- Error tests: a shared and a `var` argument in one variable; a global
  written by the routine and passed as different variables.
- The existing snapshots change wherever a program has a `const` string
  or record parameter; review that diff.

## Docs

language_spec (parameters), architecture §15 (parameters and aliasing),
README if it mentions `const` parameters, TODO.
