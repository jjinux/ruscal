{ A constant out of range for a standard routine's Byte or Word parameter
  (GotoXY(300, 1)), or for an open array's element type given a single
  value, is an error, as Turbo Pascal 7's "Constant out of range". }
program RoutineConstantRange;
uses Crt;

procedure Show(const A: array of Byte);
   begin
   end;

begin
   GotoXY(300, 1);
   TextColor(-1);
   Delay(70000);
   Window(1, 1, 80, 256);
   Show(300);
   { Fine: in range, and a variable is checked at run time if at all. }
   GotoXY(80, 25);
   Delay(65535);
   Show(255);
end.
