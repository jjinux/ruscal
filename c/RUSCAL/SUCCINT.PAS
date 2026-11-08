{$Q+}
program SUCCINT;
var
   V: Integer;
begin
   V := 32767;
   WriteLn('before: ', V);
   V := Succ(V);
   WriteLn('after V := Succ(V): ', V)
end.
