{ More Single, Double and Extended under $N+: in a variant record
  without a tag they keep TP's bytes (8 and 10, not a Real's 6), and an
  integer expression goes into a Single. Expected output from Turbo
  Pascal 7 in DOSBox. }
{$N+,E+}
program FloatMore;
type
   TPun = record
      case Integer of
         0: (E: Extended);
         1: (D: Double);
         2: (B: array[0..9] of Byte);
   end;
var
   P: TPun;
   I: Integer;
   S: Single;
begin
   FillChar(P, SizeOf(P), 0);
   P.E := 1.0;
   for I := 0 to 9 do
      Write(P.B[I], ' ');
   WriteLn;
   FillChar(P, SizeOf(P), 0);
   P.D := 1.0;
   for I := 0 to 9 do
      Write(P.B[I], ' ');
   WriteLn;
   P.B[7] := 64;
   WriteLn(P.D:0:1);
   S := 2 + 3;
   WriteLn(S:0:1, ' ', SizeOf(TPun));
   S := SizeOf(TPun) * 2;
   WriteLn(S:0:1);
end.
