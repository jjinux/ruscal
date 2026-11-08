{ Q1: w + 1 with w: Word = 65535. Ruscal says 0. }
program WordAdd;
var
   W: Word;
   L: LongInt;
   I: Integer;
begin
   W := 65535;
   WriteLn('w + 1 = ', W + 1);
   L := W + 1;
   WriteLn('L := w + 1 gives ', L);
   I := 1;
   L := W + I;
   WriteLn('L := w + i (i = 1) gives ', L);
   W := W + 1;
   WriteLn('w := w + 1 gives ', W)
end.
