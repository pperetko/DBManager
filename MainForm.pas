unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Data.DB, MemDS, DBAccess,
  PgAccess, Vcl.StdCtrls,Data.SqlTimSt, Vcl.ExtCtrls, DAScript, PgScript, PgDacVcl, Vcl.CheckLst;

type
  TForm_main = class(TForm)
    PgConnection_main: TPgConnection;
    PgQuery_main: TPgQuery;
    pc_main: TPageControl;
    ts_import: TTabSheet;
    ts_export: TTabSheet;
    ts_connection: TTabSheet;
    Edit_Host: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit_pass: TEdit;
    Label3: TLabel;
    cb_db: TComboBox;
    btn_getDb: TButton;
    Bt_connect: TButton;
    Edit_user: TEdit;
    Label4: TLabel;
    bt_getTables: TButton;
    ListView_Tables: TListView;
    bt_Checked: TButton;
    bt_unchecked: TButton;
    bt_export: TButton;
    q_tmp: TPgQuery;
    q_sub: TPgQuery;
    bt_save_as: TButton;
    pl_bottom: TPanel;
    edt_table_name: TEdit;
    pb_all: TProgressBar;
    pb_sub: TProgressBar;
    ts_log: TTabSheet;
    mm_log: TMemo;
    edt_schema: TEdit;
    cb_export_cancel: TCheckBox;
    btn_get_scripts: TButton;
    btn_import: TButton;
    cb_truncate_tables: TCheckBox;
    btn_import_checked: TButton;
    btn_import_unchecked: TButton;
    LV_import: TListView;
    PgScript1: TPgScript;
    btn_disconect: TButton;
    lbl_save_As: TLabel;
    ts_compare: TTabSheet;
    btn_compare_conn_1: TButton;
    btn_compare_conn_2: TButton;
    rg_compare_db: TRadioGroup;
    mm_compare: TMemo;
    PgConnection1: TPgConnection;
    PgConnection2: TPgConnection;
    PgConnectDialog1: TPgConnectDialog;
    PgConnectDialog2: TPgConnectDialog;
    btn_start: TButton;
    clb_compare_settings: TCheckListBox;
    q_compare_table1: TPgQuery;
    edt_schema_2: TEdit;
    SaveDialog1: TSaveDialog;
    btn_save_as: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btn_getDbClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Bt_connectClick(Sender: TObject);
    procedure bt_getTablesClick(Sender: TObject);
    procedure bt_CheckedClick(Sender: TObject);
    procedure bt_uncheckedClick(Sender: TObject);
    procedure bt_exportClick(Sender: TObject);
    procedure bt_save_asClick(Sender: TObject);
    procedure cb_export_cancelClick(Sender: TObject);
    procedure btn_import_checkedClick(Sender: TObject);
    procedure btn_import_uncheckedClick(Sender: TObject);
    procedure btn_get_scriptsClick(Sender: TObject);
    procedure btn_importClick(Sender: TObject);
    procedure btn_disconectClick(Sender: TObject);
    procedure btn_compare_conn_1Click(Sender: TObject);
    procedure btn_compare_conn_2Click(Sender: TObject);
    procedure btn_startClick(Sender: TObject);
    procedure pc_mainChange(Sender: TObject);
    procedure btn_save_asClick(Sender: TObject);
  private
    FSelectdir:string;
    Fbreak:boolean;
    procedure GetDataBaseNames;
    procedure ShowTabs(aShow:boolean);
    function TruncateTable(aname:string;aschema:string):boolean;
    function SetTrigeresEnabled(Aenabled:boolean; aschema, atablename:string):boolean;
  public
    function GetInsertLines(Aschema, aTableName:string):boolean;
    function GetKeyName(Aschema,AtableName:string):string;
  end;

var
  Form_main: TForm_main;

implementation
uses fileCtrl, Compare;
{$R *.dfm}

procedure TForm_main.btn_disconectClick(Sender: TObject);
begin
  if PgConnection_main.Connected then
  begin
    PgConnection_main.Disconnect;
    self.caption := emptystr;
  end;
end;

