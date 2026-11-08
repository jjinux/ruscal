{ $Q+ with Inc(V) for a LongInt starting at 2147483647: error 215, or wraps? }
{$Q+}
program INCLONG;
var
   V: LongInt;
begin
   V := 2147483647;
   WriteLn('before: ', V);
   Inc(V);
   WriteLn('after Inc(V): ', V)
end.
