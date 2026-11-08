{ A const parameter Turbo Pascal passes by reference is a reference in
  Rust, so it can't share a variable with a var argument (or the object
  a method is called on), nor with a global the routine changes when the
  calls pass different variables. Copy one into a local first. }
program ConstRefAliases;
type
   TBig = record
      A, B, C: Integer;
   end;
   TThing = object
      A, B, C: Integer;
      procedure CopyFrom(const Other: TThing);
   end;
var
   Name: string;
   Big, Other: TBig;
   Thing: TThing;

procedure TThing.CopyFrom(const Other: TThing);
   begin
      A := Other.A;
   end;

procedure Both(const S: string; var T: string);
   begin
      T := S;
   end;

procedure Reset(const X: TBig);
   begin
      Big.A := 0;
      WriteLn(X.A);
   end;

begin
   Both(Name, Name);
   Reset(Big);
   Reset(Other);
   Thing.CopyFrom(Thing);
end.
