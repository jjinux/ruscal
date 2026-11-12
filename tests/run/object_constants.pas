{ Typed constants of object types (TP 7): fields, inherited ones too, as
  in a record constant; an object with virtual methods works without a
  constructor call, as TP filled in its VMT. Expected output from Turbo
  Pascal 7 in DOSBox. }
program ObjectConstants;
type
   TBase = object
      Count: Integer;
      procedure Bump;
   end;
   TKid = object(TBase)
      Step: Integer;
      procedure Show; virtual;
   end;
   TPair = array[1..2] of TBase;

procedure TBase.Bump;
   begin
      Inc(Count);
   end;

procedure TKid.Show;
   begin
      WriteLn('Kid ', Count, ' ', Step);
   end;

const
   K: TBase = (Count: 10);
   D: TKid = (Count: 5; Step: 2);
   { Fields left out at the end are 0. }
   NoStep: TKid = (Count: 3);
   Pair: TPair = ((Count: 1), (Count: 2));

{ A typed constant keeps its value between calls. }
procedure Tick;
   const
      T: TBase = (Count: 100);
   begin
      T.Bump;
      WriteLn('Tick ', T.Count);
   end;

begin
   K.Bump;
   D.Bump;
   WriteLn(K.Count, ' ', D.Count, ' ', D.Step, ' ', SizeOf(K));
   D.Show;
   NoStep.Show;
   Pair[2].Bump;
   WriteLn(Pair[1].Count, ' ', Pair[2].Count);
   Tick;
   Tick;
end.