procedure TForm_main.btn_getDbClick(Sender: TObject);
begin
  if ((trim(Edit_Host.Text)<>'') and (trim(Edit_pass.Text)<>'')) then
  begin
    PgConnection_main.Username:='Postgres';
    PgConnection_main.Server:= Edit_Host.Text;
    PgConnection_main.Password:= Edit_pass.Text;
    PgConnection_main.Username:= Edit_user.Text;
    PgConnection_main.Connect;
    if PgConnection_main.Connected then
    begin
      GetDataBaseNames;
      PgConnection_main.Disconnect;
    end;
  end;
end;

procedure TForm_main.bt_CheckedClick(Sender: TObject);
var
  i:integer;
begin
  for I :=0 to ListView_Tables.Items.Count-1 do
  begin
    ListView_Tables.Items[i].Checked:=true;
  end;
end;

procedure TForm_main.Bt_connectClick(Sender: TObject);
begin
 if ((Trim(Edit_Host.Text)<>'')  and (trim(Edit_pass.Text)<>'')  and
    (trim(Edit_user.Text)<>'') and (cb_db.ItemIndex<>-1)) then
 begin
    PgConnection_main.Database:= cb_db.Text;
    PgConnection_main.Connect;
    if PgConnection_main.Connected then
    begin
      Self.Caption:= Edit_Host.Text +' '+Edit_user.Text+' ' +cb_db.Text;
      ShowTabs(true);
    end else begin
      Self.Caption:='Wrong connection parametres';
    end;
 end else begin
   ShowMessage('Fill manadatory fields');
 end;
end;

procedure TForm_main.bt_exportClick(Sender: TObject);
var
  i:integer;
  list:TStringList;
  shema_name:string;
  table_name:string;
  item:TListItem;
  res:boolean;
begin

  if trim(FSelectdir)='' then
  begin
    ShowMessage('The export path is empty');
    if bt_save_as.CanFocus then
       bt_save_as.SetFocus;
    exit;
  end;

  pb_all.Position:=0;
  pb_all.Min:=0;
  pb_all.Max:=ListView_Tables.Items.Count;
  pb_all.Step:=1;

  for I := 0 to ListView_Tables.Items.Count-1 do
  begin
    item:=  ListView_Tables.Items[i];
    pb_all.Position:= pb_all.Position+1;
    pb_all.Update;
    edt_table_name.Text:= item.SubItems[1];;
    edt_table_name.Update;

    if item.Checked then
    begin
      shema_name:= item.SubItems[0];
      table_name:= item.SubItems[1];
      res:= GetInsertLines(shema_name, table_name);
      if not res then
      begin
        ShowMessage('Export faiiled: '+shema_name+'.'+table_name );
        mm_log.Lines.Add('Export faiiled: '+shema_name+'.'+table_name);
        break;
      end;
    end;
  end;
  pb_all.Position:=0;
  pb_sub.Position:=0;
end;

procedure TForm_main.bt_getTablesClick(Sender: TObject);
var
 i:integer;
 item:TListItem;

begin
  if Trim(edt_schema.Text)='schema' then
  begin
    PgQuery_main.SQL.Text:= 'SELECT table_schema,table_name '+
                            'FROM information_schema.tables '+
                            'where table_schema '+
                            'not in (''pg_catalog'',''information_schema'')'+
                            'ORDER BY table_schema,table_name; ';
  end else  begin
    PgQuery_main.SQL.Text:= 'SELECT table_schema,table_name '+
                            'FROM information_schema.tables '+
                            'where table_schema '+
                            'not in (''pg_catalog'',''information_schema'') '+
                            'and table_schema = '+ QuotedStr(edt_schema.text) +
                            ' ORDER BY table_schema,table_name; ';


  end;

  PgQuery_main.Close;
  PgQuery_main.Open;
  ListView_Tables.Clear;
  for i:=0  to PgQuery_main.RecordCount-1 do
  begin
    item:= ListView_Tables.Items.Add;
    item.Checked:=true;

    item.SubItems.Add(PgQuery_main.FieldByName('table_schema').AsString);
    item.SubItems.Add(PgQuery_main.FieldByName('table_name').AsString);
    PgQuery_main.Next;
  end;
end;

procedure TForm_main.bt_save_asClick(Sender: TObject);
var
  SelectDir:string;
