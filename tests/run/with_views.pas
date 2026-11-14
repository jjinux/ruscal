{ with TRec(Data) do, where Data is an untyped parameter: each statement
  of the body reads the bytes and writes them back, so the body can only
  read, use two views or nest them, use Data directly or pass it on, take
  a field of the view, and leave with Break. Output from fpc -Mtp. }
program WithViews;
type
   TRec = record
      A, B: Integer;
   end;
   TInner = record
      X, Y: Integer;
   end;
   TOuter = record
      Tag: Integer;
      Inner: TInner;
   end;
var
   R, S: TRec;
   O: TOuter;

procedure Bump(var N: Integer);
   begin
      N := N + 1;
   end;

procedure Fill(var D);
   begin
      TRec(D).B := TRec(D).A + 1;
   end;

procedure ReadOnly(var Data);
   begin
      with TRec(Data) do
         WriteLn(A, ' ', B);
   end;

procedure Two(var D1, D2);
   begin
      with TRec(D1), TRec(D2) do
         A := A + 1;
      with TRec(D1) do
         with TRec(D2) do
            B := B + 10;
      with TRec(D1) do
      begin
         A := 1;
         TRec(D2).A := A + 1;
         B := 7;
      end;
   end;

procedure Direct(var Data);
   begin
      with TRec(Data) do
      begin
         A := 5;
         WriteLn(TRec(Data).A, ' ', Word(Data));
         TRec(Data).B := 9;
         Fill(Data);
         WriteLn(B);
      end;
   end;

procedure Field(var Data);
   begin
      with TOuter(Data).Inner do
      begin
         X := 1;
         Y := X + 1;
         Bump(Y);
      end;
   end;

procedure Leave(var Data);
   var
      K: Integer;
   begin
      for K := 1 to 5 do
         with TRec(Data) do
         begin
            A := K;
            if K = 3 then
               Break;
            B := K;
         end;
   end;

begin
   R.A := 1; R.B := 308;
   ReadOnly(R);
   R.A := 1; R.B := 2; S.A := 3; S.B := 4;
   Two(R, S);
   WriteLn(R.A, ' ', R.B, ' ', S.A, ' ', S.B);
   R.A := 1; R.B := 2;
   Direct(R);
   WriteLn(R.A, ' ', R.B);
   Field(O);
   WriteLn(O.Inner.X, ' ', O.Inner.Y);
   R.A := 0; R.B := 0;
   Leave(R);
   WriteLn(R.A, ' ', R.B);
end.
