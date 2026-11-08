{ Open array parameters (TP 7): an array of any size and bounds, or one
  variable, indexed from 0 inside; a value one is a copy; High, Low and
  SizeOf; passed on, captured by a nested routine, a method's, a
  procedural type's; array of Char takes a string constant; FillChar on
  one. Expected output from Turbo Pascal 7 in DOSBox. (The $F+ directive:
  TP assigns only far routines to a procedural variable.) }
{$F+}
program OpenArrays;
type
   TRec = record
      A: Integer;
      B: Char;
   end;
   TShow = procedure(const A: array of Integer);
   TBag = object
      Total: LongInt;
      procedure Add(const A: array of Integer);
   end;
var
   A3: array[1..3] of Integer;
   A5: array[-2..2] of Integer;
   C4: array[1..4] of Char;
   Names: array[0..2] of string;
   R2: array[1..2] of TRec;
   Bag: TBag;
   Show: TShow;
   X, I: Integer;

procedure TBag.Add(const A: array of Integer);
   var
      I: Integer;
   begin
      for I := 0 to High(A) do
         Total := Total + A[I];
   end;

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

procedure ShowAll(const A: array of Integer);
   var
      I: Integer;
   begin
      for I := Low(A) to High(A) do
         Write(A[I], ' ');
      WriteLn;
   end;

procedure Twice(var A: array of Integer);
   var
      I: Integer;
   begin
      for I := 0 to High(A) do
         A[I] := A[I] * 2;
   end;

procedure Local(A: array of Integer);
   begin
      A[0] := 99;
      WriteLn('local ', A[0], ' size ', SizeOf(A), ' high ', High(A));
   end;

procedure Chars(const C: array of Char);
   var
      I: Integer;
   begin
      Write('chars ', High(C), ':');
      for I := 0 to High(C) do
         Write(C[I]);
      WriteLn;
   end;

procedure Bump(var N: Integer);
   begin
      Inc(N, 100);
   end;

procedure Outer(var A: array of Integer; B: array of Integer);

   procedure Inner;
      begin
         A[0] := A[0] + 1;
         B[0] := 42;
         WriteLn('inner ', A[0], ' ', B[0], ' ', High(B));
      end;

   begin
      Inner;
      ShowAll(A);
      ShowAll(B);
   end;

procedure Pass(var A: array of Integer);
   begin
      Inc(A[1]);
      Bump(A[2]);
      ShowAll(A);
   end;

procedure Strings(var S: array of string);
   var
      I: Integer;
   begin
      for I := 0 to High(S) do
         S[I] := S[I] + '!';
      WriteLn(SizeOf(S), ' ', S[1]);
   end;

procedure Recs(var R: array of TRec);
   begin
      with R[0] do
      begin
         A := 5;
         B := 'z';
      end;
      FillChar(R[1], SizeOf(R[1]), 0);
      WriteLn(R[0].A, R[0].B, ' ', R[1].A, ' ', SizeOf(R));
   end;

procedure Clear(var A: array of Integer);
   begin
      FillChar(A, SizeOf(A), 0);
   end;

begin
   for I := 1 to 3 do
      A3[I] := I;
   for I := -2 to 2 do
      A5[I] := I * 10;
   X := 5;
   WriteLn(Sum(A3), ' ', Sum(A5), ' ', Sum(X));
   Twice(A3);
   Twice(X);
   WriteLn(A3[1], ' ', A3[3], ' ', X);
   Local(A5);
   WriteLn(A5[-2]);
   C4 := 'abcd';
   Chars(C4);
   Chars('xy');
   Outer(A3, A3);
   ShowAll(A3);
   Pass(A3);
   Names[0] := 'a';
   Names[1] := 'b';
   Names[2] := 'c';
   Strings(Names);
   R2[2].A := 9;
   Recs(R2);
   Bag.Total := 0;
   Bag.Add(A3);
   WriteLn(Bag.Total);
   Show := ShowAll;
   Show(A5);
   Clear(A3);
   ShowAll(A3);
end.
