{ After SetBkColor(1), what do GetPalette's entry 0 and the hardware
  register 0 say, and does SetBkColor(0) bring black back? }
program BkPal;
uses Graph, Dos;
var
   Driver, Mode: Integer;
   P: PaletteType;
   A0, A1, B0, C0, C1: Word;
   PalA, PalB: ShortInt;

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
   SetPalette(1, EGALightRed);
   SetBkColor(1);
   A0 := PaletteReg(0);
   GetPalette(P);
   PalA := P.Colors[0];
   SetBkColor(0);
   B0 := PaletteReg(0);
   GetPalette(P);
   PalB := P.Colors[0];
   SetBkColor(2);
   SetPalette(2, EGAYellow);
   C0 := PaletteReg(0);
   C1 := GetBkColor;
   CloseGraph;
   WriteLn('after SetBkColor(1): reg 0 = ', A0, ', GetPalette entry 0 = ', PalA);
   WriteLn('after SetBkColor(0): reg 0 = ', B0, ', GetPalette entry 0 = ', PalB);
   WriteLn('SetBkColor(2) then SetPalette(2, Yellow = ', EGAYellow, '): reg 0 = ', C0, ', GetBkColor = ', C1)
end.
