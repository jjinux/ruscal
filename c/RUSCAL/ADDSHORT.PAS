{ $Q+ with V := V + 1 for a ShortInt starting at 127: error 215, or wraps? }
{$Q+}
program ADDSHORT;
var
   V: ShortInt;
begin
   V := 127;
   WriteLn('before: ', V);
   V := V + 1;
   WriteLn('after V := V + 1: ', V)
end.
