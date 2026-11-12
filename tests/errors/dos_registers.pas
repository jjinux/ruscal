{ Registers has only its Word fields: its Byte halves (AH, AL, ...) are
  only for Intr and MsDos, which need real DOS, so they say that, in a
  field or in a with. }
program DosRegisters;
uses Dos;
var
   R: Registers;
   AH: Byte;
begin
   R.AX := 1;
   R.AH := $4C;
   with R do
      AL := 0;
   { In a with, AH is the record's (TP binds it so), not the variable. }
   with R do
      AH := 1;
   MsDos(R);
end.
