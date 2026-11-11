{ Mem[Seg:Ofs] reaches a DOS PC's memory: refused with a message that says
  so (it was "expected ]"). }
program DosMem;
var
   B: Byte;
begin
   B := Mem[$40: $17];
end.
