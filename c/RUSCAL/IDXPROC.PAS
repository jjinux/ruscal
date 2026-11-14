{ IDXPROC: an assignment whose value is a procedural variable that the
  index's call changes: TP 7 works the value out first (prints 20). }
program IdxProc;
type
   TFn = function(N: Integer): Integer;
var
   Funcs: array[1..3] of TFn;
   FV: TFn;
   I: Integer;

function Twice(N: Integer): Integer; far;
   begin
      Twice := N * 2;
   end;

function Thrice(N: Integer): Integer; far;
   begin
      Thrice := N * 3;
   end;

function Bump(var N: Integer): Integer;
   begin
      N := N + 1;
      FV := Thrice;
      Bump := N;
   end;

begin
   FV := Twice;
   I := 0;
   Funcs[Bump(I)] := FV;
   WriteLn(Funcs[1](10));
end.
