{ Constant shl and div work in 32 bits, as in Turbo Pascal 7: 1 shl 31
  is MinLongInt, and MinLongInt div -1 wraps to itself. Expected output
  from Turbo Pascal 7 in DOSBox. }
program ConstWrap;
const
   B = 1 shl 31;
   G = (-$7FFFFFFF - 1) div -1;
   H = 3 shl 1;
   K = -7 div 2;
begin
   WriteLn(B, ' ', G, ' ', H, ' ', K);
end.
