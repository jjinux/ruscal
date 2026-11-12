{ A program that only calls its unit: nothing in it uses the runtime,
  which must not be a warning (the prelude's `use` is allowed unused). }
program UsesPlain;
uses PlainUnit;
begin
   Hello;
end.
