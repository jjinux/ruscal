unit Geometry;
{ Used by units_demo.pas. }

interface

   const
      Sides = 4;

   type
      Point = record
         x, y: integer;
      end;

   var
      created: integer;   { a unit global, counted by MakePoint }

   procedure MakePoint(x, y: integer; var p: Point);
   procedure Describe(p: Point);
   function Name: string;

implementation

   procedure MakePoint(x, y: integer; var p: Point);
      begin
         p.x := x;
         p.y := y;
         created := created + 1;
      end;

   procedure Describe(p: Point);
      begin
         writeln('(', p.x, ', ', p.y, ')');
      end;

   function Name: string;
      begin
         Name := 'geometry';
      end;

begin
   created := 0;
   writeln('Geometry initialized');
end.
