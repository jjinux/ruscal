{ $Q+ with V := V + 1 for a Integer starting at 32767: error 215, or wraps? }
{$Q+}
program ADDINT;
var
   V: Integer;
begin
   V := 32767;
   WriteLn('before: ', V);
   V := V + 1;
   WriteLn('after V := V + 1: ', V)
end.
