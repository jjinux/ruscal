{ Without $N+ (TP's default) Round rounds half away from zero, at run
  time and in a constant. Expected output from Turbo Pascal 7 in
  DOSBox. }
{$N-}
program RoundNMinus;
var
   R: Real;
begin
   R := 2.5;
   WriteLn(Round(R), ' ', Round(2.5));
   R := -2.5;
   WriteLn(Round(R));
end.
