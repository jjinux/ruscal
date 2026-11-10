{ Constant shifts work on a LongInt's 32 bits, as in Turbo Pascal 7: shr
  is logical (-1 shr 1 is MaxLongInt), and the count is taken mod 32
  (1 shl 32 is 1). Expected output from Turbo Pascal 7 in DOSBox. }
program ConstShifts;
const
   A = -1 shr 1;
   B = $FFFF shl 16;
   C = 1 shl 32;
   D = -8 shr 1;
   F = 1 shl 33;
var
   L: LongInt;
begin
   WriteLn(A, ' ', B, ' ', C, ' ', D, ' ', F);
   L := -1;
   WriteLn(L shr 1);
end.
