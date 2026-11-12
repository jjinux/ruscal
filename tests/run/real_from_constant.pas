{ An integer constant stored in a real is written as a real literal. }
{$N+}
program RealFromConstant;
var
   S: Single;
   R: Real;
begin
   S := High(Word);
   R := SizeOf(R);
   WriteLn(S:0:1, ' ', R:0:1);
end.
