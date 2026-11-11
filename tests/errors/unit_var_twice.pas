{ One variable as two var arguments of a Dos routine is refused, as for a
  user routine or Val: Rust can't tell that two elements of one array are
  different. }
program UnitVarTwice;
uses Dos;
var
   D: array[1..4] of Word;
   Parts: array[1..3] of PathStr;
begin
   GetDate(D[1], D[2], D[3], D[4]);
   FSplit('C:\A\B.PAS', Parts[1], Parts[2], Parts[3]);
end.
