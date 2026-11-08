{ Open array parameters passed on to var and value ones, as bytes (Move,
  BlockWrite, BlockRead, FillChar), and a value one given the same array
  as a var one in a routine that holds the array by reference. From Fable's
  review of the open-arrays branch. Expected output from Turbo Pascal 7 in
  DOSBox. }
program OpenArrayPassing;
type
   TRec = record
      A: Integer;
      S: string[10];
   end;
var
   G: array[1..4] of Integer;
   R: array[1..2] of TRec;
   Rs: array[1..2] of Real;
   F: file;
   I: Integer;

procedure Twice(var A: array of Integer);
   var
      I: Integer;
   begin
      for I := 0 to High(A) do
         A[I] := A[I] * 2;
   end;

procedure Both(var V: array of Integer; A: array of Integer);
   begin
      V[0] := 50;
      WriteLn(A[0], ' ', V[0]);
   end;

procedure Fwd(var A: array of Integer);
   begin
      Both(A, A);
      Twice(A);
   end;

procedure Local(A: array of Integer);
   begin
      Twice(A);
      WriteLn('local ', A[0]);
   end;

procedure Sizes(const A: array of TRec; const B: array of Real);
   begin
      WriteLn(SizeOf(A), ' ', SizeOf(B));
   end;

procedure MoveIt(var A: array of Integer);
   begin
      Move(A[0], A[2], 2 * SizeOf(Integer));
      Move(A, A[1], 2);
      WriteLn(A[0], ' ', A[1], ' ', A[2], ' ', A[3]);
   end;

procedure Save(var A: array of TRec);
   begin
      Assign(F, 'OPENPASS.DAT');
      Rewrite(F, 1);
      BlockWrite(F, A, SizeOf(A));
      Close(F);
   end;

procedure Load(var A: array of TRec);
   var
      N: Word;
   begin
      Assign(F, 'OPENPASS.DAT');
      Reset(F, 1);
      BlockRead(F, A, SizeOf(A), N);
      Close(F);
      WriteLn(N, ' ', A[0].A, ' ', A[1].S);
   end;

procedure Clear(var A: array of TRec);
   begin
      FillChar(A, SizeOf(A), 0);
      WriteLn('cleared ', A[0].A, ' ', Length(A[1].S));
   end;

procedure Caller;
   begin
      G[1] := 1;
      Both(G, G);
      Both(G[2], G);
      WriteLn(G[1], ' ', G[2]);
   end;

begin
   for I := 1 to 4 do
      G[I] := I;
   Fwd(G);
   WriteLn(G[1], ' ', G[2]);
   Local(G);
   WriteLn(G[1]);
   Sizes(R, Rs);
   for I := 1 to 4 do
      G[I] := I;
   MoveIt(G);
   R[1].A := 7;
   R[2].S := 'two';
   Save(R);
   R[1].A := 0;
   R[2].S := '';
   Load(R);
   Clear(R);
   Caller;
end.
