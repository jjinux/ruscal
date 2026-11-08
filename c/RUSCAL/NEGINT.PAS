{$Q+}
program NEGINT;
var
   V: Integer;
begin
   V := -32768;
   WriteLn('before: ', V);
   V := -V;
   WriteLn('after V := -V: ', V)
end.
