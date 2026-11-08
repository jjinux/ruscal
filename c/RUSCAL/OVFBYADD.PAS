{ Q2d: with $Q+, b := b + 1 for a Byte at 255: error 215, or 0? }
{$Q+}
program OvfByAdd;
var
   B: Byte;
begin
   B := 255;
   WriteLn('before: ', B);
   B := B + 1;
   WriteLn('after b := b + 1: ', B)
end.
