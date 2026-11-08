{ Under $Q+, Turbo Pascal 7 never checks Inc and Dec: they wrap, for
  every integer type, while i := i + 1 at 32767 is runtime error 215.
  Expected output from Turbo Pascal 7 in DOSBox (Free Pascal checks Inc
  and Dec under $Q+). }
{$Q+}
program OverflowIncDec;
var
   B: Byte;
   S: ShortInt;
   I: Integer;
   W: Word;
   L: LongInt;
begin
   B := 255;
   Inc(B);
   Write(B, ' ');
   B := 255;
   Inc(B, 2);
   Write(B, ' ');
   B := 0;
   Dec(B);
   WriteLn(B);
   S := 127;
   Inc(S);
   I := 32767;
   Inc(I);
   WriteLn(S, ' ', I);
   W := 65535;
   Inc(W);
   Write(W, ' ');
   W := 0;
   Dec(W);
   WriteLn(W);
   L := 2147483647;
   Inc(L);
   WriteLn(L)
end.
