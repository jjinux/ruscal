{ A method may be called on a const parameter, but an index in the
  receiver is not the receiver: passing a const parameter by var there is
  an error, as in Turbo Pascal 7 ("Invalid variable reference"). }
program ConstParamReceiverIndex;
type
   TCounter = object
      Count: Integer;
      procedure Bump;
   end;
   PCounter = ^TCounter;

procedure TCounter.Bump;
   begin
      Inc(Count);
   end;

function Next(var N: Integer): Integer;
   begin
      Inc(N);
      Next := N;
   end;

function GetP(var N: Integer): PCounter;
   begin
      Inc(N);
      GetP := nil;
   end;

procedure Use(const N: Integer);
   var
      A: array[1..3] of TCounter;
   begin
      A[Next(N)].Bump;
      GetP(N)^.Bump;
   end;

begin
end.
