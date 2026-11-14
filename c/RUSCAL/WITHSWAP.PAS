{ WITHSWAP: in with P^.Arr[Swap] do and with M[I, Swap] do, Swap changes
  P and I. Does TP 7 use P and I from before the call or after it? }
program WithSwap;
type
   TRec = record
      X, Y: Integer;
   end;
   TBox = record
      Arr: array[1..3] of TRec;
   end;
   PBox = ^TBox;
var
   B1, B2, P: PBox;
   M: array[1..3, 1..3] of TRec;
   I, J, K: Integer;

function Swap: Integer;
   begin
      P := B2;
      I := 3;
      Swap := 2;
   end;

begin
   New(B1);
   New(B2);
   for K := 1 to 3 do
   begin
      B1^.Arr[K].X := 0;
      B1^.Arr[K].Y := 0;
      B2^.Arr[K].X := 0;
      B2^.Arr[K].Y := 0;
      for J := 1 to 3 do
      begin
         M[K, J].X := 0;
         M[K, J].Y := 0;
      end;
   end;
   P := B1;
   with P^.Arr[Swap] do
   begin
      X := 5;
      Y := 6;
   end;
   WriteLn(B1^.Arr[2].X, ' ', B1^.Arr[2].Y, ' ', B2^.Arr[2].X, ' ', B2^.Arr[2].Y);
   I := 1;
   with M[I, Swap] do
   begin
      X := 7;
      Y := 8;
   end;
   WriteLn(M[1, 2].X, ' ', M[1, 2].Y, ' ', M[3, 2].X, ' ', M[3, 2].Y);
end.
