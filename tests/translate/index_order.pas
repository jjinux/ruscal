{ The value of an assignment is worked out before the target's index, as
  in Turbo Pascal 7 (checked in DOSBox), also when the index goes into a
  let first; and an index that reads another field of the record, the
  stack idiom St.Items[St.Top], needs no let. A constant value needs no
  let either, and a value through a pointer gets just one. A procedural
  variable as the value is worked out first too (TP 7 prints 20 there:
  c/RUSCAL/IDXPROC.PAS). }
program IndexOrder;
type
   TArr = array[1..5] of Integer;
   TRec = record
      N: Integer;
      A: TArr;
   end;
   PRec = ^TRec;
   TFn = function(N: Integer): Integer;
   TStack = record
      Top: Integer;
      Items: array[1..10] of Char;
   end;
var
   A: TArr;
   R: TRec;
   St: TStack;
   I: Integer;
   P: PRec;
   Chars: array[1..4] of Char;
   Funcs: array[1..3] of TFn;
   FV: TFn;

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

function Twice(N: Integer): Integer; far;
   begin
      Twice := N * 2;
   end;

function Thrice(N: Integer): Integer; far;
   begin
      Thrice := N * 3;
   end;

function Switch(var N: Integer): Integer;
   begin
      N := N + 1;
      FV := Thrice;
      Switch := N;
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
   I := 1;
   Chars[Bump(I)] := 'q';
   Chars[Bump(I)] := #65;
   WriteLn(Chars[2], Chars[3]);
   New(P);
   P^.N := 1;
   for I := 1 to 5 do
      P^.A[I] := 0;
   P^.A[P^.N] := SetN(P^);
   WriteLn(P^.A[1], ' ', P^.A[2], ' ', P^.N);
   Dispose(P);
   FV := Twice;
   I := 0;
   Funcs[Switch(I)] := FV;
   WriteLn(Funcs[1](10));
end.
