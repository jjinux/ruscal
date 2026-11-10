{ A procedure nested in one whose name is a Rust keyword (Use is use_)
  is use_inner, not use__inner, which rustc would warn about. }
program NestedKeywordName;
procedure Use(const S: string);
   procedure Inner;
      begin
         WriteLn(S);
      end;
   begin
      Inner;
   end;
begin
   Use('x');
end.
