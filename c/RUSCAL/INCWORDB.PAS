{ $Q+ with Inc(V) for a Word starting at 32767: error 215, or wraps? }
{$Q+}
program INCWORDB;
var
   V: Word;
begin
   V := 32767;
   WriteLn('before: ', V);
   Inc(V);
   WriteLn('after Inc(V): ', V)
end.
