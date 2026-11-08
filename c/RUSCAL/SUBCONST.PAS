{ Q4: type Small = 0..10; const X = Small(300): a compile error, or 44? }
program SubConst;
type
   Small = 0..10;
const
   X = Small(300);
begin
   WriteLn('Small(300) = ', X)
end.
