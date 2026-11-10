program UnitsDemo;
uses Geometry, Labels;
var
   p, q: Point;
begin
   MakePoint(3, 4, p);
   Tag(p, 'home');
   MakePoint(1, 2, q);
   Tag(q, 'work');
   writeln(Name, ' ', Sides, ' ', created);
end.
