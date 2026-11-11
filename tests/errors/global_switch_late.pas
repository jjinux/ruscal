program GlobalSwitchLate;
{ `$N` holds for the whole program, so Turbo Pascal 7 takes it only
  before the `uses` clause and the declarations. }
var
   R: Real;
{$N+}
begin
   R := 2.5;
   WriteLn(Round(R));
end.
