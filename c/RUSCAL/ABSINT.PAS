{$Q+}
program ABSINT;
var
   V: Integer;
begin
   V := -32768;
   WriteLn('before: ', V);
   V := Abs(V);
   WriteLn('after V := Abs(V): ', V)
end.
