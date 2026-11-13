{ A case whose selector is a constant (case 2 of, case SizeOf(Rec) of)
  takes labels of its integer type. Output from fpc -Mtp. }
program CaseConstantSelector;
type
   Rec = record
      N: Integer;
   end;
begin
   case SizeOf(Rec) of
      2: WriteLn('two');
      4: WriteLn('four');
   end;
   case 2 + 1 of
      2: WriteLn('two');
      3..5: WriteLn('three to five');
      else
         WriteLn('other');
   end;
end.
