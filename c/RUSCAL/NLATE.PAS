{ $N is a global switch: TP 7 takes it only before the uses clause
  and the declarations; here it says "Error 17: Invalid compiler
  directive". Expected output from Turbo Pascal 7 in DOSBox. }
program NLate;
var
   R: Real;
{$N+}
begin
   R := 2.5;
   WriteLn(Round(R));
end.
