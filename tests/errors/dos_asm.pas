{ An asm block is 8086 machine code, which needs a real DOS PC: refused
  with a message that says so (it was a parse error). }
program DosAsm;
begin
   asm
      mov ax, 1
end;
   end.
