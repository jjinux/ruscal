{ Q7: const W = Word(-1); then i := W for an Integer: a compile error
  (constant out of range), or -1? }
program WordNeg;
const
   W = Word(-1);
   K = 1;
var
   I: Integer;
begin
   WriteLn('W = ', W);
   I := W;
   WriteLn('i := W gives ', I);
   I := K - W;
   WriteLn('i := K - W gives ', I)
end.
