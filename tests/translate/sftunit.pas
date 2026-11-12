{ A unit compiled without $N+: its reals print the software way, even
  in an $N+ program (npmix2.pas), as in Turbo Pascal 7. }
unit SftUnit;

interface

   procedure ShowSoft(X: Real);

implementation

   procedure ShowSoft(X: Real);
      var
         S: string;
      begin
         Str(X:12, S);
         WriteLn(X, '|', S, '|', Round(2.5));
      end;

end.
