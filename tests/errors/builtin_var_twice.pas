{ One variable as two var arguments of a standard routine is refused, as
  for a user routine (Rust allows one mutable reference); reading into
  the same variable twice is fine. }
program BuiltinVarTwice;
var
   I, C: Integer;
   A: array[1..2] of Integer;
   S: string;
begin
   S := '12';
   Val(S, I, I);
   Val(S, A[1], A[2]);
   Val(S, I, C);
   ReadLn(I, I);
end.
