{ $Q+ with V := V - 1 for a Word starting at 0: error 215, or wraps? }
{$Q+}
program SUBWORD;
var
   V: Word;
begin
   V := 0;
   WriteLn('before: ', V);
   V := V - 1;
   WriteLn('after V := V - 1: ', V)
end.
