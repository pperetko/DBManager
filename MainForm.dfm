object Form_main: TForm_main
  Left = 0
  Top = 0
  ClientHeight = 447
  ClientWidth = 711
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pc_main: TPageControl
    Left = 0
    Top = 0
    Width = 711
    Height = 406
    ActivePage = ts_compare
    Align = alClient
    TabOrder = 0
    OnChange = pc_mainChange
    object ts_connection: TTabSheet
      Caption = 'Connection'
      ImageIndex = 2
      object Label1: TLabel
        Left = 27
        Top = 51
        Width = 22
        Height = 13
        Caption = 'Host'
      end
      object Label2: TLabel
        Left = 27
        Top = 78
        Width = 22
        Height = 13
        Caption = 'Pass'
      end
      object Label3: TLabel
        Left = 27
        Top = 130
        Width = 13
        Height = 13
        Caption = 'DB'
      end
      object Label4: TLabel
        Left = 27
        Top = 103
        Width = 22
        Height = 13
        Caption = 'User'
      end
      object Edit_Host: TEdit
        Left = 64
        Top = 48
        Width = 233
        Height = 21
        TabOrder = 0
        Text = 'localhost'
      end
      object Edit_pass: TEdit
        Left = 64
        Top = 75
        Width = 233
        Height = 21
        TabOrder = 1
        Text = 'test'
      end
      object cb_db: TComboBox
        Left = 64
        Top = 127
        Width = 233
        Height = 21
        Style = csDropDownList
        TabOrder = 4
      end
      object btn_getDb: TButton
        Left = 303
        Top = 98
        Width = 75
        Height = 25
        Caption = 'Get DB'
        TabOrder = 3
        OnClick = btn_getDbClick
      end
      object Bt_connect: TButton
        Left = 64
        Top = 161
        Width = 75
        Height = 25
        Caption = 'Connect'
        TabOrder = 5
        OnClick = Bt_connectClick
      end
      object Edit_user: TEdit
        Left = 64
        Top = 100
        Width = 233
        Height = 21
        TabOrder = 2
      end
      object btn_disconect: TButton
        Left = 145
        Top = 161
        Width = 153
        Height = 25
        Caption = 'Disconnect'
        TabOrder = 6
        OnClick = btn_disconectClick
      end
    end
    object ts_export: TTabSheet
      Caption = 'Export'
      ImageIndex = 1
      DesignSize = (
        703
        378)
      object lbl_save_As: TLabel
        Left = 160
        Top = 29
        Width = 16
        Height = 13
        Caption = '....'
      end
      object bt_getTables: TButton
        Left = 3
        Top = -1
        Width = 75
        Height = 25
        Caption = 'Get tables'
        TabOrder = 0
        OnClick = bt_getTablesClick
      end
      object ListView_Tables: TListView
        AlignWithMargins = True
        Left = 3
        Top = 50
        Width = 697
        Height = 325
        Margins.Top = 50
        Align = alClient
        Checkboxes = True
        Columns = <
          item
          end
          item
            Caption = 'Schema'
            Width = 200
          end
          item
            Caption = 'Table name'
            Width = 300
          end>
        ReadOnly = True
        TabOrder = 1
        ViewStyle = vsReport
      end
      object bt_Checked: TButton
        Left = 79
        Top = -1
        Width = 75
        Height = 25
        Caption = 'Checked'
        TabOrder = 2
        OnClick = bt_CheckedClick
      end
      object bt_unchecked: TButton
        Left = 155
        Top = -1
        Width = 75
        Height = 25
        Caption = 'UnChecked'
        TabOrder = 3
        OnClick = bt_uncheckedClick
      end
      object bt_export: TButton
        Left = 625
        Top = 0
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Export'
        TabOrder = 4
        OnClick = bt_exportClick
      end
      object bt_save_as: TButton
        Left = 314
        Top = 0
        Width = 75
        Height = 25
        Caption = 'Save as'
        TabOrder = 5
        OnClick = bt_save_asClick
      end
      object edt_schema: TEdit
        Left = 4
        Top = 25
        Width = 151
        Height = 21
        TabOrder = 6
        Text = 'schema'
      end
      object cb_export_cancel: TCheckBox
        Left = 625
        Top = 31
        Width = 97
        Height = 17
        Caption = 'Cancel'
        TabOrder = 7
        OnClick = cb_export_cancelClick
      end
    end
    object ts_import: TTabSheet
      Caption = 'Import'
      DesignSize = (
        703
        378)
      object btn_get_scripts: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Get scripts'
        TabOrder = 0
        OnClick = btn_get_scriptsClick
      end
      object btn_import: TButton
        Left = 625
        Top = 8
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Import'
        TabOrder = 1
        OnClick = btn_importClick
      end
      object cb_truncate_tables: TCheckBox
        Left = 400
        Top = 16
        Width = 97
        Height = 17
        Caption = 'Truncate tables'
        TabOrder = 2
      end
      object btn_import_checked: TButton
        Left = 87
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Checked'
        TabOrder = 3
        OnClick = btn_import_checkedClick
      end
      object btn_import_unchecked: TButton
        Left = 163
        Top = 8
        Width = 75
        Height = 25
        Caption = 'UnChecked'
        TabOrder = 4
        OnClick = btn_import_uncheckedClick
      end
      object LV_import: TListView
        AlignWithMargins = True
        Left = 3
        Top = 50
        Width = 697
        Height = 325
        Margins.Top = 50
        Align = alClient
        Checkboxes = True
        Columns = <
          item
          end
          item
            Caption = 'Table name'
            Width = 0
          end
          item
            Caption = 'Table name'
            Width = 300
          end>
        ReadOnly = True
        TabOrder = 5
        ViewStyle = vsReport
      end
    end
    object ts_compare: TTabSheet
      Caption = 'Compare two databases'
      ImageIndex = 4
      object btn_compare_conn_1: TButton
        Left = 3
        Top = 3
        Width = 160
        Height = 25
        Caption = 'Get Connection 1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btn_compare_conn_1Click
      end
      object btn_compare_conn_2: TButton
        Left = 168
        Top = 3
        Width = 160
        Height = 25
        Caption = 'Get Connection 2'
        TabOrder = 1
        OnClick = btn_compare_conn_2Click
      end
      object rg_compare_db: TRadioGroup
        Left = 3
        Top = 34
        Width = 266
        Height = 39
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          'compare db'
          'compare db')
        TabOrder = 2
      end
      object mm_compare: TMemo
        Left = 3
        Top = 79
        Width = 697
        Height = 290
        ScrollBars = ssBoth
        TabOrder = 3
      end
      object btn_start: TButton
        Left = 327
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 4
        OnClick = btn_startClick
      end
      object clb_compare_settings: TCheckListBox
        Left = 408
        Top = 3
        Width = 211
        Height = 70
        ItemHeight = 13
        Items.Strings = (
          'structure')
        TabOrder = 5
      end
      object edt_schema_2: TEdit
        Left = 275
        Top = 52
        Width = 127
        Height = 21
        TabOrder = 6
        Text = 'schema'
      end
      object btn_save_as: TButton
        Left = 625
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Save as'
        TabOrder = 7
        Visible = False
        OnClick = btn_save_asClick
      end
    end
    object ts_log: TTabSheet
      Caption = 'Log'
      ImageIndex = 3
      object mm_log: TMemo
        Left = 0
        Top = 0
        Width = 703
        Height = 378
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object pl_bottom: TPanel
    Left = 0
    Top = 406
    Width = 711
    Height = 41
    Align = alBottom
    TabOrder = 1
    object edt_table_name: TEdit
      Left = 3
      Top = 0
      Width = 299
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object pb_all: TProgressBar
      Left = 2
      Top = 21
      Width = 150
      Height = 17
      TabOrder = 1
    end
    object pb_sub: TProgressBar
      Left = 152
      Top = 21
      Width = 150
      Height = 17
      TabOrder = 2
    end
  end
  object PgConnection_main: TPgConnection
    Options.Charset = 'UTF8'
    Options.UseUnicode = True
    Left = 296
    Top = 368
  end
  object PgQuery_main: TPgQuery
    Connection = PgConnection_main
    Left = 384
    Top = 384
  end
  object q_tmp: TPgQuery
    Connection = PgConnection_main
    Left = 400
    Top = 336
  end
  object q_sub: TPgQuery
    Connection = PgConnection_main
    Left = 440
    Top = 352
  end
  object PgScript1: TPgScript
    Connection = PgConnection_main
    Left = 520
    Top = 200
  end
  object PgConnection1: TPgConnection
    Left = 296
    Top = 112
  end
  object PgConnection2: TPgConnection
    Left = 296
    Top = 160
  end
  object PgConnectDialog1: TPgConnectDialog
    Caption = 'Connect'
    ConnectButton = 'Connect'
    CancelButton = 'Cancel'
    Server.Caption = 'Server'
    Server.Visible = True
    Server.Order = 0
    UserName.Caption = 'User Name'
    UserName.Visible = True
    UserName.Order = 2
    Password.Caption = 'Password'
    Password.Visible = True
    Password.Order = 3
    Database.Caption = 'Database'
    Database.Visible = True
    Database.Order = 4
    Port.Caption = 'Port'
    Port.Visible = True
    Port.Order = 1
    Schema.Caption = 'Schema'
    Schema.Visible = False
    Schema.Order = 5
    Left = 360
    Top = 112
  end
  object PgConnectDialog2: TPgConnectDialog
    Caption = 'Connect'
    ConnectButton = 'Connect'
    CancelButton = 'Cancel'
    Server.Caption = 'Server'
    Server.Visible = True
    Server.Order = 0
    UserName.Caption = 'User Name'
    UserName.Visible = True
    UserName.Order = 2
    Password.Caption = 'Password'
    Password.Visible = True
    Password.Order = 3
    Database.Caption = 'Database'
    Database.Visible = True
    Database.Order = 4
    Port.Caption = 'Port'
    Port.Visible = True
    Port.Order = 1
    Schema.Caption = 'Schema'
    Schema.Visible = False
    Schema.Order = 5
    Left = 352
    Top = 160
  end
  object q_compare_table1: TPgQuery
    Connection = PgConnection1
    Left = 48
    Top = 112
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Filter = '[txt]'
    Left = 512
    Top = 256
  end
end
