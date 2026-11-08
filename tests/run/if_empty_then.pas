program IfEmptyThen;
{ An empty then branch before an else keeps the comment that explains it
  in the then block. }
var
   I: Integer;
begin
   I := 1;
   if I = 0 then
   { do nothing, this is the base case }
   else
   begin
      WriteLn(I);
   end;
   if I = 1 then
   { nothing here either }
   else
      WriteLn(2);
   if I = 2 then
   else { a comment after else is about the else branch }
      WriteLn(3);
   if I = 1 then { this one is about the then branch }
   else { and this one about the else branch }
      WriteLn(4);
end.
