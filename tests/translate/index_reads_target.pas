{ An index into the variable being changed that reads that variable
  (A[High(A)] := 1, S[Length(S)] := 'z'): worked out first, so Rust
  doesn't borrow the variable twice. Output from fpc -Mtp. }
program IndexReadsTarget;
const
   K = 6;
var
   A: array[0..1000] of Byte;
   B: array[1..5] of Integer;
   S: string;
begin
   A[High(A)] := 1;
   A[High(A) - 1] := 2;
   A[K + High(A) - 1000] := 3;
   B[Low(B)] := 7;
   B[High(B)] := B[High(B)] + 5;
   Inc(B[High(B)]);
   S := 'abc';
   S[Length(S)] := 'z';
   A[A[1000]] := 9;
   B[B[1] - 6] := 4;
   WriteLn(A[1000], A[999], A[6], ' ', A[1], ' ', B[1], ' ', B[5], ' ', S);
end.
