{ SetColor(c) draws in the low 4 bits of c (17 draws in colour 1), but
  GetColor gives back c as it was set (the tests run with
  RUSCAL_GRAPH=headless). Expected output from Turbo Pascal 7 in DOSBox. }
program GraphSetColor;
uses Graph;
var
   Driver, Mode: Integer;
begin
   Driver := VGA;
   Mode := VGAHi;
   InitGraph(Driver, Mode, 'C:\TP\BGI');
   Write(GetColor, ' ');
   SetColor(17);
   Line(0, 0, 10, 0);
   Write(GetColor, ' ', GetPixel(5, 0), ' ');
   SetColor(16);
   Line(0, 0, 10, 0);
   Write(GetColor, ' ', GetPixel(5, 0), ' ');
   SetColor(300);
   Line(0, 2, 10, 2);
   Write(GetColor, ' ', GetPixel(5, 2));
   CloseGraph;
   WriteLn
end.
