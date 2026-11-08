{ $Q+ with Inc(V) for a Integer starting at 32767: error 215, or wraps? }
{$Q+}
program INCINT;
var
   V: Integer;
begin
   V := 32767;
   WriteLn('before: ', V);
   Inc(V);
   WriteLn('after Inc(V): ', V)
end.
