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
  TInformationForShowingServiceSpeed = record
    PosY: integer;
    SizY: integer;
    sSpeedValue: string;
    sSpeedUnit: string;
    UnitPosY: integer;
    UnitSizY: integer;
    iRatioUnitOnValue: integer;
    iShadowCount: integer;
    iUnitshadowcount: integer;
    colorBackground: tColor;
    colorSpeed: tColor;
    colorSpeedShadow: tColor;
    colorUnit: tColor;
    colorUnitShadow: tColor;
    iCommenditaire: integer;
  end;

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
    procedure SetInFullScreen(bWantedFullScreen: boolean);
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
    LastSpeedInformationReceived: TInformationForShowingServiceSpeed;
    procedure WMGetMinMaxInfo(var msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
    procedure LoadConfiguration;
    procedure SaveConfiguration;
  public
    { Public declarations }
    procedure ShowServiceSpeed(ServiceSpeedInfo: TInformationForShowingServiceSpeed);
  end;

var
  frmCallidusDisplay: TfrmCallidusDisplay;

implementation

{$R *.dfm}

uses
  // Delphi
  IniFiles, System.UITypes, jpeg,

  // Third party

  // My stuff
  fDebugWindow, MyEnhancedRichedit;

procedure TfrmCallidusDisplay.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfiguration;
end;

procedure TfrmCallidusDisplay.FormCreate(Sender: TObject);
begin
  LastSpeedInformationReceived.sSpeedValue := '';
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
    ShowCursor(False);  // Hide cursor
  end
  else
  begin
    BoundsRect := Rect;
      ShowCursor(True);  // Show cursor
  end;
  if LastSpeedInformationReceived.sSpeedValue <> '' then ShowServiceSpeed(LastSpeedInformationReceived);
  Application.ProcessMessages;
end;

procedure TfrmCallidusDisplay.SetInFullScreen(bWantedFullScreen: boolean);
begin
  if (bWantedFullScreen and not FullScreen) or (not bWantedFullScreen and FullScreen) then actToggleScreenModeExecute(actToggleScreenMode);
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
procedure TfrmCallidusDisplay.ShowServiceSpeed(ServiceSpeedInfo: TInformationForShowingServiceSpeed);
var
  rWindowRect: TRect;
  iSpeedSize, iUnitShadowCount, iSpeedWidthRequired, iSpeedHeightRequired, iPosX, iThisPosXChar, iThisPosYChar, iPosY, iOffset: Integer;
  iUnitSize, iUnitWidthRequired, iTotalWidthRequired, iChar: integer;
  iUnitOneCharHeight, iUnitHeightRequired, iThisCharWidth: integer;
  ImageCommenditaire: TImage;
  StdRect: TRect;
  ImageEnJpeg: TJpegImage;
  sNomfichierCommenditaire: string;

  procedure SetRequiredWithAccordingToSpecifiedTextSize;
  begin
    if (not FullScreen) or (ServiceSpeedInfo.UnitSizY = 0) then
      iUnitSize := ((iSpeedSize * ServiceSpeedInfo.iRatioUnitOnValue) div 100)
    else
      iUnitSize := ServiceSpeedInfo.UnitSizY;

    Canvas.Font.Size := iSpeedSize;
    iSpeedWidthRequired := Canvas.TextWidth(ServiceSpeedInfo.sSpeedValue);
    iSpeedHeightRequired := Canvas.TextHeight(ServiceSpeedInfo.sSpeedValue);

    if ServiceSpeedInfo.sSpeedUnit <> '' then
    begin
      Canvas.Font.Size := iUnitSize;
      iUnitWidthRequired := Canvas.TextWidth('W');
      iUnitOneCharHeight := Canvas.TextHeight('W');
      iUnitOneCharHeight := ((iUnitOneCharHeight * 75) div 100);
      iUnitHeightRequired := length(ServiceSpeedInfo.sSpeedUnit) * iUnitOneCharHeight;
    end
    else
    begin
      iUnitWidthRequired:=0;
    end;

    iTotalWidthRequired := iSpeedWidthRequired + (iUnitWidthRequired) + (iUnitWidthRequired div 2);
  end;

begin
  LastSpeedInformationReceived := ServiceSpeedInfo;
  Canvas.Font.Size := 12;
  Canvas.Font.Name := 'Arial';
  Canvas.Font.Color := clWhite;
  Canvas.Font.Style := [fsBold];
  Canvas.Brush.Style := bsSolid;

  rWindowRect.Top := 0;
  rWindowRect.Left := 0;
  rWindowRect.Height := ClientHeight;
  rWindowRect.Width := ClientWidth;

  Canvas.Brush.Color := ServiceSpeedInfo.colorBackground;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(rWindowRect);

  // 01. Si nous sommes en Full Screen ET QUE nous avons une commenditaire, on l'affiche!
  if FullScreen and (ServiceSpeedInfo.iCommenditaire > 0) then
  begin
    sNomfichierCommenditaire := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + 'commanditaire' + IntToStr(ServiceSpeedInfo.iCommenditaire) + '.jpg';
    if FileExists(sNomfichierCommenditaire) then
    begin
      ImageEnJpeg := TJpegImage.Create;
      ImageCommenditaire := TImage.Create(Self);
      try
        ImageEnJpeg.CompressionQuality := 100;
        ImageEnJpeg.LoadFromFile(sNomfichierCommenditaire);
        ImageCommenditaire.Picture.Bitmap.Assign(ImageEnJpeg);
        StdRect.Left := 0;
        StdRect.Top := 0;
        StdRect.Width := 1920;
        StdRect.Height := 200;
        Canvas.CopyRect(StdRect, ImageCommenditaire.Canvas, StdRect);
      finally
        FreeAndNil(ImageEnJpeg);
        FreeAndNil(ImageCommenditaire);
      end;
    end;
  end;

  if ServiceSpeedInfo.sSpeedValue <> '' then
  begin
    // 01. Ajuste la taille du texte. Si nous sommes en normal screen ou que le host ne nous l'a pas pitché, on s'arrange tant bien que mal pour mettre au milieu.
    if (not FullScreen) or (ServiceSpeedInfo.SizY = 0) then
    begin
      iSpeedSize := 20;
      iUnitSize := ((iSpeedSize * ServiceSpeedInfo.iRatioUnitOnValue) div 100);
      iUnitWidthRequired := 0;
      repeat
        SetRequiredWithAccordingToSpecifiedTextSize;
        inc(iSpeedSize);
      until (iTotalWidthRequired >= ClientWidth) or (iSpeedHeightRequired >= ClientHeight);
      dec(iSpeedSize);
    end
    else
    begin
      iSpeedSize := ServiceSpeedInfo.SizY;
      iUnitSize := ServiceSpeedInfo.UnitSizY;
    end;

    // 02. On ajuste nos variables. On doit le faire le cas où nous avons gossé plus haut pour trouvé taille optimale.
    SetRequiredWithAccordingToSpecifiedTextSize;

    // 03. Calcul de la position Y pour la vitesse. Si nous sommes en normal screen ou que le host ne nous l'a pas pitché, on s'arrange tant bien que mal pour mettre au milieu.
    if (not FullScreen) or (ServiceSpeedInfo.PosY = 0) then
      iPosY := ((ClientHeight - iSpeedHeightRequired) div 2)
    else
      iPosY := ServiceSpeedInfo.PosY;

    // 04. Calcule de la position X pour la vitesse.
    iPosX := ((ClientWidth - iTotalWidthRequired) div 2);
    Canvas.Brush.Style := bsClear;

    // 05. On affiche notre vitesse.
    Canvas.Font.Color := ServiceSpeedInfo.colorSpeedShadow;
    Canvas.Font.Size := iSpeedSize;
    for iOffset := 1 to ServiceSpeedInfo.iShadowCount do
      Canvas.TextOut(iPosX + iOffset, iPosY + iOffset, ServiceSpeedInfo.sSpeedValue);
    Canvas.Font.Color := ServiceSpeedInfo.colorSpeed;
    Canvas.TextOut(iPosX, iPosY, ServiceSpeedInfo.sSpeedValue);

    // 06. Si on le demande, on affiche notre unité de vitesse
    if ServiceSpeedInfo.sSpeedUnit <> '' then
    begin
      Canvas.Font.Size := iUnitSize;
      iPosX := iPosX + iSpeedWidthRequired + (iUnitWidthRequired div 2); //iUnitWidthRequired ici c'est juste pour avoir un espce.
      if (not FullScreen) then
        iUnitShadowCount := ((ServiceSpeedInfo.iShadowCount * ServiceSpeedInfo.iRatioUnitOnValue) div 100)
      else
        iUnitshadowcount := ServiceSpeedInfo.iUnitshadowcount;

      // 07. Calcul de la position Y. Si nous sommes en normal screen ou que le host ne nous l'a pas pitché, on s'arrange tant bien que mal pour mettre au milieu.
      if (not FullScreen) or (ServiceSpeedInfo.UnitPosY = 0) then
        iPosY := ((ClientHeight - iUnitHeightRequired) div 2)
      else
        iPosY := ServiceSpeedInfo.UnitPosY;

      for iChar := 1 to length(ServiceSpeedInfo.sSpeedUnit) do
      begin
        iThisCharWidth := Canvas.TextWidth(ServiceSpeedInfo.sSpeedUnit[iChar]);
        iThisPosXChar := iPosX + ((iUnitWidthRequired - iThisCharWidth) div 2);
        iThisPosYChar := iPosY + (pred(iChar) * iUnitOneCharHeight);

        Canvas.Font.Color := ServiceSpeedInfo.colorUnitShadow;
        for iOffset := 1 to iUnitshadowcount do
          Canvas.TextOut(iThisPosXChar + iOffset, iThisPosYChar + iOffset, ServiceSpeedInfo.sSpeedUnit[iChar]);

        Canvas.Font.Color := ServiceSpeedInfo.colorUnit;
        Canvas.TextOut(iThisPosXChar, iThisPosYChar, ServiceSpeedInfo.sSpeedUnit[iChar]);
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
      end
      else
      begin
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
  bDebugWasVisible, bWasInFullScreen: Boolean;
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
//      miFullCommunicationLog.Checked := ReadBool(CALLIDUSDISPLAYCONFIGSECTION, 'miFullCommunicationLog', False);
      miFullCommunicationLog.Checked := False;
      miFullCommunicationLogClick(miFullCommunicationLog);
      bWasInFullScreen := ReadBool(CALLIDUSDISPLAYCONFIGSECTION, 'FullScreen', False);
      if bWasInFullScreen then actToggleScreenModeExecute(actToggleScreenMode);
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
  ServiceSpeedInfo: TInformationForShowingServiceSpeed;
  slVariablesNames, slVariablesValues: TStringList;
  iIndexCommand: integer;
  iAnyValue: integer;
  iSpeedValueIndex: integer;
  sAnyValue: string;
  iShadowIndex: integer;
  iColorIndex: integer;
begin

  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;
  try
    iIndexCommand := ProtocolePROTO_Display.CommandList.IndexOf(Answer7);

    case iIndexCommand of
      PROTO_CMD_DISCRTC:
        begin
          CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);
          ProtocolePROTO_Display.ServerSocketReplyAnswer(Socket, PROTO_CMD_SMPLACK, nil);

          iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_ADJUSTSCREEN);
          if iAnyValue <> -1 then
          begin
            sAnyValue := slVariablesValues.Strings[iAnyValue];
            if sAnyValue = sDISPLAY_PARAM_FULLSCREEN then SetInFullScreen(TRUE);
            if sAnyValue = sDISPLAY_PARAM_NORMALSCREEN then SetInFullScreen(FALSE);
          end;

        end;

      PROTO_CMD_SNDINFO:
        begin
          CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);
          ProtocolePROTO_Display.ServerSocketReplyAnswer(Socket, PROTO_CMD_SMPLACK, nil);

          ServiceSpeedInfo.PosY := 0;
          ServiceSpeedInfo.SizY := 0;
          ServiceSpeedInfo.sSpeedValue := '';
          ServiceSpeedInfo.sSpeedUnit := '';
          ServiceSpeedInfo.UnitSizY := 0;
          ServiceSpeedInfo.iRatioUnitOnValue := 25;
          ServiceSpeedInfo.iShadowCount := 10;
          ServiceSpeedInfo.iUnitshadowcount := 2;
          ServiceSpeedInfo.colorBackground := clGreen;
          ServiceSpeedInfo.colorSpeed := clWhite;
          ServiceSpeedInfo.colorSpeedShadow := clBlack;
          ServiceSpeedInfo.colorUnit := clYellow;
          ServiceSpeedInfo.colorUnitShadow := clBlack;
          ServiceSpeedInfo.iCommenditaire := 0;

          iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICEPOSY);
          if iAnyValue <> -1 then ServiceSpeedInfo.PosY := StrToIntDef(slVariablesValues.Strings[iAnyValue], 0);
          iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICESIZY);
          if iAnyValue <> -1 then ServiceSpeedInfo.SizY := StrToIntDef(slVariablesValues.Strings[iAnyValue], 0);
          iSpeedValueIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICESPEED);
          if iSpeedValueIndex <> -1 then ServiceSpeedInfo.sSpeedValue := slVariablesValues.Strings[iSpeedValueIndex];

          iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICEUNIT);
          if iAnyValue <> -1 then ServiceSpeedInfo.sSpeedUnit := slVariablesValues.Strings[iAnyValue];
          iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICEUNITPOSY);
          if iAnyValue <> -1 then ServiceSpeedInfo.UnitPosY := StrToIntDef(slVariablesValues.Strings[iAnyValue], 0);
          iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICEUNITSIZY);
          if iAnyValue <> -1 then ServiceSpeedInfo.UnitSizY := StrToIntDef(slVariablesValues.Strings[iAnyValue], 0);
          iShadowIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICESHADOWSIZE);
          if iShadowIndex <> -1 then ServiceSpeedInfo.iShadowCount := StrToIntDef(slVariablesValues.Strings[iShadowIndex], 10);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SHOWSERVICEUNITSHDY);
          if iColorIndex <> -1 then ServiceSpeedInfo.iUnitshadowcount := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);

          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORBACK);
          if iColorIndex <> -1 then ServiceSpeedInfo.colorBackground := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORSPEED);
          if iColorIndex <> -1 then ServiceSpeedInfo.colorSpeed := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORSPEEDSHADOW);
          if iColorIndex <> -1 then ServiceSpeedInfo.colorSpeedShadow := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORUNIT);
          if iColorIndex <> -1 then ServiceSpeedInfo.colorUnit := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);
          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_COLORUNITSHADOW);
          if iColorIndex <> -1 then ServiceSpeedInfo.colorUnitShadow := StrToIntDef(slVariablesValues.Strings[iColorIndex], $FFFFFF);

          iColorIndex := slVariablesNames.IndexOf(CALLIDUS_CMD_SSS_COMMENDITAIRE);
          if iColorIndex <> -1 then ServiceSpeedInfo.iCommenditaire := StrToIntDef(slVariablesValues.Strings[iColorIndex], 0);

          ShowServiceSpeed(ServiceSpeedInfo);
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
      if not FullScreen then
        SaveWindowConfig(ConfigFile, Self, CALLIDUSDISPLAYCONFIGSECTION);
      SaveWindowConfig(ConfigFile, frmDebugWindow, DEBUGWINDOWSECTION);
      WriteBool(CALLIDUSDISPLAYCONFIGSECTION, 'bDebugWasVisible', frmDebugWindow.Visible);
      WriteBool(CALLIDUSDISPLAYCONFIGSECTION, 'cbSaveLogEachTimeWhenQuiting', miSaveLogEachTime.Checked);
      WriteBool(CALLIDUSDISPLAYCONFIGSECTION, 'miFullCommunicationLog', miFullCommunicationLog.Checked);
      WriteBool(CALLIDUSDISPLAYCONFIGSECTION, 'FullScreen', FullScreen);
      // ..SaveConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

end.

