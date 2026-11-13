{ A single value for an open array parameter, taken as a one-element
  array: TP 7 and fpc -Mtp refused it, so this output is written by
  hand. A computed value must be parenthesized in the Rust (&(i + 1)). }
program OpenArraySingle;
const
   Neg = -5;
var
   I: Integer;

procedure ShowB(const A: array of Byte);
   begin
      WriteLn(High(A), ' ', A[0]);
   end;

procedure ShowI(A: array of Integer);
   begin
      WriteLn(High(A), ' ', A[0]);
   end;

procedure ShowL(A: array of LongInt);
   begin
      WriteLn(High(A), ' ', A[0]);
   end;

begin
   I := 300;
   ShowB(255);
   ShowB(2 + 3);
   ShowI(Neg * 2);
   ShowI(I + 1);
   ShowL(-2147483647 - 1);
   ShowL(I);
end.
