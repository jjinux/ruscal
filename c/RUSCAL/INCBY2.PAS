{ $Q+ with Inc(V, 2) for a Byte starting at 255: error 215, or wraps? }
{$Q+}
program INCBY2;
var
   V: Byte;
begin
   V := 255;
   WriteLn('before: ', V);
   Inc(V, 2);
   WriteLn('after Inc(V, 2): ', V)
end.
