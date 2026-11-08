program WritelnEmpty;
{ WriteLn('') writes just a line break, so it's pwriteln!() in Rust, not
  pwriteln!(""); the same for a text file. }
begin
   WriteLn('');
   WriteLn('a', '', 'b');
   Write('');
   WriteLn(Output, '');
   WriteLn('end');
end.
