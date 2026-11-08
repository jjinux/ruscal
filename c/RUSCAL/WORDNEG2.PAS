{ Q7 without the i := W lines, in case they don't compile: what is W? }
program WordNeg2;
const
   W = Word(-1);
begin
   WriteLn('W = ', W)
end.
