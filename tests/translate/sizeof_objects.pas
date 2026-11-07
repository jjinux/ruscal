{ SizeOf of objects and of records with fields of every kind, written as
  their SERIALIZED_SIZE constants. Expected output by hand, as Free
  Pascal's VMT field is 8 bytes and its Real 8: TBase is X, Y and TP's
  2-byte VMT field (6); TChild adds a 6-byte Real (12); TPlain has no
  VMT (1); Mixed is 6 + 4 + 1 + 1 + 12 + 6 = 30; DateTime is 12. }
program SizeOfObjects;
uses Dos;
type
   TBase = object
      X, Y: Integer;
      constructor Init;
      procedure Draw; virtual;
   end;
   PBase = ^TBase;
   TChild = object(TBase)
      Z: Real;
      procedure Draw; virtual;
   end;
   TPlain = object
      A: Byte;
      procedure P;
   end;
   Color = (Red, Green);
   Mixed = record
      R: Real;
      P: ^Integer;
      S: set of 0..7;
      C: Color;
      When: DateTime;
      Base: TBase;
   end;

constructor TBase.Init;
   begin
      X := 0
   end;

procedure TBase.Draw;
   begin
      WriteLn('base')
   end;

procedure TChild.Draw;
   begin
      WriteLn('child')
   end;

procedure TPlain.P;
   begin
   end;

var
   C: TChild;
   P: PBase;
begin
   New(P, Init);
   P^.Draw;
   WriteLn(SizeOf(TBase), ' ', SizeOf(TChild), ' ', SizeOf(C), ' ', SizeOf(TPlain));
   WriteLn(SizeOf(Mixed), ' ', SizeOf(DateTime))
end.
