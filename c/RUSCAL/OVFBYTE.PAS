{ Q2a: with $Q+, Inc(b) for a Byte at 255: error 215, or 0? }
{$Q+}
program OvfByte;
var
   B: Byte;
begin
   B := 255;
   WriteLn('before: ', B);
   Inc(B);
   WriteLn('after Inc(b): ', B)
end.
