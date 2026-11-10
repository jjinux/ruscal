{ Self passed to a var parameter of the object's type inside a virtual
  method: the parameter takes any descendant (&mut dyn in Rust), and Self
  there is the real object. Expected output from Turbo Pascal 7 in
  DOSBox. }
program SelfToVarDyn;
type
   TShape = object
      Sides: Integer;
      constructor Init;
      procedure Draw; virtual;
      function Name: string; virtual;
   end;
   TSquare = object(TShape)
      constructor Init;
      procedure Draw; virtual;
      function Name: string; virtual;
   end;
var
   Square: TSquare;

procedure Paint(var Sh: TShape);
   begin
      Sh.Sides := Sh.Sides + 1;
      WriteLn('paint ', Sh.Name, ' ', Sh.Sides);
   end;

constructor TShape.Init;
   begin
      Sides := 0;
   end;

procedure TShape.Draw;
   begin
      Paint(Self);
   end;

function TShape.Name: string;
   begin
      Name := 'shape';
   end;

constructor TSquare.Init;
   begin
      Sides := 4;
   end;

procedure TSquare.Draw;
   begin
      Paint(Self);
      inherited Draw;
   end;

function TSquare.Name: string;
   begin
      Name := 'square';
   end;

begin
   Square.Init;
   Square.Draw;
   WriteLn(Square.Sides);
end.
