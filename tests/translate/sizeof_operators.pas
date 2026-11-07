{ SizeOf (a cast in the Rust, Rec::SERIALIZED_SIZE as i16) at the end of
  the left side of < and in shl, and a Pascal function named like the
  runtime's serialized_string_size. Found by the Fable review of the
  SizeOf work. Output from fpc -Mtp. }
program SizeOfOperators;
type
   Point = packed record
      X, Y: Integer;
   end;
   Rec = packed record
      Id: Integer;
      Name: string[3];
   end;
var
   I: Integer;
   W: Word;

function Serialized_String_Size(N: Integer): Integer;
   begin
      Serialized_String_Size := N * 10
   end;

begin
   I := 3;
   W := 5;
   WriteLn(I - SizeOf(Rec) < 0, ' ', I + SizeOf(Rec) < 100);
   WriteLn(SizeOf(Point) - SizeOf(Rec) < 0, ' ', I * SizeOf(Rec) < 10);
   WriteLn(I - Integer(W) < 0);
   WriteLn(SizeOf(Rec) shl I < 1000, ' ', SizeOf(Rec) shl I);
   WriteLn(High(Integer) shr I);
   WriteLn(SizeOf(Rec), ' ', Serialized_String_Size(2))
end.
