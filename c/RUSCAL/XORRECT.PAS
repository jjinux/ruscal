{ Q5: in XOR mode, does Rectangle lose its corners (each corner drawn
  twice, so XORed back)? Draws on black, then reads the pixels back.
  And does SetBkColor(1) use palette entry 1 as SetPalette left it? The
  BIOS reads back the EGA/VGA palette registers 0 (the background) and 1. }
program XorRect;
uses Graph, Dos;
var
   Driver, Mode: Integer;
   Corner, Edge, Corner2: Word;
   Before0, Before1, After0, After1, Bk: Word;

function PaletteReg(N: Byte): Byte;
   var
      R: Registers;
   begin
      R.AX := $1007;
      R.BL := N;
      Intr($10, R);
      PaletteReg := R.BH
   end;

begin
   Driver := VGA;
   Mode := VGAHi;
   InitGraph(Driver, Mode, 'C:\TP\BGI');
   if GraphResult <> grOk then
   begin
      WriteLn('InitGraph failed');
      Halt(1)
   end;
   SetWriteMode(XORPut);
   SetColor(15);
   Rectangle(10, 10, 100, 60);
   Corner := GetPixel(10, 10);
   Corner2 := GetPixel(100, 60);
   Edge := GetPixel(50, 10);
   Before0 := PaletteReg(0);
   Before1 := PaletteReg(1);
   SetPalette(1, EGALightRed);
   SetBkColor(1);
   After0 := PaletteReg(0);
   After1 := PaletteReg(1);
   Bk := GetBkColor;
   CloseGraph;
   WriteLn('XOR rectangle: corner (10,10) = ', Corner);
   WriteLn('corner (100,60) = ', Corner2, ', edge (50,10) = ', Edge);
   WriteLn('(15 means the corner is drawn, 0 that it was XORed away)');
   WriteLn('palette regs before: 0 = ', Before0, ', 1 = ', Before1);
   WriteLn('after SetPalette(1, EGALightRed = ', EGALightRed, '), SetBkColor(1):');
   WriteLn('   0 = ', After0, ', 1 = ', After1, ', GetBkColor = ', Bk);
   WriteLn('(reg 0 = ', EGALightRed, ': uses the palette entry; = ', Before1, ': the default colour 1)')
end.
