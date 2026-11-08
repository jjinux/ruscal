{ $Q+ with Dec(V) for a Word starting at 0: error 215, or wraps? }
{$Q+}
program DECWORD;
var
   V: Word;
begin
   V := 0;
   WriteLn('before: ', V);
   Dec(V);
   WriteLn('after Dec(V): ', V)
end.
