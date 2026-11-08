{ Q2c: with $Q+, w := w + 1 for a Word at 65535: error 215, or 0? }
{$Q+}
program OvfWord;
var
   W: Word;
begin
   W := 65535;
   WriteLn('before: ', W);
   W := W + 1;
   WriteLn('after w := w + 1: ', W)
end.
