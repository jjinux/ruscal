{ An enum typecast in a constant to a value the enum doesn't have: TP
  keeps the number, but a Rust enum can't hold it. Also inside another
  call, through a subrange, in a typed constant and as a case label. }
program EnumOutOfRange;
type
   Color = (Red, Green, Blue);
   Sub = Red..Green;
const
   Unset = Color(5);
   Ok = Color(2);
   Inside = Ord(Color(4));
   Ranged = Sub(6);
   Typed: Color = Color(3);
var
   C: Color;
begin
   C := Ok;
   case C of
      Color(7): WriteLn('never');
      Color(1): WriteLn('green');
   end;
end.
