program AliasSameName;
{ Bump's parameter G hides the global G, and every call passes the global
  itself; Show, which Bump calls, uses the global. The Rust passes Show
  the parameter, and Bump's doc comment says why. }
var
   G: Integer;

procedure Show;
   begin
      WriteLn(G);
   end;

procedure Bump(var G: Integer);
   begin
      Inc(G);
      Show;
   end;

begin
   G := 1;
   Bump(G);
end.
