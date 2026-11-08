{$Q+}
program SUCCBYTE;
var
   V: Byte;
begin
   V := 255;
   WriteLn('before: ', V);
   V := Succ(V);
   WriteLn('after V := Succ(V): ', V)
end.
