{ A program's own record named Registers isn't the Dos unit's: a missing
  AH is just a missing field. }
program OwnRegisters;
type
   Registers = record
      AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags: Word;
   end;
var
   R: Registers;
begin
   R.AH := 2;
end.
