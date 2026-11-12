{$N+}
{ A second unit compiled with $N+: its module explains the wrapper too. }
unit NPUnit2;

interface

   procedure Twice(X: Real);

implementation

   procedure Twice(X: Real);
      begin
         WriteLn(2 * X);
      end;

end.
