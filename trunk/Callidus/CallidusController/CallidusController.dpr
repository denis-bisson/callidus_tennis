program CallidusController;

uses
  Vcl.Forms,
  fCallidusController in 'fCallidusController.pas' {frmCallidusController},
  uCommonStuff in '..\Common\uCommonStuff.pas',
  fDebugWindow in '..\Common\fDebugWindow.pas' {frmDebugWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'CALLIDUS - CONTROLLER';
  Application.CreateForm(TfrmCallidusController, frmCallidusController);
  Application.CreateForm(TfrmDebugWindow, frmDebugWindow);
  Application.Run;
end.
