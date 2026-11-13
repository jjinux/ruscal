{ A $ without hex digits is only the location counter in an asm block;
  anywhere else it's an error at the $. }
program StrayDollar;
var
   X: Integer;
begin
   X := $;
end.
