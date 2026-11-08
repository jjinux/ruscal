# Open array parameters: plan

TP 7's open array parameters: `procedure P(a: array of T)`, `var a: array
of T`, `const a: array of T`. Today they're a parse error (README and
language_spec list them as not supported yet).

## What TP 7 does (checked in DOSBox, c/REVIEW/OPEN*.PAS, 2026-11-07)

- The argument can be any array of `T`, whatever its bounds
  (`array[1..3]`, `array[-2..2]`), or a single variable of type `T`
  (`Sum(X)`, also for `var`), which is a one-element array.
- Inside, indices run from 0: `Low(a)` is 0, `High(a)` is the count - 1.
- A value parameter is a copy: the routine can change it, the caller's
  array doesn't change.
- `SizeOf(a)` is count * element size (10 for 5 Integers; 6 for two
  `record A: Integer; B: Char end`).
- `const c: array of Char` takes a string literal (`Chars('xy')`, High 1),
  but not a `string` variable ("Type mismatch").
- No array constructors (`Sum([1, 2, 3])` is "Invalid variable
  reference").
- An index out of range is runtime error 201 under `{$R+}` (Ruscal always
  checks array indices).

## Design

**Sema.** A new `Type::OpenArray(Rc<Type>)` (the element type), allowed
only as a parameter's type. The parser accepts `array of <type name>` in a
parameter list (only there; `array of array of` is an error, as in TP).
Argument compatibility: an array whose element type is the same, or a
variable (for `var`) / expression (value, `const`) of the element type, or
(for `array of Char`, value or `const`) a string literal; or another open
array parameter of the same element type. Not allowed, with TP-like
errors: assigning a whole open array (`a := b`), passing one to a
fixed-size array parameter, a `string` variable for `array of Char`.

**Runtime** (`ruscal_runtime::array`, next to `PArray`). After Fable's
review of this plan, and the user's choice (2026-11-07), one *unsized*
type, used through references, the way `str` and `Path` are:

```rust
#[derive(RefCast)]
#[repr(transparent)]
pub struct OpenArray<T>([T]);
```

A value or `const` parameter is `a: &OpenArray<i16>`, a `var` one
`a: &mut OpenArray<i16>`. `OpenArray::new(&[T]) -> &OpenArray<T>` (and
`new_mut`) turn a slice into one: that's a pointer cast, which needs
`unsafe`, so the `ref-cast` crate's derive does it (the user preferred a
small, widely used crate to an `unsafe` block of our own). It implements
`Index<I: Ordinal>`/`IndexMut` with the same "Range check error" 201 as
`PArray` (sharing its helper), `len`, `iter`, `high() -> i64` and
`low() -> i64` (0). `PArray` gets `as_open()`/`as_open_mut()` (no `Deref`:
`(*arr)[i]` would silently be 0-based).

Why a reference to an unsized type rather than sized wrappers: the
codegen writes `var` parameters as `&mut {ty}`, captures as `&{ty}`/
`&mut {ty}`, passes a held reference on by name, and builds procedural
types from the same signature code; all of that works unchanged, with
Rust's implicit reborrows, and signatures carry no lifetime. And why not
plain `&[T]`: Pascal indexes with an `Integer`, and Rust can't implement
`Index<i16>` for a slice (the orphan rule).

**Sema.** `Type::OpenArray(Rc<Type>)`, only as a parameter's type (the
parser's parameter type accepts `array of <type name>`; procedures,
methods, procedural types and unit interfaces share that code). `rust()`
is `OpenArray<T>`, and every open array parameter is reached through a
reference (`access()` says `Reference`). `is_copy()` is false. `accepts`:
an array of the same element type, a variable/expression of the element
type (one element), another open array of the same element type, and a
string literal or string constant for `array of Char`. Rejected, as TP
does: `a := b`, an open array for a fixed-size array parameter, a `string`
variable for `array of Char`, array constructors. An open array `var`
parameter is left out of `find_param_aliases` (unifying it with a global
would index the 1-based global through the 0-based parameter).
`High`/`Low`/`SizeOf` of one aren't constants: they get a non-constant
branch (type Integer), `High(a)` → `a.high()`, `Low(a)` → `a.low()`,
`SizeOf(a)` → `a.len() * <element size>` (registering the element type
for `SERIALIZED_SIZE`).

**Codegen.**
- A value parameter the routine changes is copied first, with a
  teaching comment, as TP copies it, keeping the binding a reference:
  `let mut a_copy = a.to_vec(); let a = OpenArray::new_mut(&mut a_copy);`.
- Arguments: `arr.as_open()` / `arr.as_open_mut()`; one variable
  `OpenArray::new(std::slice::from_ref(&x))` (or a `single` helper); an
  open array parameter passed on by name; a string literal or constant
  for `array of Char` `OpenArray::new(b"xy")` / `NAME.as_bytes()`.
- `FillChar`/`Move`/`BlockWrite` (untyped parameters): `ByteView` for
  `OpenArray<T>`; `size_hint`/`string_capacity`/`enum_in_one_byte` learn
  `Type::OpenArray` so `array of string[20]` has its size.

**Not in scope:** `array of const` (not TP 7), array constructors (not
TP 7), open array function results (not Pascal).

## Tests

- Run test `open_arrays.pas` covering the TP behaviour above, with TP 7's
  output as expected output (8.3 copy in c/RUSCAL).
- Translate test showing signatures, call sites (`as_open`, `single`,
  `reborrow`), `High`, the copied value parameter.
- Error tests: `a := b`, a constant for a `var` open array, a wrong
  element type, a `string` variable for `array of Char`, an open array
  outside a parameter list, an open array for a fixed-size array
  parameter. (Free Pascal accepts the last and `a := b`, so those can't
  use `gen_expected.sh`; TP 7 rejects them.)
- A global passed by `var` to an open array parameter of a routine that
  also reads the global (the alias rule).

## Docs

README "What's supported", language_spec (move out of "not supported
yet"), architecture (a section on open arrays: the wrapper types and
why), TODO.
