{ A hexadecimal constant is a 32-bit pattern, as in Turbo Pascal: one past
  $7FFFFFFF is a negative LongInt ($FFFFFFFF is -1). Expected output from
  Turbo Pascal 7 in DOSBox. }
program HexConstants;
const
   A = $FFFFFFFF;
   B = $80000000;
   C = $FFFF;
   D = -$1;
var
   L: LongInt;
   W: Word;
begin
   WriteLn(A, ' ', B, ' ', C, ' ', $7FFFFFFF, ' ', D);
   L := $FFFFFFFF;
   W := $FFFF;
   WriteLn(L, ' ', W, ' ', $FFFFFFFF + 1, ' ', A div 2, ' ', $FFFFFFFF = -1);
   L := $ABCD1234;
   WriteLn(L);
end.
