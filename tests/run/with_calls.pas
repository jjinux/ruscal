{ A with record chosen by a function call (with A[Slot] do, with Pick^ do,
  with Items[Count] do in a method) is found once, before the body, as in
  Turbo Pascal: the function runs once, and every statement of the body
  means that record. Output from fpc -Mtp. }
program WithCalls;
type
   TRec = record
      X, Y: Integer;
   end;
   PRec = ^TRec;
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
end.
