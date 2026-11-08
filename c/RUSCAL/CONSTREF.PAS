{ Turbo Pascal passes a const parameter by reference unless it's a scalar,
  a set, or a record, array or object of exactly 1, 2 or 4 bytes; a
  string always. It shows when the routine changes, through a global, the
  variable it was given, or calls a method on the parameter. Expected
  output from Turbo Pascal 7 in DOSBox. (The $F+ directive: TP assigns
  only far routines to a procedural variable.) }
{$F+}
program ConstByReference;
type
   R2 = record
      A: Integer;
   end;
   R4 = record
      A, B: Integer;
   end;
   R6 = record
      A, B, C: Integer;
   end;
   A3 = array[1..3] of Char;
   A4 = array[1..2] of Integer;
   S3 = string[3];
   St = set of 0..15;
   St32 = set of 0..63;
   O2 = object
      A: Integer;
      procedure Bump;
   end;
   O6 = object
      A, B, C: Integer;
      procedure Bump;
   end;
   TShow = procedure(const X: O6);
   TShape = object
      N: Integer;
      Pad: array[1..4] of Integer;
      constructor Init;
      procedure Grow; virtual;
   end;
   TCircle = object(TShape)
      procedure Grow; virtual;
   end;
var
   G2: R2;
   G4: R4;
   G6: R6;
   GA3: A3;
   GA4: A4;
   GS3: S3;
   GSt: St;
   GSt32: St32;
   GO2: O2;
   GO6: O6;
   GR: Real;
   GL: LongInt;
   Show: TShow;
   C: TCircle;

procedure O2.Bump;
   begin
      Inc(A);
   end;

procedure O6.Bump;
   begin
      Inc(A);
   end;

constructor TShape.Init;
   begin
      N := 0;
   end;

procedure TShape.Grow;
   begin
      Inc(N);
   end;

procedure TCircle.Grow;
   begin
      Inc(N, 10);
   end;

{ Each changes the global it's given, then reads the parameter. }
procedure P2(const X: R2);
   begin
      G2.A := 9;
      Write(X.A, ' ');
   end;

procedure P4(const X: R4);
   begin
      G4.A := 9;
      Write(X.A, ' ');
   end;

procedure P6(const X: R6);
   begin
      G6.A := 9;
      Write(X.A, ' ');
   end;

procedure PA3(const X: A3);
   begin
      GA3[1] := 'z';
      Write(X[1], ' ');
   end;

procedure PA4(const X: A4);
   begin
      GA4[1] := 9;
      Write(X[1], ' ');
   end;

procedure PS3(const X: S3);
   begin
      GS3 := 'zz';
      Write(X, ' ');
   end;

procedure PSt(const X: St);
   begin
      GSt := [9];
      Write(9 in X, ' ');
   end;

procedure PSt32(const X: St32);
   begin
      GSt32 := [9];
      Write(9 in X, ' ');
   end;

procedure PR(const X: Real);
   begin
      GR := 9;
      Write(X:0:0, ' ');
   end;

{ A method called on the parameter, then the global read. }
procedure PO2(const X: O2);
   begin
      X.Bump;
      Write(GO2.A, ' ');
   end;

procedure PO6(const X: O6);
   begin
      X.Bump;
      Write(GO6.A, ' ');
   end;

{ The same without a global: a method, passed on, only read. }
procedure Direct(const X: O6);
   begin
      X.Bump;
   end;

procedure Passer(const X: O6);
   begin
      Direct(X);
   end;

procedure Reader(const X: O6);
   begin
      Write(X.A, ' ');
   end;

procedure Sized(const Sh: TShape);
   begin
      Sh.Grow;
   end;

{ A value parameter is always a copy. }
procedure V6(X: R6);
   begin
      G6.A := 7;
      Write(X.A, ' ');
   end;

begin
   G2.A := 1;
   G4.A := 1;
   G6.A := 1;
   GA3[1] := 'a';
   GA4[1] := 1;
   GS3 := 'a';
   GSt := [];
   GSt32 := [];
   GR := 1;
   P2(G2);
   P4(G4);
   P6(G6);
   PA3(GA3);
   PA4(GA4);
   PS3(GS3);
   PSt(GSt);
   PSt32(GSt32);
   PR(GR);
   WriteLn;
   GO2.A := 1;
   GO6.A := 1;
   PO2(GO2);
   PO6(GO6);
   WriteLn;
   GO6.A := 1;
   Direct(GO6);
   Passer(GO6);
   Reader(GO6);
   Show := Reader;
   Show(GO6);
   WriteLn(GO6.A);
   C.Init;
   Sized(C);
   WriteLn(C.N);
   G6.A := 1;
   V6(G6);
   WriteLn(G6.A);
end.
