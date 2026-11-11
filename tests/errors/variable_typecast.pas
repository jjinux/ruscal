{ A variable typecast as a place (Word(I) with I an Integer) would treat
  the variable's bytes as another type: Turbo Pascal allows it, Ruscal
  refuses it, saying what to do instead. }
program VariableTypecast;
var
   I, N: Integer;
   S: string;
begin
   S := '65535';
   Val(S, Word(I), N);
   Word(I) := 5;
end.
