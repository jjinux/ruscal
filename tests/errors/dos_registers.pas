{ Registers has only its Word fields: its Byte halves (AH, AL, ...) are
  only for Intr and MsDos, which need real DOS, so they say that, in a
  field or in a with. }
program DosRegisters;
uses Dos;
var
   R: Registers;
begin
   R.AX := 1;
   R.AH := $4C;
   with R do
      AL := 0;
   MsDos(R);
end.
