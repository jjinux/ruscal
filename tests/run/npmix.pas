{ A program without $N+ using units with and without it: each prints
  reals its own way, as in Turbo Pascal 7 (checked in DOSBox). }
program NPMix;
uses NPUnit, SftUnit;
var
   R: Real;
begin
   R := 1.5;
   WriteLn(R, '|', R:12);
   Show(R);
   ShowSoft(R);
end.
