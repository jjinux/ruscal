{ For with_calls.pas: a with record chosen by a function call in a
  unit's initialization part. }
unit WithUnit;

interface

   type
      TCell = record
         X, Y: Integer;
      end;

   var
      Calls: Integer;
      Cells: array[1..3] of TCell;

implementation

   function Slot: Integer;
      begin
         Calls := Calls + 1;
         Slot := Calls;
      end;

begin
   Calls := 0;
   with Cells[Slot] do
   begin
      X := 3;
      Y := 4;
   end;
end.
