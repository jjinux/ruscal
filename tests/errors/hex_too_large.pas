{ A hexadecimal constant is at most $FFFFFFFF, as in Turbo Pascal 7
  ("Error in integer constant"). }
program HexTooLarge;
begin
   WriteLn($100000000);
end.
