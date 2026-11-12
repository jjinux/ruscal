{ A function whose result is set only by its last statement: in the Rust
  the function ends with that value, with no `result` variable. }
program FunctionTail;
type
   Short = string[5];
var
   I: Integer;

function Twice(N: Integer): Integer;
   begin
      Twice := N * 2;
   end;

function Bigger(A, B: Integer): Integer;
   begin
      if A > B then
         I := A
      else
         I := B;
      Bigger := I; { the bigger one }
   end;

function Clip(S: string): Short;
   begin
      Clip := S;
   end;

{$Q+}
function Checked(N: Integer): Integer;
   begin
      Checked := N + 1;
   end;
{$Q-}

function Outer(N: Integer): Integer;

   function Inner: Integer;
      begin
         Inner := N + 10;
      end;

   begin
      Outer := Inner * 2;
   end;

{ Set in two places, or left by Exit: these keep their result variable. }
function Sign(N: Integer): Integer;
   begin
      Sign := 0;
      if N > 0 then
         Exit;
      Sign := -1;
   end;

function Digits(N: Integer): Integer;
   begin
      Digits := 1;
      while N > 9 do
      begin
         Digits := Digits(N div 10) + 1;
         N := 0;
      end;
   end;

begin
   WriteLn(Twice(21), ' ', Bigger(3, 7), ' ', Clip('abcdefgh'), ' ', Checked(41));
   WriteLn(Outer(1), ' ', Sign(5), ' ', Sign(-5), ' ', Digits(12345));
end.
