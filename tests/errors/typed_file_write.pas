{ Write to a typed file takes a variable of the file's own type, as in
  Turbo Pascal 7 ("Variable identifier expected", "Type mismatch"):
  not a value, and not a Single for a file of Real or a Double for a
  file of Single. Read likewise. A typecast variable is fine, a typecast
  value isn't. }
{$N+}
program TypedFileWrite;
var
   S: Single;
   D: Double;
   R: Real;
   FS: file of Single;
   FR: file of Real;
   FW: file of Word;
   I: Integer;
begin
   Write(FS, D);
   Write(FS, 3);
   Write(FS, S * 2);
   Write(FR, S);
   Read(FR, D);
   Write(FS, S);
   Write(FW, Word(I));
   Write(FW, Word(I + 1));
end.
