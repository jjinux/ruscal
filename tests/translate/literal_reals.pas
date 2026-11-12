{ A real function of an expression made only of literals (Round(2.5 +
  0.0), Sqrt(2.0 + 2.0)) is written as its value in the Rust, which can
  call a method on it; (2.5 + 0.0).round() wouldn't compile. Expected
  output from Turbo Pascal 7 in DOSBox. }
program LiteralReals;
const
   C = 2.5;
var
   L: LongInt;
   R: Real;
begin
   L := Trunc(2.5 + 0.0);
   Write(L, ' ');
   L := Round(1 / 2);
   Write(L, ' ');
   L := Round(2 * 1.5);
   Write(L, ' ');
   L := Round(C + 0.5);
   WriteLn(L);
   R := Sqrt(2.0 + 2.0);
   WriteLn(R:0:1);
   R := Int(1.5 * 2);
   WriteLn(R:0:1);
   R := Abs(-1.5 + 0.0);
   WriteLn(R:0:1);
   R := Abs(-(1.5 + 0.0));
   L := Trunc(-(2.5 + 0.0));
   WriteLn(R:0:1, ' ', L);
   R := -0;
   Write(R:0:1, ' ');
   R := -5;
   WriteLn(R:0:1);
end.
