{ SetBkColor(c) makes colour 0 a copy of colour c as the palette has it
  now, so it follows an earlier SetPalette(c, ...) but not a later one,
  and SetBkColor(0) brings back black; a colour past 15 changes nothing
  (the tests run with RUSCAL_GRAPH=headless). Expected output from Turbo
  Pascal 7 in DOSBox. }
program GraphBkPalette;
uses Graph;
var
   Driver, Mode: Integer;
   P: PaletteType;
begin
   Driver := VGA;
   Mode := VGAHi;
   InitGraph(Driver, Mode, 'C:\TP\BGI');
   SetPalette(1, EGALightRed);
   SetBkColor(1);
   GetPalette(P);
   Write(P.Colors[0], ' ', GetBkColor, ' ');
   SetBkColor(0);
   GetPalette(P);
   Write(P.Colors[0], ' ');
   SetBkColor(2);
   SetPalette(2, EGAYellow);
   GetPalette(P);
   Write(P.Colors[0], ' ', P.Colors[2], ' ', GetBkColor, ' ');
   SetBkColor(17);
   SetBkColor(16);
   GetPalette(P);
   Write(P.Colors[0], ' ', GetBkColor);
   CloseGraph;
   WriteLn
end.
