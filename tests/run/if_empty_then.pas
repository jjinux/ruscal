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
end.
