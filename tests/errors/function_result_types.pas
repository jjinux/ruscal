{ A function can't return a record, array, set, object or file, as in
  Turbo Pascal 7 ("Invalid function result type"); an ordinal type, a
  real, a string or a pointer is fine. }
program FunctionResultTypes;
type
   TRec = record
      A: Integer;
   end;
   TArr = array[1..2] of Integer;
   TSet = set of 0..7;
   TObj = object
      A: Integer;
   end;
   TMake = function: TRec;

function MakeRec: TRec;
   begin
   end;

function MakeArr: TArr;
   begin
   end;

function MakeSet: TSet;
   begin
   end;

function MakeObj: TObj;
   begin
   end;

function Fine: string;
   begin
      Fine := 'ok';
   end;

begin
end.
