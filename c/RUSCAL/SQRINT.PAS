{$Q+}
program SQRINT;
var
   V: Integer;
begin
   V := 200;
   WriteLn('before: ', V);
   V := Sqr(V);
   WriteLn('after V := Sqr(V): ', V)
end.
