{ A file parameter must be a var parameter, as in Turbo Pascal 7 ("Files
  must be var parameters"). }
program FileParamNotVar;

procedure Put(const F: Text);
   begin
      WriteLn(F, 'x');
   end;

procedure Copy(F: file of Integer);
   begin
   end;

begin
end.
