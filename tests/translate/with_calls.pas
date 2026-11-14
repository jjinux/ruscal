{ A with record chosen by a function call (with A[Slot] do, with Pick^ do,
  with Items[Next] do in a method, a procedural variable FV, IOResult, in a
  unit's initialization) is found once, before the body, as in Turbo
  Pascal: the function runs once, and every statement of the body means
  that record; with Pick^.Arr[Slot] runs Pick first. Output from
  fpc -Mtp. }
program WithCalls;
{$F+}
uses WithUnit;
type
   TRec = record
      X, Y: Integer;
   end;
   PRec = ^TRec;
   TBox = record
      Arr: array[1..3] of TRec;
   end;
   PBox = ^TBox;
   TSlotFn = function: Integer;
   TList = object
      Count: Integer;
      Items: array[1..5] of TRec;
      function Next: Integer;
      procedure Fill;
   end;
var
   G: Integer;
   A: array[1..5] of TRec;
   Ps: array[1..3] of PRec;
   L: TList;
   K: Integer;
   Order: string;
   Box: PBox;
   FV: TSlotFn;
   F: Text;

function Slot: Integer;
   begin
      G := G + 1;
      Slot := G;
   end;

function Pick: PRec;
   begin
      G := G + 1;
      Pick := Ps[G];
   end;

function PickBox: PBox;
   begin
      Order := Order + 'P';
      PickBox := Box;
   end;

function Two: Integer;
   begin
      Order := Order + 'S';
      Two := 2;
   end;

function TList.Next: Integer;
   begin
      Inc(Count);
      Next := Count;
   end;

procedure TList.Fill;
   begin
      with Items[Next] do
      begin
         X := 7;
         Y := 8;
      end;
   end;

begin
   for K := 1 to 5 do
   begin
      A[K].X := K;
      A[K].Y := K * 10;
   end;
   G := 0;
   with A[Slot] do
      WriteLn(X, ' ', Y);
   WriteLn(G);
   G := 0;
   with A[Slot] do
   begin
      X := 100;
      Y := 200;
   end;
   WriteLn(G, ' ', A[1].X, ' ', A[1].Y, ' ', A[2].Y);
   for K := 1 to 3 do
   begin
      New(Ps[K]);
      Ps[K]^.X := 0;
      Ps[K]^.Y := 0;
   end;
   G := 0;
   with Pick^ do
   begin
      X := 5;
      Y := 6;
   end;
   WriteLn(G, ' ', Ps[1]^.X, ' ', Ps[1]^.Y, ' ', Ps[2]^.Y);
   L.Count := 0;
   for K := 1 to 5 do
   begin
      L.Items[K].X := 0;
      L.Items[K].Y := 0;
   end;
   L.Fill;
   WriteLn(L.Count, ' ', L.Items[1].X, ' ', L.Items[1].Y, ' ', L.Items[2].Y);
   WriteLn(Calls, ' ', Cells[1].X, ' ', Cells[1].Y);
   New(Box);
   Order := '';
   with PickBox^.Arr[Two] do
   begin
      X := 1;
      Y := 2;
   end;
   WriteLn(Order, ' ', Box^.Arr[2].X, ' ', Box^.Arr[2].Y);
   for K := 1 to 5 do
   begin
      A[K].X := 0;
      A[K].Y := 0;
   end;
   G := 0;
   FV := Slot;
   with A[FV] do
   begin
      X := 1;
      Y := 2;
   end;
   WriteLn(G, ' ', A[1].X, ' ', A[1].Y, ' ', A[2].Y);
   Assign(F, 'no_such_dir_here/x.txt');
   {$I-}
   Reset(F);
   {$I+}
   with A[IOResult - 1] do
   begin
      X := 3;
      Y := 4;
   end;
   WriteLn(A[1].X, ' ', A[1].Y, ' ', A[4].X, ' ', A[4].Y);
end.
