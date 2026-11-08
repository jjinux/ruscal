{$Q+}
program PREDINT;
var
   V: Integer;
begin
   V := -32768;
   WriteLn('before: ', V);
   V := Pred(V);
   WriteLn('after V := Pred(V): ', V)
end.
