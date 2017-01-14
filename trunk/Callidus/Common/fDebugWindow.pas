unit fDebugWindow;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls,
  uRichEditCallidus, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan;

type
  TfrmDebugWindow = class(TForm)
    MainMenu1: TMainMenu;
    miActions: TMenuItem;
    MyStatusBar: TStatusBar;
    StatusWindow: tRichEditCallidus;
    Closedebugwindow1: TMenuItem;
    ActionManagerDebugWindow: TActionManager;
    actCloseDebugWindow: TAction;
    procedure miCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCloseDebugWindowExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDebugWindow: TfrmDebugWindow;

implementation

{$R *.dfm}

uses
  // Delphi

  // Third Party

  // My Stuff
  uCommonStuff;

const
  IDX_PANEL_VERSION = 0;
  IDX_PANEL_LOCALIP = 1;

procedure TfrmDebugWindow.actCloseDebugWindowExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmDebugWindow.FormCreate(Sender: TObject);
begin
  Icon := Application.MainForm.Icon;
  Caption := Application.MainForm.Caption + ' [debug]';
  MyStatusBar.Panels[IDX_PANEL_VERSION].Text := sCALLIDUS_SYSTEM_VERSION;
  MyStatusBar.Panels[IDX_PANEL_LOCALIP].Text := 'local:' + GetLocalIpAddress;
end;

procedure TfrmDebugWindow.miCloseClick(Sender: TObject);
begin
  Application.MainForm.Close;
end;

end.
