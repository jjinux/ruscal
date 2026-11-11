{ An enum typecast in a constant to a value the enum doesn't have: TP
  keeps the number, but a Rust enum can't hold it. }
program EnumOutOfRange;
type
   Color = (Red, Green, Blue);
const
   Unset = Color(5);
   Ok = Color(2);
begin
   WriteLn(Ord(Ok));
end.
