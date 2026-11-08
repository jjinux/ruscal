program ConstByReference;
{ A const parameter Turbo Pascal passes by reference is a reference in
  Rust: &PString for a string, &TBig for a record of more than 4 bytes
  (a 4-byte one is copied), &mut TCounter when a method is called on it
  or it's passed on to such a parameter, and &mut too when the routine
  changes the global every call passes, which it then reads through the
  parameter. }
type
   TSmall = record
      A, B: Integer;
   end;
   TBig = record
      A, B, C: Integer;
   end;
   TCounter = object
      Count, Step, Limit: Integer;
      procedure Bump;
   end;
var
   Name: string;
   Small: TSmall;
   Big: TBig;
   Counter: TCounter;

procedure TCounter.Bump;
   begin
      Inc(Count, Step);
   end;

procedure Greet(const S: string);
   begin
      WriteLn('hello, ', S);
   end;

function Total(const X: TBig; const Y: TSmall): Integer;
   begin
      Total := X.A + X.B + X.C + Y.A + Y.B;
   end;

procedure BumpIt(const C: TCounter);
   begin
      C.Bump;
   end;

procedure PassOn(const C: TCounter);
   begin
      BumpIt(C);
   end;

procedure Reset(const X: TBig);
   begin
      Big.A := 0;
      WriteLn(X.A);
   end;

begin
   Name := 'world';
   Greet(Name);
   Greet('there');
   Greet(Name + '!');
   Big.A := 1;
   Small.A := 2;
   WriteLn(Total(Big, Small));
   Counter.Step := 5;
   BumpIt(Counter);
   PassOn(Counter);
   WriteLn(Counter.Count);
   Reset(Big);
end.
