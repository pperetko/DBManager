unit Compare;

interface
uses Classes,SysUtils, PgDacVcl,pgAccess,stdCtrls;
Type


 TType=class
 public
   Name:string;
   typ:string;
   length:integer;
 end;



 TCompareDB=class(TObject)
 private

   connection_1:TPgConnection;
   connection_2:TPgConnection;
   function GetStructureTable(table_name, table_schema:string;Conn:TPgConnection):TStringlist;

 public
   constructor myCreate(conn1,conn2 :TPgConnection);
   procedure CompareDB(query1:TPgQuery; var mm:TMemo;settings:byte);
   class function IntToBinByte(Value: Byte): string;



 end;



implementation

{ TCompareDB }

procedure TCompareDB.CompareDB(query1:TPgQuery; var mm:TMemo;settings:byte);
var
  i, j:integer;
  table_name:string;
  schema:string;

  list1 :TStringList;
  list2 :TStringList;

  obj1:TType;
  obj2:TType;

  sett:string;
begin

  sett:= IntToBinByte(settings);
  query1.First;
  for i:=0 to query1.RecordCount-1 do begin
    table_name:= query1.FieldByName('table_name').AsString;
    schema:= query1.FieldByName('table_schema').AsString;
    list1:= GetStructureTable(table_name,schema,connection_1);

    list2:= GetStructureTable(table_name,schema,connection_2);
    mm.Lines.Add('');
    mm.Lines.Add('--------'+schema+'.'+table_name+'--------');
    mm.Lines.Add('');

    if pos('1',sett,length(sett)) > 0 then
    begin
      //No fields
      for j := 0 to list1.Count-1 do
      begin
        obj1:= TType(list1.Objects[j]);
        if Assigned(obj1) then
        begin
          if list2.IndexOfName(obj1.Name)= -1 then
          begin
            mm.Lines.Add(schema+'.'+table_name+'      No field- db 1:'+obj1.Name);
          end;
        end;
      end;
      //Adding fields

      for j := 0 to list2.Count-1 do
      begin
        obj2:= TType(list2.Objects[j]);
        if Assigned(obj2) then
        begin
          if list1.IndexOfName(obj2.Name)= -1 then
          begin
            mm.Lines.Add(schema+'.'+table_name+'      add field- db 2:'+obj2.Name);
          end;
        end;
      end;
    end;
    query1.next;
  end;


  for i:=list1.Count-1  downto 0 do
  begin
    if Assigned(list1.Objects[i]) then
      list1.Objects[i].Free;

  end;
  list1.Clear;
  list1.Free;

  for i:=list2.Count-1  downto 0 do
  begin
    if Assigned(list2.Objects[i]) then
      list2.Objects[i].Free;

  end;
  list2.Clear;
  list2.Free;
end;

function TCompareDB.GetStructureTable(table_name, table_schema: string;Conn:TPgConnection): TStringlist;
var
  query:string;
  qtmp:TPgQuery;
  i:integer;
  obj:TType;
begin
  result:=TStringList.Create;
  query:= ' SELECT Distinct column_name,data_type,character_maximum_length '+
              ' FROM information_schema.columns '+
              ' WHERE table_schema = :schema '+
              ' AND table_name   = :table ';
  qtmp:= TPgQuery.Create(nil);
  qtmp.Connection:= Conn;
  qtmp.SQL.Text:= query;
  qtmp.ParamByName('table').AsString:=table_name;
  qtmp.ParamByName('schema').AsString:=table_schema;
  qtmp.Open;
  for I := 0 to qtmp.RecordCount-1 do
  begin
    obj := TType.Create;
    obj.Name:=qtmp.FieldByName('column_name').AsString;
    obj.typ:=qtmp.FieldByName('data_type').AsString;
    obj.length:= qtmp.FieldByName('character_maximum_length').AsInteger;
    result.AddObject(qtmp.FieldByName('column_name').AsString,obj);
    qtmp.next;
  end;
  qtmp.Close;
  qtmp.Free;
end;

class function TCompareDB.IntToBinByte(Value: Byte): string;
var
  i: Integer;
begin
  SetLength(Result, 8);
  for i := 1 to 8 do begin
    if (Value shl (i-1) and $ff) shr 7 = 0 then begin
      Result[i] := '0'
    end else begin
      Result[i] := '1';
    end;
  end;
end;

constructor TCompareDB.myCreate(conn1,conn2 :TPgConnection);
begin
  inherited;
  connection_1:= conn1;
  connection_2:= conn2;
end;

end.
