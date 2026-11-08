{ Q3: s := s + Bump, where Bump changes s: is s read before or after
  Bump runs? 'abX' means before, 'abcX' after. }
program EvalOrd;
var
   S: string;

function Bump: string;
   begin
      S := S + 'c';
      Bump := 'X'
   end;

begin
   S := 'ab';
   S := S + Bump;
   WriteLn('s + Bump: ', S);
   S := 'ab';
   S := Bump + S;
   WriteLn('Bump + s: ', S)
end.
