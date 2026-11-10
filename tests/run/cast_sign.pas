{ A ShortInt widened to a Word is sign-extended: ShortInt(255) is -1,
  which is 65535 as a Word. (Narrowing twice can be one cast, but not a
  cast that widens with another sign.) Expected output from Turbo Pascal 7
  in DOSBox. }
program CastSign;
var
   B: Byte;
   W: Word;
   L: LongInt;
   S: ShortInt;
begin
   B := 255;
   W := ShortInt(B);
   WriteLn(W);
   W := Word(ShortInt(B));
   WriteLn(W);
   L := Word(ShortInt(B));
   WriteLn(L);
   S := ShortInt(B);
   W := S;
   WriteLn(W);
end.
