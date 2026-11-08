{ $Q+ with Inc(V) for a ShortInt starting at 127: error 215, or wraps? }
{$Q+}
program INCSHORT;
var
   V: ShortInt;
begin
   V := 127;
   WriteLn('before: ', V);
   Inc(V);
   WriteLn('after Inc(V): ', V)
end.
