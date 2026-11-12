{ A constant too big for its type: an integer one (typed constants too),
  and a real one too big for a Single. }
{$N+}
program F1;
const
   B: Byte = 300;
   C: Single = 1E39;
var
   S: Single;
begin
   S := 1E39;
end.
