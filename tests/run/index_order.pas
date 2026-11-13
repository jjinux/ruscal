{ The value of an assignment is worked out before the target's index, as
  in Turbo Pascal 7 (checked in DOSBox), also when the index goes into a
  let first; and an index that reads another field of the record, the
  stack idiom St.Items[St.Top], needs no let. }
program IndexOrder;
type
   TArr = array[1..5] of Integer;
   TRec = record
      N: Integer;
      A: TArr;
   end;
   TStack = record
      Top: Integer;
      Items: array[1..10] of Char;
   end;
var
   A: TArr;
   R: TRec;
   St: TStack;
   I: Integer;

function SetN(var X: TRec): Integer;
   begin
      X.N := X.N + 1;
      SetN := 50;
   end;

function Bump(var X: Integer): Integer;
   begin
      X := X + 1;
      Bump := X;
   end;

procedure Show;
   var
      K: Integer;
   begin
      for K := 1 to 5 do
         Write(A[K], ' ');
      WriteLn;
   end;

begin
   for I := 1 to 5 do
   begin
      A[I] := I;
      R.A[I] := I;
   end;
   R.N := 1;
   R.A[R.N] := SetN(R);
   WriteLn(R.A[1], ' ', R.A[2], ' ', R.N);
   A[A[1]] := Bump(A[1]) + 10;
   Show;
   A[1] := 1;
   A[Bump(A[1])] := A[A[1]] + 100;
   Show;
   A[Succ(Low(A))] := 9;
   A[Pred(High(A))] := 8;
   Show;
   St.Top := 0;
   Inc(St.Top);
   St.Items[St.Top] := 'x';
   Inc(St.Top);
   St.Items[St.Top] := 'y';
   WriteLn(St.Items[1], St.Items[2], ' ', St.Top);
end.
