{$N+}
{ An $N+ program using a unit without it: each prints reals its own
  way, as in Turbo Pascal 7 (checked in DOSBox). }
program NPMix2;
uses SftUnit;
var
   R: Real;
begin
   R := 1.5;
   WriteLn(R, '|', R:12);
   ShowSoft(R);
end.
