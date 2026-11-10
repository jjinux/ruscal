program ReadableBits;
{ Small readability points: a hex constant stays hex (0xFF00), an open
  array's High for a Byte loop is one cast (a.high() as u8), and a const
  string parameter, held as &PString, is used as it is where a reference
  does: printed, with a width, searched, compared, moved, Val'd. }
const
   Mask = $FF00;
   Back = -$10;
var
   Buf: array[1..4] of Char;
   Nums: array[1..3] of Integer;
   N, Code: Integer;

procedure ShowAll(const A: array of Integer);
   var
      B: Byte;
   begin
      for B := 0 to High(A) do
         Write(A[B], ' ');
      WriteLn;
   end;

procedure Use(const S: string);
   begin
      WriteLn(S, '|', S:8, '|', Pos('l', S));
      if S = 'hello' then
         WriteLn('equal');
      Move(S[1], Buf, 4);
      Val(S, N, Code);
      WriteLn(Buf[1], Buf[4], ' ', Code);
   end;

begin
   WriteLn(Mask and $0F00, ' ', $10, ' ', Back);
   Nums[1] := 1;
   Nums[2] := 2;
   Nums[3] := 3;
   ShowAll(Nums);
   Use('hello');
end.
