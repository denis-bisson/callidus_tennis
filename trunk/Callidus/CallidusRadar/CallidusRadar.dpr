program CallidusRadar;

uses
  Vcl.Forms,
  fCallidusRadar in 'fCallidusRadar.pas' {frmCallidusRadar},
  uCommonStuff in '..\Common\uCommonStuff.pas',
  fDebugWindow in '..\Common\fDebugWindow.pas' {frmDebugWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'CALLIDUS - RADAR';
  Application.CreateForm(TfrmCallidusRadar, frmCallidusRadar);
  Application.CreateForm(TfrmDebugWindow, frmDebugWindow);
  Application.Run;
end.
