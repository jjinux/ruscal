program UntypedCasts;
{ Writes through a typecast of an untyped parameter: an element of a Word
  array, a record's field, Inc of one, and a string[5] as a whole (which
  takes 6 bytes, not a full string's 256), and one passed on to a var
  parameter, whole or a field (two in one statement too), or to Val or
  Str. Output from fpc -Mtp. }
type
   TWords = array[0..127] of Word;
   Rec = record a, b: Word; end;
   TName = string[5];
   NRec = record name: TName; n: Integer; end;
var
   r: Rec;
   nr: NRec;
   w, x, y: Word;
procedure SetWords(var Data);
   begin
      TWords(Data)[0] := 1;
      TWords(Data)[1] := 2;
   end;
procedure SetField(var Data);
   begin
      Rec(Data).b := 77;
      Inc(Rec(Data).a, 10);
   end;
procedure SetName(var Data; const s: string);
   begin
      TName(Data) := s;
   end;
procedure Add1(var n: Word);
   begin
      n := n + 1;
   end;
procedure Bump(var Data);
   begin
      Add1(Word(Data));
      Add1(Rec(Data).b);
   end;
function Next(var n: Word): Word;
   begin
      n := n + 1;
      Next := n;
   end;
procedure BumpBoth(var a; var b; var Sum: Word);
   begin
      Sum := Next(Word(a)) + Next(Word(b));
   end;
procedure Parse(var Data; const s: string);
   var
      Code: Integer;
   begin
      Val(s, Word(Data), Code);
   end;
procedure Show(var Data; n: Integer);
   begin
      Str(n, TName(Data));
   end;
begin
   r.a := 0; r.b := 0;
   SetWords(r);
   WriteLn(r.a, ' ', r.b);
   SetField(r);
   WriteLn(r.a, ' ', r.b);
   nr.name := 'abc'; nr.n := 258;
   SetName(nr, 'xy');
   WriteLn(nr.name, ' ', nr.n);
   Bump(r);
   WriteLn(r.a, ' ', r.b);
   x := 1; y := 2;
   BumpBoth(x, y, w);
   WriteLn(w, ' ', x, ' ', y);
   Parse(r.a, '77');
   Show(nr, 123);
   WriteLn(r.a, ' ', nr.name, ' ', nr.n);
end.
