unit fCallidusDisplay;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,
  System.Win.ScktComp,

  // Third party

  // My stuff
  uCommonStuff, Vcl.AppEvnts, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, uProtocolePROTO, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient;

type
  TfrmCallidusDisplay = class(TForm)
    pmMainPopUpMenu: TPopupMenu;
    ogglefullscreenornot1: TMenuItem;
    ServerSocketForDisplay: TServerSocket;
    Showdebugwindow1: TMenuItem;
    ActionManagerRadarConfig: TActionManager;
    actCloseApplication: TAction;
    N1: TMenuItem;
    CloseApplication1: TMenuItem;
    aeMainApplicationEvents: TApplicationEvents;
    actToggleDebugWindow: TAction;
    actToggleScreenMode: TAction;
    actStartServicing: TAction;
    miSaveLogEachTime: TMenuItem;
    ProtocolePROTO_Display: TProtocole_PROTO;
    actCloseAllApplications: TAction;
    CloseallCallidusapplications1: TMenuItem;
    AutoStartTimer: TTimer;
    IdUDPClientDisplay: TIdUDPClient;
    tmrControllerVerification: TTimer;
    csSocketDisplay: TClientSocket;
    miFullCommunicationLog: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure actCloseApplicationExecute(Sender: TObject);
    procedure aeMainApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actToggleDebugWindowExecute(Sender: TObject);
    procedure actToggleScreenModeExecute(Sender: TObject);
    procedure actStartServicingExecute(Sender: TObject);
    procedure ProtocolePROTO_DisplayServerSocketValidPacketReceived(Sender: TObject; Socket: TCustomWinSocket; Answer7: AnsiString; PayloadData: TStringList);
    procedure actCloseAllApplicationsExecute(Sender: TObject);
    procedure AutoStartTimerTimer(Sender: TObject);
    procedure tmrControllerVerificationTimer(Sender: TObject);
    procedure miFullCommunicationLogClick(Sender: TObject);
    procedure aeMainApplicationEventsException(Sender: TObject; E: Exception);
  private
    { Private declarations }
    isFirstActivation: Boolean;
    NomFichierConfiguration: string;
    Rect: TRect;
    FullScreen: Boolean;
    iIndexApplication: integer;
    procedure WMGetMinMaxInfo(var msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
    procedure LoadConfiguration;
    procedure SaveConfiguration;
  public
    { Public declarations }
    procedure ShowServiceSpeed(sSpeedValue, sSpeedUnit: string; iRatioUnitOnValue, iShadowCount: integer; colorBackground, colorSpeed, colorSpeedShadow, colorUnit, colorUnitShadow: tColor);
  end;

var
  frmCallidusDisplay: TfrmCallidusDisplay;

implementation

{$R *.dfm}

uses
  // Delphi
  IniFiles,

  // Third party

  // My stuff
  fDebugWindow;

procedure TfrmCallidusDisplay.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfiguration;
end;

procedure TfrmCallidusDisplay.FormCreate(Sender: TObject);
begin
  isFirstActivation := True;
  iIndexApplication := GetApplicationNbOfThisClass(Self.ClassName);
  ProtocolePROTO_Display.ComplementDeviceName := Format('Instance%.2d', [iIndexApplication]);
  NomFichierConfiguration := GetConfigFilename('CallidusDisplay');
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := 0;
  Rect.Bottom := 0;
  FullScreen := False;
  Caption := Application.Title;
end;

// 2015-12-03:DB-Provient de Peter Below from TeamB
procedure TfrmCallidusDisplay.WMGetMinMaxInfo(var msg: TWMGetMinMaxInfo);
begin
  inherited;
  with msg.MinMaxInfo^.ptMaxTrackSize do
  begin
    X := GetDeviceCaps(Canvas.handle, HORZRES) + (Width - ClientWidth);
    Y := GetDeviceCaps(Canvas.handle, VERTRES) + (Height - ClientHeight);
  end;
end;

procedure TfrmCallidusDisplay.actCloseAllApplicationsExecute(Sender: TObject);
begin
  CloseAllCallidusApplications;
end;

procedure TfrmCallidusDisplay.actCloseApplicationExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmCallidusDisplay.actStartServicingExecute(Sender: TObject);
begin
  try
    ServerSocketForDisplay.Port := PORT_FOR_SENDING_DISPLAY;
    WriteStatusLg('About to open server...', 'Sur le point d''ouvrir le serveur...', COLORDANGER);
    ServerSocketForDisplay.Open;
    Application.ProcessMessages;
    if ServerSocketForDisplay.Active then
      WriteStatusLg('Server opened successfully!', 'Le serveur a été ouvert avec succès!', COLORSUCCESS)
    else
      WriteStatusLg('ERROR: Failed to open server!', 'ERREUR: Problème d''ouverture du serveur...,COLORERROR)', COLORERROR);
  except
    WriteStatusLg('ERROR: Exception while in "actStartServicingExecute"...', 'ERREUR: Exception durant "actStartServicingExecute"...', COLORERROR);
  end;
end;

procedure TfrmCallidusDisplay.actToggleDebugWindowExecute(Sender: TObject);
begin
  if frmDebugWindow.Visible then
    frmDebugWindow.Close
  else
    frmDebugWindow.Show;
end;

procedure TfrmCallidusDisplay.actToggleScreenModeExecute(Sender: TObject);
begin
  FullScreen := not FullScreen;
  if FullScreen then
  begin
    Rect := BoundsRect;
    SetBounds(Left - ClientOrigin.X, Top - ClientOrigin.Y, GetDeviceCaps(Canvas.handle, HORZRES) + (Width - ClientWidth), GetDeviceCaps(Canvas.handle, VERTRES) + (Height - ClientHeight));
  end
  else
    BoundsRect := Rect;
  Application.ProcessMessages;
end;

procedure TfrmCallidusDisplay.aeMainApplicationEventsException(Sender: TObject; E: Exception);
var
  Msg: string;
begin
  if frmDebugWindow <> nil then
  begin
    Msg := E.Message;
    frmDebugWindow.StatusWindow.WriteStatus(E.Message, COLORERROR);
  end;
end;

procedure TfrmCallidusDisplay.aeMainApplicationEventsIdle(Sender: TObject; var Done: Boolean);
begin
  Application.ProcessMessages;
  if isFirstActivation then
  begin
    isFirstActivation := False;
    LoadConfiguration;
    ProtocolePROTO_Display.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Display.WorkingClientSocket.Port := PORT_FOR_SENDING_CONTROLLER;
    ProtocolePROTO_Display.WorkingClientSocket.Address := IP_ADDRESS_NULL;
    ProtocolePROTO_Display.WorkingServerSocket.Port := PORT_FOR_SENDING_DISPLAY;
    ProtocolePROTO_Display.Init;
    tmrControllerVerification.Enabled := TRUE;
    AutoStartTimer.Enabled := TRUE;
  end;
end;

procedure TfrmCallidusDisplay.AutoStartTimerTimer(Sender: TObject);
begin
  AutoStartTimer.Enabled := False;
  actStartServicingExecute(actStartServicing);
end;

{ TfrmCallidusDisplay.ShowServiceSpeed }
procedure TfrmCallidusDisplay.ShowServiceSpeed(sSpeedValue, sSpeedUnit: string; iRatioUnitOnValue, iShadowCount: integer; colorBackground, colorSpeed, colorSpeedShadow, colorUnit, colorUnitShadow: tColor);
var
  rWindowRect: TRect;
  iSpeedSize, iSpeedWidthRequired, iSpeedHeightRequired, iPosX, iThisPosXChar, iThisPosYChar, iPosY, iOffset: Integer;
  iUnitSize, iUnitWidthRequired, iTotalWidthRequired, iChar: integer;
  iUnitOneCharHeight, iUnitHeightRequired, iThisCharWidth: integer;

  procedure SetRequiredWithAccordingToSpecifiedTextSize;
  begin
    iUnitSize := ((iSpeedSize * iRatioUnitOnValue) div 100);

    Canvas.Font.Size := iSpeedSize;
    iSpeedWidthRequired := Canvas.TextWidth(sSpeedValue);
    iSpeedHeightRequired := Canvas.TextHeight(sSpeedValue);

    if sSpeedUnit <> '' then
    begin
      Canvas.Font.Size := iUnitSize;
      iUnitWidthRequired := Canvas.TextWidth('W');
      iUnitOneCharHeight := Canvas.TextHeight('W');
      iUnitOneCharHeight := ((iUnitOneCharHeight * 75) div 100);
      iUnitHeightRequired := length(sSpeedUnit) * iUnitOneCharHeight;
    end;

    iTotalWidthRequired := iSpeedWidthRequired + (iUnitWidthRequired) + (iUnitWidthRequired div 2);
  end;

begin
  Canvas.Font.Size := 12;
  Canvas.Font.Name := 'Arial';
  Canvas.Font.Color := clWhite;
  Canvas.Font.Style := [fsBold];
  Canvas.Brush.Style := bsSolid;

  rWindowRect.Top := 0;
  rWindowRect.Left := 0;
  rWindowRect.Height := ClientHeight;
  rWindowRect.Width := ClientWidth;

  Canvas.Brush.Color := colorBackground;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(rWindowRect);

  if sSpeedValue <> '' then
  begin
    iSpeedSize := 20;
    iUnitSize := ((iSpeedSize * iRatioUnitOnValue) div 100);
    iUnitWidthRequired := 0;

    repeat
      SetRequiredWithAccordingToSpecifiedTextSize;
      inc(iSpeedSize);
    until (iTotalWidthRequired >= ClientWidth) or (iSpeedHeightRequired >= ClientHeight);

    // Let's set "iSpeedSize" and "iUnitSize" so they hold the desired text size
    dec(iSpeedSize);
    SetRequiredWithAccordingToSpecifiedTextSize;

    Canvas.Font.Name := 'Arial';
    Canvas.Brush.Style := bsClear;

    // Let's show the SPEED first
    iPosX := ((ClientWidth - iTotalWidthRequired) div 2);
    iPosY := ((ClientHeight - iSpeedHeightRequired) div 2);

    Canvas.Font.Color := colorSpeedShadow;
    Canvas.Font.Size := iSpeedSize;
    for iOffset := 1 to iShadowCount do
      Canvas.TextOut(iPosX + iOffset, iPosY + iOffset, sSpeedValue);
    Canvas.Font.Color := colorSpeed;
    Canvas.TextOut(iPosX, iPosY, sSpeedValue);

    // If we have unit, let's show it!
    if sSpeedUnit <> '' then
    begin
      Canvas.Font.Size := iUnitSize;
      iShadowCount := ((iShadowCount * iRatioUnitOnValue) div 100);

      iPosX := iPosX + iSpeedWidthRequired + (iUnitWidthRequired div 2); //iUnitWidthRequired ici c'est juste pour avoir un espce.
      iPosY := ((ClientHeight - iUnitHeightRequired) div 2);

      for iChar := 1 to length(sSpeedUnit) do
      begin
        iThisCharWidth := Canvas.TextWidth(sSpeedUnit[iChar]);
        iThisPosXChar := iPosX + ((iUnitWidthRequired - iThisCharWidth) div 2);
        iThisPosYChar := iPosY + (pred(iChar) * iUnitOneCharHeight);

        Canvas.Font.Color := colorUnitShadow;
        for iOffset := 1 to iShadowCount do
          Canvas.TextOut(iThisPosXChar + iOffset, iThisPosYChar + iOffset, sSpeedUnit[iChar]);

        Canvas.Font.Color := colorUnit;
        Canvas.TextOut(iThisPosXChar, iThisPosYChar, sSpeedUnit[iChar]);
      end;
    end;
  end;
end;

procedure TfrmCallidusDisplay.tmrControllerVerificationTimer(Sender: TObject);
var
  sControllerIpAddress: string;
begin
  tmrControllerVerification.Enabled := FALSE;
  try
    if ProtocolePROTO_Display.GetControllerAddress(sControllerIpAddress) then
    begin
      if ProtocolePROTO_Display.WorkingClientSocket.Address <> sControllerIpAddress then
      begin
        ProtocolePROTO_Display.WorkingClientSocket.Address := sControllerIpAddress;
        // sbNetwork.Panels[IDX_PANEL_CONTROLLERIP].Text := 'controller:' + ProtocolePROTO_Display.WorkingClientSocket.Address;
        ProtocolePROTO_Display.SendIamAliveMessage;
      end;
    end
    else
    begin
      ProtocolePROTO_Display.WorkingClientSocket.Address := IP_ADDRESS_NULL;
      // sbNetwork.Panels[IDX_PANEL_CONTROLLERIP].Text := 'controller:' + ProtocolePROTO_Display.WorkingClientSocket.Address;
    end;

    if ProtocolePROTO_Display.WorkingClientSocket.Address <> IP_ADDRESS_NULL then
      tmrControllerVerification.Interval := 10000
    else
      tmrControllerVerification.Interval := 2000;
  finally
    tmrControllerVerification.Enabled := TRUE;
  end;
end;

procedure TfrmCallidusDisplay.WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
begin
  if sDebugLineFrench = '' then
    sDebugLineFrench := sDebugLineEnglish;
  frmDebugWindow.StatusWindow.WriteStatusLg(sDebugLineEnglish, sDebugLineFrench, clColorRequested);
end;

procedure TfrmCallidusDisplay.LoadConfiguration;
var
  ConfigFile: TIniFile;
  bDebugWasVisible: Boolean;
begin
  ConfigFile := TIniFile.Create(NomFichierConfiguration);
  try
    with ConfigFile do
    begin
      LoadWindowConfig(ConfigFile, Self, CALLIDUSDISPLAYCONFIGSECTION);
      LoadWindowConfig(ConfigFile, frmDebugWindow, DEBUGWINDOWSECTION);
      bDebugWasVisible := ReadBool(CALLIDUSDISPLAYCONFIGSECTION, 'bDebugWasVisible', False);
      if bDebugWasVisible then
        frmDebugWindow.Show;
      miSaveLogEachTime.Checked := ReadBool(CALLIDUSDISPLAYCONFIGSECTION, 'cbSaveLogEachTimeWhenQuiting', True);
      miFullCommunicationLog.Checked := ReadBool(CALLIDUSDISPLAYCONFIGSECTION, 'miFullCommunicationLog', False);
      miFullCommunicationLogClick(miFullCommunicationLog);
      // ..LoadConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

procedure TfrmCallidusDisplay.miFullCommunicationLogClick(Sender: TObject);
begin
  ProtocolePROTO_Display.WriteDebug := miFullCommunicationLog.Checked;
end;

{ ProtocolePROTO_DisplayServerSocketValidPacketReceived }
procedure TfrmCallidusDisplay.ProtocolePROTO_DisplayServerSocketValidPacketReceived(Sender: TObject; Socket: TCustomWinSocket; Answer7: AnsiString; PayloadData: TStringList);
var
  slVariablesNames, slVariablesValues: TStringList;
  iIndexCommand: integer;
  iSpeedValueIndex, iSpeedUnitIndex, iSpeedRatioIndex: integer;
  sSpeedValueToShow, sSpeedUnitToShow, sSpeedRatio: string;
  iShadowIndex, iShadowCount: integer;
  iColorIndex: integer;
  colorBackground, colorSpeed, colorSpeedShadow, colorUnit, colorUnitShadow: tColor;
begin
  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;
  try
    iIndexCommand := ProtocolePROTO_Display.CommandList.IndexOf(Answer7);

    case iIndexCommand of
      PROTO_CMD_SNDINFO:
        begin
          CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);
          ProtocolePROTO_Display.ServerSocketReplyAnswer(Socket, PROTO_CMD_SMPLACK, nil);

          sSpeedValueToShow := '';
          sSpeedUnitToShow := '';
          sSpeedRatio := '25';
          iShadowCount := 10;
          colorBackground := clGreen;
          colorSpeed := clWhite;
          colorSpeedShadow := clBlack;
          colorUnit := clYellow;
          colorUnitShadow := clBlack;

          iSpeedValueIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICESPEED);
          if iSpeedValueIndex <> -1 then sSpeedValueToShow := slVariablesValues.Strings[iSpeedValueIndex];
          iSpeedUnitIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICEUNIT);
          if iSpeedUnitIndex <> -1 then sSpeedUnitToShow := slVariablesValues.Strings[iSpeedUnitIndex];
          iSpeedRatioIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICERATIO);
          if iSpeedRatioIndex <> -1 then sSpeedRatio := slVariablesValues.Strings[iSpeedRatioIndex];
          iShadowIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICESHADOWSIZE);
          if iShadowIndex <> -1 then iShadowCount := StrToIntDef(slVariablesValues.Strings[iShadowIndex], 10);

          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORBACK);
          if iColorIndex <> -1 then colorBackground := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORSPEED);
          if iColorIndex <> -1 then colorSpeed := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORSPEEDSHADOW);
          if iColorIndex <> -1 then colorSpeedShadow := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORUNIT);
          if iColorIndex <> -1 then colorUnit := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORUNITSHADOW);
          if iColorIndex <> -1 then colorUnitShadow := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);

          ShowServiceSpeed(sSpeedValueToShow, sSpeedUnitToShow, StrToIntDef(sSpeedRatio, 25), iShadowCount, colorBackground, colorSpeed, colorSpeedShadow, colorUnit, colorUnitShadow);
        end;
    end;
  finally
    FreeAndNil(slVariablesNames);
    FreeAndNil(slVariablesValues);
  end;
end;

procedure TfrmCallidusDisplay.SaveConfiguration;
var
  ConfigFile: TIniFile;

begin
  ConfigFile := TIniFile.Create(NomFichierConfiguration);
  try
    with ConfigFile do
    begin
      SaveWindowConfig(ConfigFile, Self, CALLIDUSDISPLAYCONFIGSECTION);
      SaveWindowConfig(ConfigFile, frmDebugWindow, DEBUGWINDOWSECTION);
      WriteBool(CALLIDUSDISPLAYCONFIGSECTION, 'bDebugWasVisible', frmDebugWindow.Visible);
      WriteBool(CALLIDUSDISPLAYCONFIGSECTION, 'cbSaveLogEachTimeWhenQuiting', miSaveLogEachTime.Checked);
      WriteBool(CALLIDUSDISPLAYCONFIGSECTION, 'miFullCommunicationLog', miFullCommunicationLog.Checked);
      // ..SaveConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

end.

