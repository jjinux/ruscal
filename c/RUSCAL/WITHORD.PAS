{ WITHORD: the order in which TP 7 works out a with record: the calls in
  its indexes first, from right to left (the last index of the last
  array first), and only then the pointer, so a call that changes the
  pointer (Swap) changes the record chosen. (Calls inside one index
  expression, Two + Three, follow TP's own expression order, which
  Ruscal doesn't: see TODO.md.) }
program WithOrd;
type
   TRec = record
      X, Y: Integer;
   end;
   PBox = ^TBox;
   TBox = record
      Next: PBox;
      Arr: array[1..3] of TRec;
   end;
var
   M: array[1..3, 1..3] of TRec;
   Ps: array[1..3] of PBox;
   N1, N2, P: PBox;
   Order: string;
   K: Integer;

function One: Integer;
   begin
      Order := Order + '1';
      One := 1;
   end;

function Two: Integer;
   begin
      Order := Order + '2';
      Two := 2;
   end;

function Three: Integer;
   begin
      Order := Order + '3';
      Three := 3;
   end;

function Pick: PBox;
   begin
      Order := Order + 'P';
      Pick := Ps[1];
   end;

function Swap: Integer;
   begin
      P := N2;
      Swap := 2;
   end;

procedure Clear(Q: PBox);
   var
      K: Integer;
   begin
      for K := 1 to 3 do
      begin
         Q^.Arr[K].X := 0;
         Q^.Arr[K].Y := 0;
      end;
   end;

begin
   for K := 1 to 3 do
      New(Ps[K]);
   Order := '';
   with M[One, Two] do
      X := 1;
   WriteLn(Order);
   Order := '';
   with Ps[One]^.Arr[Two] do
      X := 1;
   WriteLn(Order);
   Order := '';
   with Pick^.Arr[Two] do
      X := 1;
   WriteLn(Order);
   Order := '';
   with M[One, Two], Ps[Three]^.Arr[One] do
      Y := 1;
   WriteLn(Order);
   New(N1);
   New(N2);
   New(N1^.Next);
   New(N2^.Next);
   Clear(N1);
   Clear(N2);
   Clear(N1^.Next);
   Clear(N2^.Next);
   P := N1;
   with P^.Next^.Arr[Swap] do
   begin
      X := 5;
      Y := 6;
   end;
   WriteLn(N1^.Next^.Arr[2].X, ' ', N2^.Next^.Arr[2].X);
   P := N1;
   with P^.Arr[Swap] do
   begin
      X := 7;
      if P = nil then
         Y := 8;
   end;
   WriteLn(N1^.Arr[2].X, ' ', N2^.Arr[2].X);
end.
