{ $Q+ with Inc(V) for a Word starting at 65535: error 215, or wraps? }
{$Q+}
program INCWORD;
var
   V: Word;
begin
   V := 65535;
   WriteLn('before: ', V);
   Inc(V);
   WriteLn('after Inc(V): ', V)
end.
