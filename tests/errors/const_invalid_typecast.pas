{ A constant can't typecast a Real or a string to an ordinal type, as in
  Turbo Pascal 7 ("Invalid type cast"). }
program ConstInvalidTypecast;
const
   A = Integer(1.5);
   B = Byte('ab');
   C = 2 * Word(0.5);
begin
end.
