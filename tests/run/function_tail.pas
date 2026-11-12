{ A function whose result is set only by its last statement: in the Rust
  the function ends with that value, with no `result` variable. (Expected
  output by hand: fpc finds tests/run/strings.pas for the Strings unit.) }
program FunctionTail;
uses Strings;
type
   Short = string[5];
var
   I: Integer;
   Buf: array[0..9] of Char;

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

{ Comments after the last statement, with a ; or a // in them. }
function A(X: Integer): Integer;
   begin
      A := X + 1; { see note; }
   end;

function B(X: Integer): Integer;
   begin
      B := X + 2; { first; // second }
   end;

function S: Short;
   begin
      S := 'a; // b'; { c; }
   end;

{ A PChar lent for the statement and copied back after it: the result
  keeps its variable, declared with the other locals. }
function Upper: Integer;
   begin
      I := I + 1;
      Upper := StrLen(StrUpper(Buf));
   end;

{ A last statement that never runs: it stays commented out. }
function Loop: Integer;
   begin
      repeat
         Halt(0);
      until False;
      Loop := 1;
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
   StrCopy(Buf, 'abc');
   WriteLn(A(1), ' ', B(1), ' ', S, ' ', Upper, ' ', Buf);
   WriteLn(Loop);
end.
