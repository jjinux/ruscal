{ Constant arithmetic that doesn't fit 32 bits is an error, as in Turbo
  Pascal 7 ("Overflow in arithmetic operation"). }
program ConstOverflow;
const
   Neg = -$80000000;
   Big = MaxLongInt + 1;
   Fine = -$7FFFFFFF - 1;
begin
   WriteLn(-$80000000, Fine);
end.
