{ A global passed by var to an open array parameter of a routine that
  also uses the global: the usual alias rule (the parameter isn't merged
  with the global, which is indexed from 1 where it's indexed from 0). }
program OpenArrayAlias;
var
   G: array[1..3] of Integer;

procedure Zero(var A: array of Integer);
   begin
      A[0] := 0;
      WriteLn(G[1], ' ', High(A));
   end;

begin
   G[1] := 7;
   Zero(G);
end.