begin
 if SelectDirectory('Select directory','c:\',SelectDir) then
 begin
   FSelectdir:= SelectDir;
   lbl_save_As.Caption:= SelectDir;
 end;
end;

procedure TForm_main.bt_uncheckedClick(Sender: TObject);
var
  i:integer;
begin
  for I :=0 to ListView_Tables.Items.Count-1 do
  begin
    ListView_Tables.Items[i].Checked:=false;
  end;
end;


procedure TForm_main.cb_export_cancelClick(Sender: TObject);
begin
  Fbreak:= cb_export_cancel.Checked;
end;

procedure TForm_main.FormActivate(Sender: TObject);
begin
  Edit_Host.SetFocus;
end;

procedure TForm_main.FormCreate(Sender: TObject);
var
  i:integer;
begin
  pc_main.ActivePage:= ts_connection;
  Edit_user.Text:='postgres';
  ShowTabs(false);
  Fbreak:=false;
  for i:= 0 to clb_compare_settings.Count-1 do
    clb_compare_settings.Checked[i]:=true;
end;

procedure TForm_main.GetDataBaseNames;
var
  i: integer;
begin
  PgQuery_main.SQL.Text:= 'SELECT datname FROM pg_database WHERE datistemplate = false;';
  PgQuery_main.Open;
  cb_db.Clear;
  for i:=0  to PgQuery_main.RecordCount-1 do
  begin
    cb_db.Items.Add(PgQuery_main.FieldByName('datname').AsString);
    PgQuery_main.Next;
  end;
end;

function TForm_main.GetInsertLines(ASchema, aTableName: string): boolean;
var
  query:string;
  row_string : string;
  row_params : UTF8String;// string;
  row_select : string;
  key_name   :string;
  i,j,a :integer;
  row:string;
  field_name:string;
  file_end:TFileStream;
  FS : TFormatSettings;
  //--------------------- Array to string --------------------------------------
  function ArrayToString(aarray:string):string;
  begin
   result:='';
   if trim(aarray)='' then
     result:='{}'
   else result:=aarray;
  end;
  //------------------- Empty is null ------------------------------------------
  function EmptyIsNull(Avalue:string):string;
  begin
    result:='NULL';
    if (trim(Avalue)<>'') and (trim(Avalue)<>QuotedStr('')) then
      result:= Avalue;
  end;
  //-------------------Boolean -------------------------------------------------
  function booleanToString(avalue:boolean):string;
  begin
    if avalue then
      result:=QuotedStr('t')
    else
      result:=QuotedStr('f');
  end;
  //----------------------------------------------------------------------------
  //Those columns not exports
  function IsColumnNameForReserwerWords(Aname:string):boolean;
  var
   reserved_words:string;
  begin
   result:=false;
   reserved_words:='CLASS';
   if pos(AnsiUpperCase(aname), reserved_words)<>0 then
   begin
     result:=true;
   end;
  end;
 //-----------------------------------------------------------------------------
 //Those data type not exports
 function isDataTypeNotExports(atype:string):boolean;
 var
   types:string;
 begin
   result:=false;
   types:='OID BYTEA REFCURSOR';
   if pos(AnsiUpperCase(atype), types)<>0 then
   begin
     result:=true;
   end;
 end;
 //-----------------------------------------------------------------------------
begin
  result:=true;
  GetLocaleFormatSettings(1045, FS);

  try
    try
      PgConnection_main.StartTransaction;
      mm_log.Lines.Add('Add: '+ aTableName );


      query:= ' SELECT Distinct column_name,data_type '+
              ' FROM information_schema.columns '+
              ' WHERE table_schema = :schema '+
              ' AND table_name   = :table ';

      PgQuery_main.SQL.Text:= query;
      PgQuery_main.ParamByName('schema').AsString:= Aschema;
      PgQuery_main.ParamByName('table').AsString:= aTableName;
      PgQuery_main.Open;




      a:=0;
      for i:=0 to PgQuery_main.RecordCount-1 do
      begin
        if Fbreak then
        begin
          PgConnection_main.Rollback;
          break;
        end;
        if a=0 then
        begin
          if
          (not  isDataTypeNotExports(PgQuery_main.FieldByName('data_type').AsString)) then
          begin
            if (not IsColumnNameForReserwerWords(PgQuery_main.FieldByName('column_name').AsString)) then
            begin
              row_string := PgQuery_main.FieldByName('column_name').AsString;
              row_select:=  PgQuery_main.FieldByName('column_name').AsString;
            end else begin
              row_string := '"'+PgQuery_main.FieldByName('column_name').AsString+'"';
              row_select:= '"'+PgQuery_main.FieldByName('column_name').AsString+'"';
            end;
          end else begin
             mm_log.Lines.Add('Table: '+ aTableName + 'Exclude column:' + PgQuery_main.FieldByName('column_name').AsString
              +' Or '+
              'Type: ' + PgQuery_main.FieldByName('data_type').AsString) ;
            dec(a);
          end;
        end else begin
          if  (not  isDataTypeNotExports(PgQuery_main.FieldByName('data_type').AsString)) then
          begin
            if (not IsColumnNameForReserwerWords(PgQuery_main.FieldByName('column_name').AsString)) then
            begin
              row_string := row_string+','+ PgQuery_main.FieldByName('column_name').AsString;
              row_Select := row_Select+','+ PgQuery_main.FieldByName('column_name').AsString;
            end else begin
              row_string := row_string+','+'"'+ PgQuery_main.FieldByName('column_name').AsString+'"';
              row_Select := row_Select+','+'"'+ PgQuery_main.FieldByName('column_name').AsString+'"';
            end;
          end else begin
            mm_log.Lines.Add('Table: '+ aTableName + 'Exclude column:' + PgQuery_main.FieldByName('column_name').AsString
             + ' Or '+
              'Type: ' + PgQuery_main.FieldByName('data_type').AsString) ;
          end;
        end;
        inc(a);
        PgQuery_main.next;
      end;

      row_string:= ' INSERT INTO '+Aschema+'.'+aTableName +'(' + row_string+') ';

      row_select:= ' SELECT '+ row_select;

      key_name:= GetKeyName(Aschema,aTableName);
      if Trim(key_name)<>'' then
        row_select := row_select +' FROM '+Aschema+'.'+aTableName +' order by '+ key_name
      else
        row_select := row_select +' FROM '+Aschema+'.'+aTableName;
      //----------------------pobieranie danych do skryptu
      PgQuery_main.First;
      q_sub.SQL.Text :=row_select;
      q_sub.Open;

      pb_sub.Max:= q_sub.RecordCount;
      if q_sub.RecordCount>0 then
      begin
        file_end:= TFileStream.Create(IncludeTrailingBackslash( FSelectdir)+ aTableName+'.'+Aschema,fmCreate);
      end;
      pb_sub.Step:=1;
      pb_sub.Min:=0;
      pb_sub.Position:=0;

      for I := 0 to q_sub.RecordCount-1 do begin
        row_params:= EmptyStr;
        if Fbreak then
        begin
          PgConnection_main.Rollback;
          break;
        end;

        pb_sub.Position:= pb_sub.Position+1;
        self.Update;
        Application.ProcessMessages;

        for j:=0 to q_sub.Fields.Count-1 do begin
          field_name:= q_sub.Fields[j].FieldName;
          PgQuery_main.Locate('column_name', field_name,[]);
          //VARCHAR
          if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'CHARACTER VARYING'
          then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //BIGINT    INTEGER
          else if ( AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'BIGINT') or
                          ( AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'INTEGER') then
          begin
            if trim(row_params)='' then row_params:= EmptyIsNull(q_sub.Fields[j].AsString)
                                 else  row_params:=row_params +','+ EmptyIsNull(q_sub.Fields[j].AsString);
          //SMALLINT
          end else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'SMALLINT' then
          begin
            if trim(row_params)='' then row_params:= EmptyIsNull(q_sub.Fields[j].AsString)
                                 else  row_params:=row_params +','+ EmptyIsNull(q_sub.Fields[j].AsString);
          //BOOLEAN
          end else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'BOOLEAN' then
          begin
            if trim(row_params)='' then row_params:= booleanToString(q_sub.Fields[j].AsBoolean)
                                 else  row_params:=row_params +','+ booleanToString(q_sub.Fields[j].AsBoolean);
          //TIMESTAMP with time zone
          end else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'TIMESTAMP WITH TIME ZONE' then
          begin
            if q_sub.Fields[j].IsNull=false then
            begin
              if trim(row_params)='' then row_params:= QuotedStr(DateTimeToStr(q_sub.Fields[j].AsDateTime,FS))
                                 else  row_params:=row_params +',' + QuotedStr(DateTimeToStr(q_sub.Fields[j].AsDateTime,FS));
              end else begin
                 if trim(row_params)='' then row_params:= 'NULL'
                                 else  row_params:=row_params +',NULL';
              end;
          //ARRAY
          end else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'ARRAY' then
          begin
            if trim(row_params)='' then row_params:= ArrayToString(q_sub.Fields[j].AsString)
                                 else  row_params:=row_params +','+ ArrayToString(q_sub.Fields[j].AsString);
          end
          //Bit
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'BIT' then begin
            if trim(row_params)='' then row_params:=EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //Bit varing
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'BIT VARYING' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //Box
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'BOX' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));

          end
          //Char
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'CHARACTER' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //CIDR
          else if AnsiUpperCase( PgQuery_main.FieldByName('data_type').AsString) = 'CIDR' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));

          end
          //CIRCE
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'CIRCLE' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));

          end
          //double precision
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'DOUBLE PRECISION' then begin
            if trim(row_params)='' then row_params:= q_sub.Fields[j].AsString
                                 else  row_params:=row_params +','+ q_sub.Fields[j].AsString;

          end
          //inet
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'INET' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //INTERVAL
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'INTERVAL' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //JSON
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'JSON' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
         //JSONB
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'JSONB' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
         //LINE
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'LINE' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //LSEG
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'LSEG' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          // MACADDR
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'MACADDR' then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //MONEY  NUMERIC  REAL
          else if ((AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'MONEY') or
                  (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'NUMERIC') or
                  (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'REAL'))

            then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(q_sub.Fields[j].AsString )
                                 else  row_params:=row_params +','+ EmptyIsNull(q_sub.Fields[j].AsString);
          end
          //PATH   POINT  POLYGON   TEXT   tsquery  uuid tsvector
          else if (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'PATH') or
                   (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'POINT') or
                   (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'POLYGON') or
                   (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'TEXT') or
                   (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'TSQUERY') or
                   (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'UUID') or
                   (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'XML') or
                   (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'TSVECTOR')

                        then begin
            if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr(q_sub.Fields[j].AsString));
          end
          //Time without time zone
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'TIME WITHOUT TIME ZONE' then begin
            if q_sub.Fields[j].IsNull=false then begin
              if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr( TimeToStr(q_sub.Fields[j].AsDateTime)))
                                 else  row_params:=row_params +','+ EmptyIsNull(QuotedStr( TimeToStr(q_sub.Fields[j].AsDateTime)));
            end else begin
              if trim(row_params)='' then row_params:= 'NULL'
                                 else  row_params:=row_params +',NULL';
            end;
          end
          //time with time zone
          else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'TIME WITH TIME ZONE' then begin
            if q_sub.Fields[j].IsNull=false then
            begin
              if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(TimeToStr(q_sub.Fields[j].AsDateTime)))
                                 else  row_params:=row_params +','+
                                 EmptyIsNull(QuotedStr(TimeToStr(q_sub.Fields[j].AsDateTime)));
            end else begin
              if trim(row_params)='' then row_params:= 'NULL'
                                 else  row_params:=row_params +',NULL';
            end;
          end
          //refcursor
           else if AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'REFCURSOR' then begin
            if trim(row_params)='' then row_params:= 'NULL'
                                 else  row_params:=row_params +',NULL';
          end
          //Timestamp without time zone
          else if ((AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) = 'TIMESTAMP WITHOUT TIME ZONE') or
                  (AnsiUpperCase(PgQuery_main.FieldByName('data_type').AsString) ='TIMESTAMP'))    then begin
             if q_sub.Fields[j].IsNull=false then
             begin
               if trim(row_params)='' then row_params:= EmptyIsNull(QuotedStr(DateTimeToStr(q_sub.Fields[j].AsDateTime,FS)))

                                 else  row_params:=row_params +',' + EmptyIsNull(QuotedStr( DateTimeToStr(q_sub.Fields[j].AsDateTime,FS)));
             end else begin
               if trim(row_params)='' then row_params:= 'NULL'
                                 else  row_params:=row_params +',NULL';
             end;
          end

        end;
        row_params:= ' VALUES(' + row_params+');';
        row_params:= row_string +row_params+#13#10;
        file_end.WriteBuffer(row_params[1], Length(row_params) * SizeOf(row_params[1]));
        q_sub.Next;
      end;
     // if Assigned(file_end) then
     // begin
     //   row_params:='END;';
     //   file_end.WriteBuffer(row_params[1], Length(row_params) * SizeOf(row_params[1]));
     // end;
    except
       on E: EDatabaseError do
       begin
        result:=false;
        mm_log.Lines.Add(e.Message);
       end;
    end;
  finally
    PgConnection_main.Rollback;
    if Assigned(file_end) then
       file_end.Free;
  end;
