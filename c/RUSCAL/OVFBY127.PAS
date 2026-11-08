{ Q2b: with $Q+, Inc(b) for a Byte at 127: error 215 (signed overflow flag), or 128? }
{$Q+}
program OvfBy127;
var
   B: Byte;
begin
   B := 127;
   WriteLn('before: ', B);
   Inc(B);
   WriteLn('after Inc(b): ', B)
end.
