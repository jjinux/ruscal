{ Write to a typed file takes a typecast variable, as in Turbo Pascal 7. }
program TypedFileCast;
var
   F: file of Word;
   I: Integer;
   W: Word;
begin
   Assign(F, 'tfcast.dat');
   Rewrite(F);
   I := -1;
   Write(F, Word(I));
   Reset(F);
   Read(F, W);
   WriteLn(W, ' ', FileSize(F));
   Close(F);
   Erase(F);
end.
