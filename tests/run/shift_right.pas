program ShiftRight;
{ shr is a logical shift: it fills with zeros, even for negative numbers,
  in the operand's type (16 bits for an Integer), but a constant's in 32
  bits (-300 shr 4 is 268435437). Expected output from Turbo Pascal 7 in
  DOSBox. (Free Pascal computes in 64 bits here.) }
var
   i: integer;
   l: longint;
   s: shortint;
   w: word;
begin
   i := -300;
   l := -300;
   s := -3;
   w := 65236;
   writeln(i shr 4, ' ', l shr 4, ' ', s shr 1, ' ', -300 shr 4);
   writeln(300 shr 4, ' ', w shr 4);
end.
