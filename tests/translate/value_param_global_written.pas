program ValueParamGlobalWritten;
{ A value parameter given a global that the routine also changes: the
  parameter is a copy, made before the call (the Rust passes the global
  by &mut first, so the copy goes in a let). }
type
   R6 = record
      A, B, C: Integer;
   end;
var
   G6: R6;

procedure V(X: R6);
   begin
      G6.A := 7;
      WriteLn(X.A, ' ', G6.A);
   end;

begin
   G6.A := 1;
   V(G6);
end.
