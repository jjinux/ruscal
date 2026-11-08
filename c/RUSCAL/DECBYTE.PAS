{ $Q+ with Dec(V) for a Byte starting at 0: error 215, or wraps? }
{$Q+}
program DECBYTE;
var
   V: Byte;
begin
   V := 0;
   WriteLn('before: ', V);
   Dec(V);
   WriteLn('after Dec(V): ', V)
end.
