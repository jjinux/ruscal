{ Ruscal's temporaries start with rsc_, so a function named Index or
  Value doesn't clash with them. Output from fpc -Mtp. }
program TempNames;
var
   A: array[0..9] of Integer;
   I: Integer;

function Index(N: Integer): Integer;
   begin
      Index := N + 1;
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
end.
