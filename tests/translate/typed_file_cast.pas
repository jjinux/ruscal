{ Write to a typed file takes a typecast variable of the same size, as in
  Turbo Pascal 7: an Integer, an untyped parameter, a string's
  character. }
program TypedFileCast;
var
   F: file of Word;
   I: Integer;
   W: Word;
   FB: file of Byte;
   s: string;
   b, B2: Byte;

procedure WriteBytes(var Data);
   begin
      Write(F, Word(Data));
   end;

begin
   Assign(F, 'tfcast.dat');
   Rewrite(F);
   I := -1;
   Write(F, Word(I));
   Reset(F);
   Read(F, W);
   WriteLn(W, ' ', FileSize(F));
   W := 40;
   Seek(F, 0);
   WriteBytes(W);
   Seek(F, 0);
   Read(F, W);
   WriteLn(W);
   Close(F);
   Erase(F);
   Assign(FB, 'tfcastb.dat');
   Rewrite(FB);
   s := 'A';
   Write(FB, Byte(s[1]), Byte(s[0]));
   Reset(FB);
   Read(FB, b, B2);
   WriteLn(b, ' ', B2);
   Close(FB);
   Erase(FB);
end.
