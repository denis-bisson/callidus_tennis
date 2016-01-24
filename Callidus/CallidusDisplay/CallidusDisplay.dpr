program CallidusDisplay;

uses
  Vcl.Forms,
  fCallidusDisplay in 'fCallidusDisplay.pas' {frmCallidusDisplay},
  uCommonStuff in '..\Common\uCommonStuff.pas',
  fDebugWindow in '..\Common\fDebugWindow.pas' {frmDebugWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'CALLIDUS - DISPLAY';
  Application.CreateForm(TfrmCallidusDisplay, frmCallidusDisplay);
  Application.CreateForm(TfrmDebugWindow, frmDebugWindow);
  Application.Run;
end.
