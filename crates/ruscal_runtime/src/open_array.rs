//! `OpenArray`: Turbo Pascal 7's open array parameters.
//!
//! `procedure Show(const A: array of Integer)` takes an array of Integers of
//! any size and any bounds (`array[1..3]`, `array[-2..2]`), or one Integer.
//! Inside, its indices run from 0 to `High(A)`. In Rust it's a reference to
//! an [`OpenArray`]: `a: &OpenArray<i16>` for a value or `const` parameter,
//! `a: &mut OpenArray<i16>` for a `var` one.
//!
//! An `OpenArray<T>` is a slice `[T]` under another name, so that it can be
//! indexed with any ordinal (`a[i]` with an `i16`) and range-checked as a
//! `PArray` is: Rust only lets a slice be indexed with a `usize`, and won't
//! let us add an `Index<i16>` for a type we don't own (the "orphan rule").
//! Like `str` and `Path`, it's *unsized*: there's no `OpenArray` value, only
//! references to one, which carry the length.

use std::ops::{Deref, Index, IndexMut};

use ref_cast::RefCast;

use crate::bytes::ByteView;
use crate::io::{FileRecord, Hint};
use crate::ordinal::Ordinal;

/// The elements of an open array parameter, indexed from 0.
///
/// `#[repr(transparent)]` promises it's laid out exactly as the slice it
/// wraps, which is what makes turning a `&[T]` into a `&OpenArray<T>` sound;
/// the `ref-cast` crate's derive writes that conversion (`ref_cast`), so the
/// `unsafe` pointer cast it needs lives in that small, widely used crate.
#[derive(RefCast)]
#[repr(transparent)]
pub struct OpenArray<T>([T]);

impl<T> OpenArray<T> {
    /// An open array of the elements of `slice`.
    pub fn new(slice: &[T]) -> &OpenArray<T> {
        OpenArray::ref_cast(slice)
    }

    /// An open array of the elements of `slice`, to change (a `var` one).
    pub fn new_mut(slice: &mut [T]) -> &mut OpenArray<T> {
        OpenArray::ref_cast_mut(slice)
    }

    /// One variable as an open array of one element, as TP allows
    /// (`Sum(X)` for `X: Integer`).
    pub fn single(value: &T) -> &OpenArray<T> {
        OpenArray::new(std::slice::from_ref(value))
    }

    pub fn single_mut(value: &mut T) -> &mut OpenArray<T> {
        OpenArray::new_mut(std::slice::from_mut(value))
    }

    /// Pascal `Low(a)`: always 0.
    pub fn low(&self) -> i64 {
        0
    }

    /// Pascal `High(a)`: the last index, one less than the length.
    pub fn high(&self) -> i64 {
        self.0.len() as i64 - 1
    }
}

/// The elements as a slice: `len()`, `iter()` and the rest. (Only reading:
/// a `DerefMut` would let `a[i]` with a `usize` skip the range check.)
impl<T> Deref for OpenArray<T> {
    type Target = [T];
    fn deref(&self) -> &[T] {
        &self.0
    }
}

/// Indexing with any ordinal, from 0, with TP's range check (runtime error
/// 201), as for a `PArray`.
impl<T, I: Ordinal> Index<I> for OpenArray<T> {
    type Output = T;
    fn index(&self, index: I) -> &T {
        &self.0[crate::array::offset(index.ord(), 0, self.0.len())]
    }
}

impl<T, I: Ordinal> IndexMut<I> for OpenArray<T> {
    fn index_mut(&mut self, index: I) -> &mut T {
        let at = crate::array::offset(index.ord(), 0, self.0.len());
        &mut self.0[at]
    }
}

/// An open array as bytes, for an untyped parameter (`FillChar(A,
/// SizeOf(A), 0)`): its elements in TP's layout, one after another. A
/// `&mut dyn ByteView` can only point to a sized type, so this small struct
/// holds the reference; `hint` is the elements' size where their Rust type
/// doesn't say it (`array of string[20]`).
pub struct OpenBytes<'a, T> {
    elements: &'a mut OpenArray<T>,
    hint: Hint,
}

/// `FillChar(A, SizeOf(A), 0)` with `var A: array of Integer`:
/// `fill_char(&mut open_bytes(a), ...)`.
pub fn open_bytes<T: FileRecord>(elements: &mut OpenArray<T>) -> OpenBytes<'_, T> {
    OpenBytes { elements, hint: Hint::default() }
}

/// The same for elements that say their size: `array of string[20]` (20),
/// a small set (`size` bytes from byte `first` of its bitmap).
pub fn open_sized_bytes<T: FileRecord>(elements: &mut OpenArray<T>, size: usize, first: usize) -> OpenBytes<'_, T> {
    OpenBytes { elements, hint: Hint::new(size, first) }
}

impl<T: FileRecord> ByteView for OpenBytes<'_, T> {
    fn to_bytes(&self) -> Vec<u8> {
        open_sized_view_bytes(self.elements, self.hint.size, self.hint.first)
    }

    fn set_bytes(&mut self, bytes: &[u8]) {
        let mut input = bytes;
        for element in self.elements.0.iter_mut() {
            *element = T::decode_sized(self.hint, &mut input);
        }
    }
}

/// An open array's bytes, to read from (`Move`'s source, `BlockWrite`):
/// its elements in TP's layout. It takes a shared reference, so a `const`
/// open array works too.
pub fn open_view_bytes<T: FileRecord>(elements: &OpenArray<T>) -> Vec<u8> {
    open_sized_view_bytes(elements, 0, 0)
}

/// The same for elements that say their size (see [`open_sized_bytes`]).
pub fn open_sized_view_bytes<T: FileRecord>(elements: &OpenArray<T>, size: usize, first: usize) -> Vec<u8> {
    let mut out = Vec::new();
    for element in elements.0.iter() {
        element.encode_sized(Hint::new(size, first), &mut out);
    }
    out
}

impl<T: std::fmt::Debug> std::fmt::Debug for OpenArray<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_list().entries(self.0.iter()).finish()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::array::PArray;

    fn sum(a: &OpenArray<i16>) -> i32 {
        (a.low()..=a.high()).map(|i| i32::from(a[i])).sum()
    }

    #[test]
    fn any_bounds_index_from_zero() {
        let a: PArray<i16, -2, 5> = PArray::new([1, 2, 3, 4, 5]);
        assert_eq!(sum(a.as_open()), 15);
        assert_eq!(a.as_open()[0_i16], 1);
        assert_eq!(a.as_open().high(), 4);
        assert_eq!(sum(OpenArray::single(&7)), 7);
    }

    #[test]
    fn var_open_array_changes_the_array() {
        let mut a: PArray<i16, 1, 3> = PArray::new([1, 2, 3]);
        let open = a.as_open_mut();
        open[2_u8] *= 10;
        assert_eq!(a[3], 30);
    }
}
