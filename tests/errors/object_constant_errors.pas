{ An object constant gives values to fields, not methods; and a string
  divided by 0 is a type error, not a division by zero. }
program ObjectConstantErrors;
type
   TBase = object
      Count: Integer;
      procedure Bump;
   end;

procedure TBase.Bump;
   begin
   end;

const
   K: TBase = (Count: 1; Bump: 2);
   Missing: TBase = (Size: 3);
begin
   WriteLn('a' / 0);
end.
