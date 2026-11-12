{ A constant too big for its type: an integer one (typed constants and
  value arguments too), and a real one too big for a Single. }
{$N+}
program F1;
const
   B: Byte = 300;
   C: Single = 1E39;
   Big = 1E39;
var
   S: Single;

procedure P(X: Single; Y: Byte);
   begin
   end;

begin
   S := 1E39;
   P(1E39, 1);
   P(Big, 300);
end.