end;

function TForm_main.GetKeyName(Aschema, AtableName: string): string;
begin
  result:= EmptyStr;
  q_tmp.SQL.Text:=' SELECT pg_attribute.attname, '+
                 ' format_type(pg_attribute.atttypid, pg_attribute.atttypmod) '+
                 ' FROM pg_index, pg_class, pg_attribute, pg_namespace '+
                 ' WHERE '+
                 ' pg_class.oid = :oid  ::regclass AND '+
                 ' indrelid = pg_class.oid AND '+
                 ' nspname = :schema AND '+
                 ' pg_class.relnamespace = pg_namespace.oid AND '+
                 ' pg_attribute.attrelid = pg_class.oid AND '+
                 ' pg_attribute.attnum = any(pg_index.indkey)  AND indisprimary';

  q_tmp.ParamByName('oid').AsString:=Aschema+'.'+AtableName;
  q_tmp.ParamByName('schema').AsString :=Aschema;
  q_tmp.Open;
  if q_tmp.RecordCount>0 then
    result:= q_tmp.FieldByName('attname').AsString;
end;

procedure TForm_main.pc_mainChange(Sender: TObject);
begin
  if pc_main.ActivePage=ts_compare then
  begin
    btn_save_as.Visible:=true;
    btn_save_as.Left:= pl_bottom.Width-btn_save_as.Width-10;
  end;
