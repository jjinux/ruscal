{ A const parameter can't be changed, but Turbo Pascal 7 lets a method be
  called on a const object parameter, and lets a program write through a
  const pointer parameter (that changes what it points to, not the
  pointer). Expected output from Turbo Pascal 7 in DOSBox. }
program ConstParams;
type
   PInt = ^Integer;
   TCounter = object
      Count: Integer;
      procedure Bump;
   end;

procedure TCounter.Bump;
   begin
      Inc(Count);
      WriteLn('bumped to ', Count);
   end;

procedure Use(const C: TCounter; const P: PInt; const N: Integer);
   begin
      C.Bump;
      P^ := N * 2;
      WriteLn(C.Count, ' ', N);
   end;

var
   Counter: TCounter;
   P: PInt;
begin
   Counter.Count := 10;
   New(P);
   P^ := 0;
   Use(Counter, P, 21);
   WriteLn(Counter.Count, ' ', P^);
   Dispose(P);
end.
