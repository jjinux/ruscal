{ Chr of a literal past a byte keeps its low 8 bits, as Turbo Pascal 7
  did (Chr(300) is ',', 44; checked in DOSBox). }
program ChrLiterals;
var
   C: Char;
begin
   C := Chr(300);
   WriteLn(Ord(C), ' ', C);
   WriteLn(Ord(Chr(256)), ' ', Ord(Chr(65)));
end.