end;

function TForm_main.SetTrigeresEnabled(Aenabled: boolean; aschema, atablename:string): boolean;
var
  items:TStringList;
  i:integer;
  query:string;
begin
  result:=true;
  items:=TStringList.Create;

  q_tmp.SQL.Text:=' SELECT event_object_table '+
                  ' ,trigger_name '+
                  ' ,event_manipulation '+
                  ' ,action_statement '+
                  ' ,action_timing '+
                  ' FROM  information_schema.triggers '+
                  ' WHERE event_object_table = :table '+
                  ' and event_object_schema=:schema '+
                  ' ORDER BY event_object_table ,event_manipulation ';
  q_tmp.ParamByName('table').AsString:= atablename;
  q_tmp.ParamByName('schema').AsString:= aschema;
  q_tmp.Execute;
  q_tmp.First;
  for i:=0 to q_tmp.RecordCount-1 do begin
    items.Add(q_tmp.FieldByName('trigger_name').AsString);
    q_tmp.Next;
  end;

  if items.Count>0 then
  begin
    try
      try
         for I:=0 to items.count-1 do begin
           if Aenabled then
           begin
              query:=' ALTER TABLE '+ aschema+'.'+atablename+
                    '  ENABLE TRIGGER '+ items.Strings[i];
           end else begin
             query:=' ALTER TABLE '+ aschema+'.'+atablename+
                    ' DISABLE TRIGGER '+ items.Strings[i];
           end;
           q_tmp.SQL.Text:=query;
           q_tmp.Execute;

         end;
     except
        mm_log.Lines.Add('Cant change this: '+ query);
        result:=false;
     end;
    finally

    end;
  end;
