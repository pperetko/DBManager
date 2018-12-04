program DBManager;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form_main},
  Compare in 'Compare.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_main, Form_main);
  Application.Run;
end.
