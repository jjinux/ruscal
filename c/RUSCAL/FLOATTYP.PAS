{ Single, Double and Extended under $N+ (TP 7, with the 8087): a Single
  keeps single precision, arithmetic is done in full precision, reals
  print with 15 digits, and a typed file stores 4, 8, 10 and 6 bytes.
  Expected output from Turbo Pascal 7 in DOSBox. }
{$N+,E+}
program FloatTypes;
type
   TRec = record
      S: Single;
      D: Double;
      E: Extended;
      R: Real;
   end;
var
   S: Single;
   D: Double;
   E: Extended;
   R: Real;
   L: LongInt;
   I, Code: Integer;
   Rec: TRec;
   F: file of TRec;
   B: file of Byte;
   Bt: Byte;
begin
   S := 0.1;
   D := 0.1;
   WriteLn(S);
   WriteLn(D);
   WriteLn(S:0:10, ' ', D:0:10, ' ', S:12, '|');
   WriteLn(SizeOf(S), ' ', SizeOf(D), ' ', SizeOf(E), ' ', SizeOf(R), ' ', SizeOf(TRec));
   S := 1 / 3;
   D := S;
   WriteLn(D:0:15);
   S := 16777216.0;
   S := S + 1;
   WriteLn(S:0:1);
   L := 100007;
   S := L;
   I := 7;
   WriteLn(Round(S), ' ', Trunc(S + I), ' ', Sqr(S):0:1, ' ', Sqrt(S):0:3);
   Val('2.5', S, Code);
   WriteLn(S:0:2, ' ', Code);
   Rec.S := 1.5;
   Rec.D := -2.25;
   Rec.E := 1.5E10;
   Rec.R := 3;
   Assign(F, 'FLOATS.DAT');
   Rewrite(F);
   Write(F, Rec);
   Close(F);
   Assign(B, 'FLOATS.DAT');
   Reset(B);
   while not Eof(B) do
   begin
      Read(B, Bt);
      Write(Bt, ' ');
   end;
   WriteLn;
   Close(B);
   Reset(F);
   Read(F, Rec);
   WriteLn(Rec.S:0:2, ' ', Rec.D:0:2, ' ', Rec.E, ' ', Rec.R:0:1);
   Close(F);
   Erase(F);
end.
