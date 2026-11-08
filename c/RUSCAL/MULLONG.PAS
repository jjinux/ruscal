{$Q+}
program MULLONG;
var
   V: LongInt;
begin
   V := 2000000000;
   WriteLn('before: ', V);
   V := V * 2;
   WriteLn('after V := V * 2: ', V)
end.
