{ $Q+ with V := V * 2 for a Byte starting at 200: error 215, or wraps? }
{$Q+}
program MULBYTE;
var
   V: Byte;
begin
   V := 200;
   WriteLn('before: ', V);
   V := V * 2;
   WriteLn('after V := V * 2: ', V)
end.
