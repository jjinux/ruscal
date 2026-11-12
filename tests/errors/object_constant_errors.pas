{ An object constant gives values to fields, not methods, and each field
  once (a record constant too); a string or a Real divided by 0 with `/`
  or `div` is a type error, not a division by zero. }
program ObjectConstantErrors;
type
   TPoint = record
      X, Y: Integer;
   end;
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
   Twice: TBase = (Count: 1; Count: 2);
   P: TPoint = (X: 1; X: 2);
begin
   WriteLn('a' / 0);
   WriteLn(1.5 div 0);
end.
