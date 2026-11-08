{ Const parameters Turbo Pascal passes by reference, in routines that
  share a signature or reach them indirectly: a procedural type's
  routines, a method called by a nested routine, and an object we hold as
  &mut dyn (a var parameter, Self in a virtual method) given to a const or
  value parameter. Expected output from Turbo Pascal 7 in DOSBox. (The
  $F+ directive: TP assigns only far routines to a procedural variable.) }
{$F+}
program ConstRefFamilies;
type
   TCounter = object
      Count, Step, Limit: Integer;
      procedure Bump;
   end;
   TAct = procedure(const C: TCounter);
   TShape = object
      X: Integer;
      Pad: array[1..3] of Integer;
      constructor Init;
      procedure Draw; virtual;
   end;
   TCircle = object(TShape)
      procedure Draw; virtual;
   end;
var
   Counter: TCounter;
   Act: TAct;
   Circle: TCircle;

procedure TCounter.Bump;
   begin
      Inc(Count, Step);
   end;

procedure BumpIt(const C: TCounter);
   begin
      C.Bump;
   end;

procedure ShowIt(const C: TCounter);
   begin
      WriteLn('count ', C.Count);
   end;

procedure Twice(const C: TCounter; A: TAct);
   begin
      A(C);
      A(C);
   end;

procedure Outer(const C: TCounter);

   procedure Inner;
      begin
         C.Bump;
      end;

   begin
      Inner;
   end;

procedure ShowX(const Sh: TShape);
   begin
      WriteLn('x ', Sh.X);
   end;

procedure CopyX(Sh: TShape);
   begin
      WriteLn('copy ', Sh.X);
   end;

constructor TShape.Init;
   begin
      X := 5;
   end;

procedure TShape.Draw;
   begin
      ShowX(Self);
   end;

procedure TCircle.Draw;
   begin
      X := 7;
      ShowX(Self);
      CopyX(Self);
   end;

procedure Paint(var Sh: TShape);
   begin
      ShowX(Sh);
      Sh.Draw;
   end;

begin
   Counter.Step := 2;
   Twice(Counter, BumpIt);
   Twice(Counter, ShowIt);
   Act := BumpIt;
   Act(Counter);
   Outer(Counter);
   ShowIt(Counter);
   Circle.Init;
   Paint(Circle);
end.
