{ A constant / by 0 is refused when TP 7 compiles ("Error 140:
  Invalid floating point operation"), as 1.0 / 0.0 and 0.0 / 0.0 are;
  X / 0 of a variable is left to run time. Expected output from Turbo
  Pascal 7 in DOSBox. }
program RealDiv0;
var
   R: Real;
begin
   R := 2.0;
   R := R / 0;
   R := 1 / 0;
   WriteLn(R);
end.
