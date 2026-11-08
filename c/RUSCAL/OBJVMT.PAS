{ Q8: does an object with a constructor but no virtual methods get the
  2-byte VMT field? 6 means yes, 4 no. }
program ObjVmt;
type
   TPlain = object
      X, Y: Integer;
   end;
   TCtor = object
      X, Y: Integer;
      constructor Init;
   end;
   TVirt = object
      X, Y: Integer;
      constructor Init;
      procedure P; virtual;
   end;
   TDtor = object
      X, Y: Integer;
      destructor Done;
   end;

constructor TCtor.Init;
begin
end;

constructor TVirt.Init;
begin
end;

procedure TVirt.P;
begin
end;

destructor TDtor.Done;
begin
end;

begin
   WriteLn('plain ', SizeOf(TPlain), ' ctor ', SizeOf(TCtor));
   WriteLn('virtual ', SizeOf(TVirt), ' dtor ', SizeOf(TDtor))
end.
