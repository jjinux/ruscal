{ SizeOf of the program's records is written as the record's
  SERIALIZED_SIZE constant, built from its fields, so the Rust says
  where the number comes from. Output from fpc -Mtp. }
program SizeOfNames;
const
   NameLen = 10;
type
   Point = packed record
      X, Y: Integer;
   end;
   Shape = (Circle, Square);
   Rec = packed record
      Id: Integer;
      Name: string[NameLen];
      Corners: array[1..3] of Point;
   end;
   Variant = packed record
      Tag: Byte;
      case Kind: Shape of
         Circle: (Radius: Integer);
         Square: (Side: LongInt; Fill: Char);
   end;
   Bytes = array[1..SizeOf(Point)] of Byte;
   Pair = array[1..2] of Rec;
const
   Twice = SizeOf(Rec) * 2;
   Total = SizeOf(Rec) + NameLen;
   Typed: Integer = SizeOf(Variant);
var
   R: Rec;
   Ps: Pair;
   B: Bytes;
   Anon: packed record
      A: Integer;
      S: string[5];
   end;
   W: Word;
   L: LongInt;
   I, Count: Integer;
   F: file;

procedure Show(N: Integer);
   begin
      Write(N, ' ')
   end;

begin
   WriteLn(SizeOf(Rec), ' ', SizeOf(R), ' ', SizeOf(R.Name), ' ', SizeOf(Point));
   WriteLn(SizeOf(Variant), ' ', SizeOf(Ps), ' ', SizeOf(Pair), ' ', SizeOf(Anon));
   WriteLn(Twice, ' ', Total, ' ', Typed, ' ', SizeOf(Integer), ' ', High(B));
   WriteLn(High(Ps) + SizeOf(Rec), ' ', SizeOf(Rec) - SizeOf(Point) * 2);
   W := SizeOf(Rec);
   L := SizeOf(Pair) * 1000;
   Show(W);
   Show(L);
   Show(SizeOf(Variant));
   WriteLn;
   if SizeOf(Rec) > 20 then
      WriteLn('big');
   case 4 of
      SizeOf(Point): WriteLn('point-sized');
      else
         WriteLn('other')
   end;
   Count := 0;
   for I := 1 to SizeOf(Point) do
      Inc(Count);
   WriteLn(Count);
   FillChar(R, SizeOf(R), 0);
   WriteLn(R.Id, ' ', Length(R.Name));
   R.Id := 7;
   R.Name := 'seven';
   Assign(F, 'sizeof_names.dat');
   Rewrite(F, 1);
   BlockWrite(F, R, SizeOf(R));
   WriteLn(FileSize(F) div SizeOf(Rec));
   Close(F);
   Erase(F)
end.
