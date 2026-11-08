{ A const parameter can't be changed, as in Turbo Pascal 7 ("Invalid
  variable reference"): not assigned to, nor its fields or characters,
  nor passed by var, nor read into, nor changed through with. }
program ConstParamAssign;
type
   TRec = record
      X: Integer;
   end;

procedure Change(var N: Integer);
   begin
      N := 1;
   end;

procedure P(const N: Integer; const R: TRec; const S: string);
   begin
      N := 2;
      R.X := 1;
      S[1] := 'x';
      Inc(N);
      Change(N);
      Change(R.X);
      ReadLn(N);
      with R do
         X := 1;
   end;

begin
end.
