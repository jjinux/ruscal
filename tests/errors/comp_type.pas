{ Comp, the 8087's 64-bit integer, isn't supported: the error says what
  to use instead. }
{$N+}
program CompType;
type
   PComp = ^Comp;
var
   C: Comp;
   R: Real;
begin
   R := Comp(R);
   WriteLn(SizeOf(Comp));
end.
