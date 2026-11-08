program OpenArraysBasics;
{ Open array parameters: &OpenArray<T> for a value or const one, &mut
  OpenArray<T> for a var one; an array argument is as_open(), one
  variable OpenArray::single, a string constant OpenArray::new; High is
  a.high(); a value one the routine changes is copied first; a nested
  routine and FillChar see it too. }
const
   Greeting = 'hello';
type
   TRec = record
      A: Integer;
      B: Char;
   end;
var
   Scores: array[1..3] of Integer;
   Recs: array[0..1] of TRec;
   N: Integer;

function Sum(const A: array of Integer): LongInt;
   var
      I: Integer;
      T: LongInt;
   begin
      T := 0;
      for I := Low(A) to High(A) do
         T := T + A[I];
      Sum := T;
   end;

procedure Twice(var A: array of Integer);

   procedure DoubleFirst;
      begin
         A[0] := A[0] * 2;
      end;

   begin
      DoubleFirst;
      WriteLn(Sum(A));
   end;

procedure Local(A: array of Integer);
   begin
      A[0] := 0;
      WriteLn(Sum(A), ' ', SizeOf(A));
   end;

procedure Count(const C: array of Char);
   begin
      WriteLn(High(C) + 1);
   end;

procedure Clear(var R: array of TRec);
   begin
      FillChar(R, SizeOf(R), 0);
   end;

begin
   Scores[1] := 1;
   Scores[2] := 2;
   Scores[3] := 3;
   N := 4;
   WriteLn(Sum(Scores), ' ', Sum(N));
   Twice(Scores);
   Twice(N);
   Local(Scores);
   Count('xyz');
   Count(Greeting);
   Clear(Recs);
end.
