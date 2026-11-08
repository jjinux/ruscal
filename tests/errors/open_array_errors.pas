{ What Turbo Pascal 7 doesn't allow with an open array parameter:
  assigning one as a whole, passing one where a fixed-size array is
  wanted, a constant for a var one, an array of another element type, a
  string variable for array of Char. }
program OpenArrayErrors;
type
   TThree = array[1..3] of Integer;
var
   W: array[1..3] of Word;
   S: string;

procedure Fixed(A: TThree);
   begin
   end;

procedure Copy(var A: array of Integer; const B: array of Integer);
   begin
      A := B;
      Fixed(A);
   end;

procedure Twice(var A: array of Integer);
   begin
   end;

procedure Chars(const C: array of Char);
   begin
   end;

begin
   Twice(5);
   Twice(W);
   Chars(S);
end.
