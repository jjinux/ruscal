{ Port[...] reaches a DOS PC's I/O ports: refused with a message that says
  so (it was "unknown identifier"). A program's own Mem array is fine. }
program DosPort;
var
   Mem: array[1..2] of Integer;
begin
   Mem[1] := 2;
   Port[$60] := 1;
end.
