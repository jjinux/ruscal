{ Constant arithmetic that doesn't fit 32 bits is an error, as in Turbo
  Pascal 7 ("Overflow in arithmetic operation"). }
program ConstOverflow;
const
   Neg = -$80000000;
   Big = MaxLongInt + 1;
   Fine = -$7FFFFFFF - 1;
   AbsMin = Abs(-$7FFFFFFF - 1);
   AfterMax = Succ(MaxLongInt);
   BeforeMin = Pred(-$7FFFFFFF - 1);
var
   L: LongInt;
begin
   WriteLn(-$80000000, Fine);
   L := MaxLongInt + 1;
end.
