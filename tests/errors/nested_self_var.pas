{ A procedure nested in a virtual method passes Self to a var parameter
  of a type with virtual methods: not supported yet (the nested procedure
  holds only the object's own part, so virtual calls on the parameter
  would go to the wrong version). }
program DynNest3;
type
   TShape = object
      Sides: Integer;
      constructor Init;
      procedure Draw; virtual;
      function Name: string; virtual;
   end;
   TSquare = object(TShape)
      function Name: string; virtual;
   end;
var
   Sq: TSquare;

procedure Paint(var Sh: TShape);
   begin
      WriteLn('paint ', Sh.Name);
   end;

constructor TShape.Init;
   begin
      Sides := 0;
   end;

procedure TShape.Draw;
   procedure Helper;
      begin
         Paint(Self);
      end;
   begin
      Helper;
   end;

function TShape.Name: string;
   begin
      Name := 'shape';
   end;

function TSquare.Name: string;
   begin
      Name := 'square';
   end;

begin
   Sq.Init;
   Sq.Draw;
end.
