{ SizeOf(Rec) keeps its name in the Rust wherever it's used: runtime
  routines' counts, overflow-checked arithmetic, reals, a minus sign, an
  index and in. Output from fpc -Mtp. }
{$Q+}
program SizeOfMore;
type
   Point = record
      X, Y: Integer;
   end;
   Rec = record
      N: Integer;
      P: Point;
   end;
   Big = array[1..300] of Byte;
var
   I, J: Integer;
   R: Real;
   A: array[1..20] of Byte;
   S: set of Byte;
   Small: set of 0..100;
   F: file;
   P: Pointer;
   B: Rec;
begin
   I := 3;
   J := SizeOf(Rec) * I;
   WriteLn(J);
   J := (SizeOf(Rec) + SizeOf(Point)) * I;
   WriteLn(J);
   J := -SizeOf(Rec) * I;
   WriteLn(J);
   R := SizeOf(Rec);
   WriteLn(R:0:1);
   R := SizeOf(Rec) / 4;
   WriteLn(R:0:2);
   R := SizeOf(Rec) * 2;
   WriteLn(R:0:1);
   R := SizeOf(Rec) * 1.5;
   WriteLn(R:0:1);
   WriteLn(-SizeOf(Rec), ' ', -(-SizeOf(Rec)));
   A[SizeOf(Point) + 1] := 7;
   WriteLn(A[5]);
   S := [6];
   WriteLn(SizeOf(Rec) in S, ' ', SizeOf(Big) in Small);
   B.N := 1;
   B.P.X := 2;
   B.P.Y := 3;
   Assign(F, 'sznames.dat');
   Rewrite(F, 1);
   BlockWrite(F, B, SizeOf(Rec));
   BlockWrite(F, B, I * SizeOf(Rec) div 3);
   Seek(F, SizeOf(Rec));
   WriteLn(FileSize(F), ' ', FilePos(F));
   Close(F);
   Erase(F);
   GetMem(P, 10 * SizeOf(Rec));
   FreeMem(P, 10 * SizeOf(Rec));
   FillChar(A, SizeOf(Point), 0);
   Move(B, A, SizeOf(Rec));
   WriteLn(A[1], A[3], A[5]);
end.
