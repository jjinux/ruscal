{ A const parameter Turbo Pascal passes by reference, in a routine that
  changes the global some calls pass: other calls pass values, so the
  parameter can't stand for the global; copy it into a local first. }
program ConstRefLiteralGlobal;
var
   Name: string;

function MakeName: string;
   begin
      MakeName := 'made';
   end;

procedure Show(const S: string);
   begin
      Name := Name + '.';
      WriteLn(S);
   end;

begin
   Name := 'n';
   Show(Name);
   Show(MakeName);
   Show(Name + '!');
   Show('lit');
   WriteLn(Name);
end.
