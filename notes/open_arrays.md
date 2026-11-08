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

**Runtime** (`ruscal_runtime::array`, next to `PArray`):

```rust
/// A value or `const` open array parameter: the caller's elements, indexed
/// from 0.
#[derive(Clone, Copy)]
pub struct OpenArray<'a, T>(&'a [T]);
/// A `var` open array parameter.
pub struct OpenArrayMut<'a, T>(&'a mut [T]);
```

Both `Deref` to the slice (`len`, `iter`), and implement
`Index<I: Ordinal>` (and `IndexMut` for `OpenArrayMut`) with the same
"Range check error" 201 as `PArray`; `high()` returns `len - 1` as an
`i64`, like `PArray::high`. `PArray` gets `as_open()`/`as_open_mut()`;
`OpenArray::single(&x)`/`OpenArrayMut::single(&mut x)` wrap one variable
(`std::slice::from_ref`); `OpenArrayMut::reborrow()` passes a `var` open
array on; `OpenArray::from(b"xy")`-style for a string literal into
`array of Char` (the bytes as `u8`, Ruscal's `Char`).

Why wrappers rather than plain `&[T]`/`&mut [T]`: Pascal indexes them with
an `Integer` (`a[i]`, `i: i16`), and Rust can't implement `Index<i16>` for
a slice (both are foreign: the orphan rule). The wrappers let the
generated code index them exactly as it indexes a `PArray`, `a[i]`, with
the same range check, and the signature still says what it is.

**Codegen.**
- Signatures: value/`const` → `a: OpenArray<'_, i16>`; `var` →
  `a: OpenArrayMut<'_, i16>`.
- A value parameter the routine changes (sema's `mutated`) is copied
  first, with a teaching comment, as TP copies it:
  `let mut a_copy = a.to_vec(); let mut a = OpenArrayMut::new(&mut a_copy);`
  (alternative: a third type `OpenArrayBuf<T>(Vec<T>)`; I'd rather not add
  a type for a rare case).
- Arguments: `arr.as_open()` / `arr.as_open_mut()`;
  `OpenArray::single(&x)` / `OpenArrayMut::single(&mut x)`; an open array
  parameter passed on as is (it's `Copy`) or `a.reborrow()`; a `var` one
  into a value/`const` one `a.as_open()`.
- `Low(a)` → `0`; `High(a)` → `a.high()` (cast as `PArray`'s is);
  `SizeOf(a)` → `a.len() * <element size>` (the element's
  `SERIALIZED_SIZE` term or number).
- Captured by a nested routine: `&OpenArray`/`&mut OpenArrayMut`, which
  index through auto-deref.
- `for i := Low(a) to High(a)` works as for a `PArray`.
- `FillChar(a, SizeOf(a), 0)` / `Move` / `BlockWrite` on an open array
  (an untyped parameter): `ByteView` for `OpenArrayMut` (and read-only
  for `OpenArray`) if it's straightforward; otherwise a clear "not
  supported yet" error and a TODO.

**Not in scope:** `array of const` (not TP 7), array constructors (not
TP 7), open array function results (not Pascal).

## Tests

- Run test `open_arrays.pas` covering the TP behaviour above, with TP 7's
  output as expected output (8.3 copy in c/RUSCAL).
- Translate test showing signatures, call sites (`as_open`, `single`,
  `reborrow`), `High`, the copied value parameter.
- Error tests: `a := b`, a constant for a `var` open array, a wrong
  element type, a `string` variable for `array of Char`, an open array
  outside a parameter list.

## Docs

README "What's supported", language_spec (move out of "not supported
yet"), architecture (a section on open arrays: the wrapper types and
why), TODO.
