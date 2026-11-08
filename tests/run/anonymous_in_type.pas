program AnonymousInType;
{ A record written inside a type declaration (here an array's elements)
  is named after the type, AnonymousTList, like one in a field or a
  variable. }
type
   TList = array[1..2] of record
      Z: Integer;
      end;
      var
      L: TList;
      begin
      L[1].Z := 3;
      WriteLn(L[1].Z);
      end.
