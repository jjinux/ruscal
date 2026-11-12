{$N+}
{ A unit compiled with $N+: its reals print the 8087's way, whatever
  the program's setting (npmix.pas), as in Turbo Pascal 7. }
unit NPUnit;

interface

   procedure Show(X: Real);

implementation

   procedure Show(X: Real);
      var
         S: string;
      begin
         Str(X, S);
         WriteLn(X, '|', X:12, '|', S, '|', X:0:3, '|', Round(2.5));
      end;

end.