end;

procedure TForm_main.ShowTabs(aShow: boolean);
begin
  ts_import.TabVisible:= aShow;
  ts_export.TabVisible:= aShow;
  pl_bottom.Visible:= aShow;
  ts_log.TabVisible:= aShow;
end;



//--------------------------------IMPORT ---------------------------------------


procedure TForm_main.btn_get_scriptsClick(Sender: TObject);
var
  SelectDir:string;
  list:TStringList;
  //----------------------------------------------------------------------
  function IsDirNotation(ADirName: string): Boolean;
  begin
    Result := (ADirName = '.') or (ADirName = '..');
  end;
  //----------------------------------------------------------------------
  function GetFiilesFromFolder(AFolder: string; var Alist: TStringList): integer;
  var
    c: TsearchRec;
  begin
    result := 0;
    if System.SysUtils.FindFirst(AFolder + '\*.*', FaAnyFile, c) = 0 then begin
      if not IsDirNotation(c.Name) then begin
        if System.SysUtils.fileExists(AFolder + '\' + c.name) then
          Alist.Add(AFolder + '\' + c.name);
      end;
      while System.SysUtils.FindNext(c) = 0 do
        if not IsDirNotation(c.Name) then begin
          if System.SysUtils.fileExists(AFolder + '\' + c.name) then
            AList.Add(AFolder + '\' + c.name);
        end;
    end;
    System.SysUtils.FindClose(c);
    result:= alist.Count;
  end;
  //----------------------------------------------------------------------
  function GetNamesFiles(Atext: string): string;
  begin
    while pos('\', Atext) <> 0 do
    delete(Atext, 1, pos('\', Atext));
    result := Atext;
  end;
  //----------------------------------------------------------------------
  procedure AddToList(Alist:TStringList);
  var
    i:integer;
    item:TListItem;
  begin
    for i:=0  to Alist.Count-1 do
    begin
      item:= LV_import.Items.Add;
      item.Checked:=true;
      item.SubItems.Add(list.Strings[i]);
      item.SubItems.Add(GetNamesFiles(list.Strings[i]));
    end;
  end;
begin
 if SelectDirectory('Select directory','c:\',SelectDir) then
 begin
   FSelectdir:= SelectDir;
 end;
 if trim(FSelectdir)<>'' then
 begin
   list:= TStringList.Create;
   GetFiilesFromFolder(FSelectdir,list);
   AddToList(list);
   list.Free;
 end;
end;

procedure TForm_main.btn_import_checkedClick(Sender: TObject);
var
  i:integer;
begin
  for I :=0 to LV_import.Items.Count-1 do
  begin
    LV_import.Items[i].Checked:=true;
  end;
end;

procedure TForm_main.btn_import_uncheckedClick(Sender: TObject);
var
  i:integer;
begin
  for I :=0 to LV_import.Items.Count-1 do
  begin
    LV_import.Items[i].Checked:=false;
  end;
end;



procedure TForm_main.btn_importClick(Sender: TObject);
var
 i,j:integer;
 item:TListItem;
 schema, table_name:string;
 res:boolean;
 path:string;
 lines:TStringList;
 line:string;
   function GetSchema(Atext:string):string;
   begin
     result:= copy(Atext,pos('.',Atext)+1,length(atext));
   end;
   //--------------------------------------------------------------
   function GetTableName(Atext:string):string;
   begin
    // text:= Atext;
    // Delete(text,1,pos('.[',text));
    // Delete(text,pos('.',text), length(text));
     result:= copy(atext,1, pos('.',atext)-1);
   end;
   //--------------------------------------------------------------
begin
 try
  PgConnection_main.StartTransaction;
  pb_all.Max :=LV_import.Items.Count;
  pb_all.Position:=0;
  pb_sub.Position:=0;
  lines:=TStringList.Create;

  for i :=0 to LV_import.Items.Count-1 do begin
    item:=  LV_import.Items[i];
    pb_all.Position:=pb_all.Position+1;
    if item.Checked then
    begin
      res:=true;
      schema:= GetSchema(item.SubItems[1]);
      table_name :=GetTableName(item.SubItems[1]);
      if cb_truncate_tables.Checked then
      begin
        res:= TruncateTable(table_name,schema);
      end;
      if res then
      begin
        res:= SetTrigeresEnabled(false,schema,table_name);
      end;

      if res then
      begin
        try
          path:= item.SubItems[0];
          lines.Clear;
          lines.LoadFromFile(path);

          q_tmp.SQL.Text := lines.Text;
          q_tmp.ExecSQL;
        except
          on E: EDatabaseError do
          begin
            //PgScript1.BreakExec;
            mm_log.Lines.Add(schema+'.'+ table_name+' ' + e.Message);
            PgConnection_main.Rollback;
            exit;
          end;
        end;
      end;
      if res then
      begin
        res:= SetTrigeresEnabled(true,schema,table_name);
      end;
    end;
  end;
 finally
  lines.Free;
  PgConnection_main.Commit;
 end;

 pb_all.Position:=0;
 pb_sub.Position:=0;
end;

function TForm_main.TruncateTable(aname:string;aschema:string): boolean;
begin
  result:=false;
  try
    q_tmp.SQL.Text:='Truncate table '+aschema+'.'+aname;
    q_tmp.Execute;
    result:=true;
  except
      on E: EDatabaseError do
       begin
        result:=false;
        mm_log.Lines.Add(e.Message);
       end;
  end;

end;



//Compare two databases


procedure TForm_main.btn_compare_conn_1Click(Sender: TObject);
begin
  PgConnection1.ConnectDialog := PgConnectDialog1;
  if PgConnection1.ConnectDialog.Execute then begin
     PgConnection1.Connect;
     btn_compare_conn_1.Caption:='Conn. to '+PgConnection1.Database;

  end;
end;

procedure TForm_main.btn_compare_conn_2Click(Sender: TObject);
begin
   PgConnection2.ConnectDialog := PgConnectDialog2;
  if PgConnection2.ConnectDialog.Execute then begin
     PgConnection2.Connect;
     btn_compare_conn_2.Caption:= 'Conn. to '+PgConnection2.Database;
  end;
end;


procedure TForm_main.btn_save_asClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    mm_compare.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm_main.btn_startClick(Sender: TObject);
var
  compDB:TCompareDB;

 function CheckConnect():boolean;
 var
   check:boolean;
 begin
   result:=true;
   if ((PgConnection1.Server= PgConnection2.Server) and
      (PgConnection1.Database=PgConnection2.Database))  then
   begin
      result:=false;
      ShowMessage('You connected to this same database!!!');
   end;
 end;

 function SettingsToByte:byte;
 var
   i:integer;
   sum:integer;
 begin
   sum:=0;
   for I := 0 to clb_compare_settings.Count-1 do
   begin
     if clb_compare_settings.Checked[i] then
       if i=0 then
        sum:=1 else
       sum:=sum + 2* i;
   end;
   result:=sum;
 end;
begin
  if PgConnection1.Connected and PgConnection2.Connected then
  begin
    if CheckConnect then
    begin
      //get table names
      if rg_compare_db.ItemIndex=0 then
      begin
        q_compare_table1.Connection := PgConnection1;
      end else begin
        q_compare_table1.Connection := PgConnection2;
      end;

      if Trim(edt_schema_2.Text)='schema' then
      begin
        q_compare_table1.SQL.Text:= 'SELECT table_schema, table_name '+
                                'FROM information_schema.tables '+
                                'where table_schema '+
                                'not in (''pg_catalog'',''information_schema'')'+
                                'ORDER BY table_schema,table_name; ';
        q_compare_table1.Open;


      end else  begin
        q_compare_table1.SQL.Text:= 'SELECT table_schema,table_name '+
                                'FROM information_schema.tables '+
                                'where table_schema '+
                                'not in (''pg_catalog'',''information_schema'') '+
                                'and table_schema = '+ QuotedStr(edt_schema_2.text) +
                                ' ORDER BY table_schema,table_name; ';
        q_compare_table1.Open;

      end;

      compDB:= TCompareDB.myCreate(PgConnection1,PgConnection2);
      compDB.CompareDB(q_compare_table1,mm_compare,SettingsToByte);
      compDB.Free;
      PgConnection1.Disconnect;
      PgConnection2.Disconnect;
      btn_compare_conn_1.Caption:='Get Connection 1';
      btn_compare_conn_2.Caption:='Get Connection 2';

    end;
  end else begin
    ShowMessage('Connect to two database please!');
  end;
end;


end.
