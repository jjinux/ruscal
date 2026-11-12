# SizeOf as a name in more places (plan)

The user, 2026-11-12: do the open `SizeOf` item from review batch U on a
branch. `SizeOf(Rec)` is `Rec::SERIALIZED_SIZE` (a `usize`) where codegen
knows the integer type wanted (`coerce` casts it: `as i16`). It's still a
number in these places (checked on main, `out/review/sz.pas`):

| Pascal | Rust now | Plan |
|---|---|---|
| `BlockWrite(F, B, SizeOf(Rec))` | `f.block_write(&b.to_bytes(), 6)` | `Rec::SERIALIZED_SIZE as u16` |
| `Seek(F, SizeOf(Rec))` | `f.seek(6)` | `... as i32` |
| `GetMem(P, SizeOf(Rec))` (`Pointer`/`PChar`) | `AnyPtr::alloc(6)` | `... as u16` |
| `Move(B, A, SizeOf(Rec))` | `move_bytes(..., 6)` | `... as u16` |
| `Reset(F, SizeOf(Rec))` | `reset_records(6)` | `... as u16` |
| `J := SizeOf(Rec) * I` under `{$Q+}` | `6_i16.checked_mul(i)` | `(Rec::SERIALIZED_SIZE as i16).checked_mul(i)` |
| `R := SizeOf(Rec)` (a Real) | `r = 6.0` | `Rec::SERIALIZED_SIZE as f64` |
| `WriteLn(-SizeOf(Rec))` | `pwriteln!(-6)` | `-(Rec::SERIALIZED_SIZE as i32)` |
| `A[SizeOf(Point) + 1]` | `a[4 + 1]` | `a[Point::SERIALIZED_SIZE as i16 + 1]` |
| `SizeOf(Rec) in S` | `s.contains(6)` | `s.contains(Rec::SERIALIZED_SIZE as i16)` |

Already named (no change): assignments, sums with variables
(`Rec::SERIALIZED_SIZE as i16 * i`), comparisons, `Write`, set
constructors, constants, `Word(SizeOf(Rec))` (one cast: the review's
"two casts in a row" no longer happens).

## Fable's changes (adopted)

- A runtime routine's count is cast only when it's a constant
  (`IntLit`) with a `SizeOf`: `I * SizeOf(Rec)` is already named and
  stays as it is.
- The Real case goes in `coerce` (by then `convert` sees only `6`); a
  constant sum is worked out in its integer type first:
  `f64::from(Rec::SERIALIZED_SIZE as i16 * 2)`.
- `{$Q+}`: any constant with a `SizeOf` on the left goes through
  `coerce` (so sums and `-SizeOf(Rec)` are named too).
- `in` and an index use the operand's own type, not the set's element
  type (`set of 0..100` is a `PSet<i8>`: `as i8` would cut 300 to 44).
- `-SizeOf(Rec)` in `Write`: the operand's type (`i16`), as the sum
  path does.
- A `case` label keeps today's guard, which keeps the name.

## How (the first plan)

1. Runtime routines' count/size arguments (`BlockRead`/`BlockWrite`
   count, `Seek`, `Reset`/`Rewrite` record size, `GetMem`/`FreeMem` of a
   `Pointer`/`PChar`, `Move` and `FillChar` count): a helper,
   `size_arg(e, kind)`, that coerces to TP's parameter type (`Word`, or
   `LongInt` for `Seek`) when `uses_sizeof(e)`, and is `self.expr(e)`
   otherwise, so other arguments don't change (`w` stays `w`, not
   `i32::from(w)`). `u16` and `i32` both go into the runtime's
   `impl Into<i32>`.
2. `{$Q+}`: where the checked path suffixes a literal (`6_i16`), a
   `SizeOf` name is parenthesized instead: `(Rec::SERIALIZED_SIZE as
   i16).checked_mul(i)`.
3. A Real: `convert` from an integer to a Real, when the code is a
   `SizeOf` name, casts the `usize` with `as f64` (`as f32` for a
   `Single`); `f64::from` doesn't take a `usize`.
4. `Write` of a unary minus of one: like the existing constant-sum path
   in `write_arg` (the integer type TP works it out in), extended to
   `Unary`.
5. An index and `in`: coerce to the index type / set's element type when
   `uses_sizeof` (they're written with `expr` now, as literals).

Left as a number, documented: an array bound in a type (a const
generic), a sum with `High(a)`, and basic types (`SizeOf(Integer)` is
`2`).

Tests: a translate test `sizeof_more.pas` with each row, and a run test
that it prints the same numbers (fpc -Mtp); docs/architecture.md's
"That's most places, not all" list and the TODO item updated.
