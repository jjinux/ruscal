{ Under $N+ the 8087 rounds half to even at run time, for every real
  type (Round(2.5) is 2, Round(-2.5) is -2, Round(0.5) is 0); a
  constant Round(2.5) is still 3, worked out by the compiler. Expected
  output from Turbo Pascal 7 in DOSBox. }
{$N+,E+}
program RoundNPlus;
var
   R: Real;
   D: Double;
   E: Extended;
   S: Single;
begin
   R := 2.5; D := 2.5; E := 2.5; S := 2.5;
   WriteLn(Round(R), ' ', Round(D), ' ', Round(E), ' ', Round(S), ' ', Round(2.5));
   R := -2.5; D := 0.5; E := 3.5;
   WriteLn(Round(R), ' ', Round(D), ' ', Round(E), ' ', Trunc(D));
end.
