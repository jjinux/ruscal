{ Ruscal's temporaries start with rsc_, so a function named Index or
  Value doesn't clash with them; nor do Pascal names that start with
  Rsc_ themselves (a function Rsc_Index, a variable Rsc_I beside a for
  loop's I). Output from fpc -Mtp. }
program TempNames;
var
   A: array[0..9] of Integer;
   I, Rsc_I: Integer;

function Index(N: Integer): Integer;
   begin
      Index := N + 1;
   end;

function Rsc_Index: Integer;
   begin
      Rsc_Index := 2;
   end;

function Value(N: Integer): Integer;
   begin
      Value := N * 10;
   end;

begin
   for I := 0 to 9 do
      A[I] := I;
   A[A[Index(0)]] := A[Index(1)] + Value(4);
   WriteLn(A[1], ' ', A[2]);
   A[1] := 1;
   A[A[1]] := 3;
   WriteLn(Rsc_Index, ' ', A[1]);
   Rsc_I := 3;
   for I := 1 to Rsc_I do
      Write(Rsc_I, ' ');
   WriteLn(I);
end.
