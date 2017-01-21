unit fCallidusRadar;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit, Vcl.ComCtrls, Vcl.Menus,
  BaseGrid, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls, System.Actions, Vcl.ActnList,
  Vcl.AppEvnts, Vcl.Buttons, System.ImageList,

  // Third party
  AdvObj, AdvGrid, VaClasses, VaComm, IdUDPServer, IdGlobal, IdSocketHandle,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient,

  // Callidus
  uCommonStuff, uProtocoleProto;

type
  TRadarMethod = (rm_GetMethod, rm_ChangeMethod, rm_SetMethod);

  TParameter = class
  public
    Name: string;
    ConfigTypeName: string;

    Packet_Type: byte;
    Command_ID: byte;
    Antenna_Number: byte;
    Value_Byte: byte;
    DataType: byte;
    ValueMin: integer;
    ValueMax: integer;
    Value_Items_Display: TStringList;
    Value_Items_Firmware: TStringList;
    Default_Value: integer;
    ReadBack_Value: integer;
    Proposed_Value: integer;
    Display: byte;
    constructor Create(const paramName: string; const paramConfigTypeName: string);
    procedure PopulateFieldAccordingToList(paramListeFields: TStrings);
  end;

  TRadarConfigList = class(TList)
  private
    function GetParameter(Index: integer): TParameter;
  public
    constructor Create;
    procedure Clear; override;
    function Add(paramName, paramConfigTypeName: string): integer;
    property Parameter[Index: integer]: TParameter read GetParameter;
  end;

  TfrmCallidusRadar = class(TForm)
    pcRadarPageControl: TPageControl;
    tsConfiguration: TTabSheet;
    btnReadStalkerConfigFile: TButton;
    pnlMainConfig: TPanel;
    edConfigFile: TLabeledEdit;
    cbComPort: TComboBox;
    cbRadarAddress: TComboBox;
    lblRadarAddress: TLabel;
    lblComPort: TLabel;
    pmRadarConfig: TPopupMenu;
    miExit: TMenuItem;
    pcConfigParam: TPageControl;
    Button3: TButton;
    RefreshCOMportlist1: TMenuItem;
    N1: TMenuItem;
    MainMenu1: TMainMenu;
    Action1: TMenuItem;
    Ref1: TMenuItem;
    ActionManagerRadarConfig: TActionManager;
    actRefreshComboComm: TAction;
    actCloseThisWindow: TAction;
    Closethiswindow1: TMenuItem;
    actReadStalkerConfigFile: TAction;
    ReadStalkerconfigfile1: TMenuItem;
    actReadSensorValue: TAction;
    Readsensorvalue1: TMenuItem;
    tsDebug: TTabSheet;
    chkbNoRadarFakeAnswer: TCheckBox;
    VaCommRadar: TVaComm;
    actStartMonitoring: TAction;
    actCloseConnexion: TAction;
    sbNetwork: TStatusBar;
    Closeconnexion1: TMenuItem;
    Button5: TButton;
    actWriteSensorValue: TAction;
    Writesensorvalue1: TMenuItem;
    TabSheet1: TTabSheet;
    edLowServiceSpeed: TLabeledEdit;
    edHighServiceSpeed: TLabeledEdit;
    edShowTimeServiceSpeed: TLabeledEdit;
    edLowInactivitySpeed: TLabeledEdit;
    edHighInactivitySpeed: TLabeledEdit;
    edInactivityTime: TLabeledEdit;
    miStartMonitoring: TMenuItem;
    aeMainApplicationEvents: TApplicationEvents;
    actToggleDebugWindow: TAction;
    View1: TMenuItem;
    oggleDebugWindow1: TMenuItem;
    ProtocolePROTO_Radar: TProtocoleProto;
    cbSaveLogEachTimeWhenQuiting: TCheckBox;
    actStopMonitoring: TAction;
    Button1: TButton;
    btnMonitoring: TSpeedButton;
    ImageListRadar: TImageList;
    btnConfigFile: TButton;
    odMainApp: TOpenDialog;
    acSelectStalkerConfigFile: TAction;
    actCloseAllApplications: TAction;
    Closeallapplications1: TMenuItem;
    IdUDPClientController: TIdUDPClient;
    IdUDPServerRadar: TIdUDPServer;
    tmrControllerVerification: TTimer;
    sbRadar: TStatusBar;
    miFullCommunicationLog: TMenuItem;
    btnApply: TButton;
    actAutodetection: TAction;
    N3: TMenuItem;
    tsOptionsAutoDetection: TTabSheet;
    GroupBox1: TGroupBox;
    cbKeepRetryingAutodetect: TCheckBox;
    cbTryAllBaudRate: TCheckBox;
    GroupBox2: TGroupBox;
    cbDetectNetwork: TCheckBox;
    cbDetectRadar: TCheckBox;
    cbLanceMonitoring: TCheckBox;
    btnStopAutoDetect: TSpeedButton;
    pnlAutoDetection: TMemo;
    tmrTestConnexion: TTimer;
    procedure RefreshDisplayedParameterTable(paramShowReadBackValues: boolean = FALSE);
    procedure FormCreate(Sender: TObject);
    procedure AdvAnyGridGetEditorType(Sender: TObject; ACol, ARow: integer; var AEditor: TEditorType);
    procedure AdvAnyGridCanEditCell(Sender: TObject; ARow, ACol: integer; var CanEdit: boolean);
    procedure PopulatecbComPort;
    procedure cbComPortDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
    procedure actRefreshComboCommExecute(Sender: TObject);
    procedure actCloseThisWindowExecute(Sender: TObject);
    procedure actReadStalkerConfigFileExecute(Sender: TObject);
    procedure actReadSensorValueExecute(Sender: TObject);
    procedure DisableToute;
    procedure EnableToute(bShowLogWindowIfError: boolean = True);
    function SetTransmitterOnOrOff(StateWanted: boolean): boolean;
    procedure actStartMonitoringExecute(Sender: TObject);
    procedure actCloseConnexionExecute(Sender: TObject);
    procedure VaCommRadarClose(Sender: TObject);
    procedure actWriteSensorValueExecute(Sender: TObject);
    procedure AdvAnyGridEditCellDone(Sender: TObject; ACol, ARow: integer);
    procedure AdvAnyGridGetCellColor(Sender: TObject; ARow, ACol: integer; AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
    procedure ProcessSpeedPacket(sSpeedReceived: AnsiString);
    procedure WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
    procedure aeMainApplicationEventsIdle(Sender: TObject; var Done: boolean);
    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actToggleDebugWindowExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure acSelectStalkerConfigFileExecute(Sender: TObject);
    procedure actCloseAllApplicationsExecute(Sender: TObject);
    procedure btnStopTestEnBoucleClick(Sender: TObject);
    procedure miFullCommunicationLogClick(Sender: TObject);
    procedure aeMainApplicationEventsException(Sender: TObject; E: Exception);
    procedure FaisRemonterLeServiceSpeed(pServiceSpeedInfo: PTServiceSpeed);
    procedure btnApplyClick(Sender: TObject);
    procedure ChangeServiceSettingClick(Sender: TObject);
    procedure actAutodetectionExecute(Sender: TObject);
    function AutoDetectRadar: boolean;
    procedure CloseConnexion;
    procedure cbDetectRadarClick(Sender: TObject);
    procedure cbDetectNetworkClick(Sender: TObject);
    procedure btnStopAutoDetectClick(Sender: TObject);
    procedure ProtocolePROTO_RadarServerPacketReceived(Sender: TObject; ABinding: TIdSocketHandle; const AData: TIdBytes; Answer7: AnsiString; PayloadData: TStringList);
    procedure ProcessInfoForSpeedParam(PayloadData: TStringList);
    procedure StartNetworkTest(PayloadData: TStringList);
    procedure StopNetworkTest(PayloadData: TStringList);
    procedure tmrTestConnexionTimer(Sender: TObject);
    procedure SendBackToHostCurrentParameters;

  private
    { Private declarations }
    WorkingRadarConfig: TRadarConfigList;
    bCurrentlyWaitingEF: boolean;
    RadarAnswer: AnsiString;
    bOverAllActionResult: boolean;
    InitialTabSheet: TTabSheet;
    IndexCommandeTransmitControl, IndexCommandReadProductID: integer;
    bMonitorSpeed: boolean;
    iRxOverallCount, iTxOverallCount: integer;
    isFirstActivation: boolean;
    NomFichierConfiguration: string;
    iIndexApplication: integer;
    bFlagAbort, bAbortAutoDetection, bCurrentlyDoingNetworkCycleTest: boolean;
    bFirstNetworkDetection: boolean;
    itnTempsOn, itnTempsOff: integer;
    btnIncludeTempsOff: boolean;
  public
    { Public declarations }
    ServiceSpeed: TServiceSpeed;
    procedure LoadRadarConfigFile;
    function EstablishConnexionWithRadar: boolean;
    function SendReceiveRadarParameter(RadarAddress, IndexParameter: integer; paramMethod: TRadarMethod; paramNoVerification: boolean = FALSE): boolean;
    procedure VaCommRadarRxChar(Sender: TObject; Count: integer);
    procedure RefreshConfigRadarStatusBar;
    procedure SetVisibleServiceSpeedParamFromVariable;
    procedure SetVariableFromVisibleServiceSpeedParam;
  end;

var
  frmCallidusRadar: TfrmCallidusRadar;

implementation

{$R *.dfm}

uses
  // Delphi
  IniFiles, StrUtils, AnsiStrings, Math, System.UITypes,

  // Third party

  // Callidus
  fDebugWindow;

const
  COL_INDEX = 0;
  COL_SETTINGS = 1;
  COL_SENSORVAL = 2;
  COL_PROPOSEVAL = 3;
  COL_DEFAULTVAL = 4;
  COL_RANGE = 5;

  COL_SETTING_DIFFERENT = $E0FFFF;
  COL_SETTING_OK = clWhite;

  NBCOLMAX = 6;

  //sbNetwork
  IDX_PANEL_VERSION = 0;
  IDX_PANEL_APPLICATIONO = 1;
  IDX_PANEL_LOCALIP = 2;
  IDX_PANEL_CONTROLLERIP = 3;

  //sbRadar
  IDX_PANEL_SERVICESPEEDSTATEMACHINE = 0;
  IDX_PANEL_SERVICETIMESHOWN = 1;
  IDX_PANEL_COM = 2;
  IDX_PANEL_TX = 3;
  IDX_PANEL_RX = 4;

  CODE_WAIT_SERVICE = 2147483647;
  CODE_WAIT_INACTIVITY = 2147483646;

  STR_STOPMONITORING = ' Stop Monitoring';
  STR_STARTMONITORING = 'Start Monitoring';

  { TParameter.Create }

constructor TParameter.Create(const paramName: string; const paramConfigTypeName: string);
begin
  Self.Name := paramName;
  Self.ConfigTypeName := paramConfigTypeName;
  Self.Packet_Type := 0;
  Self.Command_ID := 0;
  Self.Antenna_Number := 0;
  Self.Value_Byte := 0;
  Self.DataType := 0;
  Self.ValueMin := 0;
  Self.ValueMax := 0;
  Self.Value_Items_Display := TStringList.Create;
  Self.Value_Items_Display.Delimiter := ',';
  Self.Value_Items_Display.QuoteChar := #0;
  Self.Value_Items_Display.StrictDelimiter := True;
  Self.Value_Items_Firmware := TStringList.Create;
  Self.Value_Items_Firmware.Delimiter := ',';
  Self.Value_Items_Firmware.QuoteChar := #0;
  Self.Value_Items_Firmware.StrictDelimiter := True;
  Self.Default_Value := 0;
  Self.ReadBack_Value := 0;
  Self.Proposed_Value := 0;
  Self.Display := 0;
end;

{ TParameter.PopulateFieldAccordingToList }

procedure TParameter.PopulateFieldAccordingToList(paramListeFields: TStrings);

  function ReturnStringValue(paramKeyWord: string): string;
  var
    iSearching, PosEgal: integer;
  begin
    result := '';
    paramKeyWord := paramKeyWord + '=';
    iSearching := 0;
    while (iSearching < paramListeFields.Count) and (result = '') do
    begin
      if pos(paramKeyWord, paramListeFields.Strings[iSearching]) = 1 then
      begin
        PosEgal := pos('=', paramListeFields.Strings[iSearching]);
        result := RightStr(paramListeFields.Strings[iSearching], (length(paramListeFields.Strings[iSearching]) - PosEgal));
      end;
      inc(iSearching);
    end;
  end;

begin
  Self.Packet_Type := StrToIntDef(ReturnStringValue('PACKET_TYPE'), 0);
  Self.Command_ID := StrToIntDef(ReturnStringValue('COMMAND_ID'), 0);
  Self.Antenna_Number := StrToIntDef(ReturnStringValue('ANTENNA_NUMBER'), 0);
  Self.Value_Byte := StrToIntDef(ReturnStringValue('VALUE_BYTES'), 0);
  Self.DataType := StrToIntDef(ReturnStringValue('DATA_TYPE'), 0);
  Self.ValueMin := StrToIntDef(ReturnStringValue('VALUE_MIN'), 0);
  Self.ValueMax := StrToIntDef(ReturnStringValue('VALUE_MAX'), 0);
  Self.Value_Items_Display.DelimitedText := ReturnStringValue('VALUE_ITEMS_DISPLAY');
  Self.Value_Items_Firmware.DelimitedText := ReturnStringValue('VALUE_ITEMS_FIRMWARE');
  Self.Default_Value := StrToIntDef(ReturnStringValue('DEFAULT_VALUE'), 0);
  Self.ReadBack_Value := 0;
  Self.Proposed_Value := 0;
  Self.Display := StrToIntDef(ReturnStringValue('DISPLAY'), 0);
end;

{ TRadarConfigList.GetParameter }

function TRadarConfigList.GetParameter(Index: integer): TParameter;
begin
  result := TParameter(Items[Index]);
end;

{ TRadarConfigList.Create }

constructor TRadarConfigList.Create;
begin
  inherited Create;
end;

{ TRadarConfigList.Clear }

procedure TRadarConfigList.Clear;
var
  i: integer;
begin
  for i := pred(Count) downto 0 do
  begin
    FreeAndNil(Parameter[i].Value_Items_Display);
    FreeAndNil(Parameter[i].Value_Items_Firmware);
    Parameter[i].Free;
  end;
  inherited Clear;
end;

{ TRadarConfigList.Add }

function TRadarConfigList.Add(paramName, paramConfigTypeName: string): integer;
var
  WorkingParameter: TParameter;
begin
  WorkingParameter := TParameter.Create(paramName, paramConfigTypeName);
  result := inherited Add(WorkingParameter);
end;

procedure TfrmCallidusRadar.acSelectStalkerConfigFileExecute(Sender: TObject);
begin
  odMainApp.FilterIndex := 1;
  if FileExists(edConfigFile.Text) then
    odMainApp.FileName := edConfigFile.Text;
  if odMainApp.Execute then
  begin
    edConfigFile.Text := odMainApp.FileName;
    SendMessage(btnReadStalkerConfigFile.Handle, BM_CLICK, 0, 0);
  end;
end;

procedure TfrmCallidusRadar.actCloseAllApplicationsExecute(Sender: TObject);
begin
  CloseAllCallidusApplications;
end;

procedure TfrmCallidusRadar.CloseConnexion;
begin
  if VaCommRadar.Active then
  begin
    VaCommRadar.Close;
    Application.ProcessMessages;
  end;
end;

procedure TfrmCallidusRadar.actCloseConnexionExecute(Sender: TObject);
begin
  CloseConnexion;
end;

procedure TfrmCallidusRadar.actCloseThisWindowExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmCallidusRadar.actReadSensorValueExecute(Sender: TObject);
var
  iParam, RadarAddress: integer;
  bKeepGoing: boolean;
begin
  DisableToute;
  try
    RadarAddress := StrToIntDef(cbRadarAddress.Items.Strings[cbRadarAddress.ItemIndex], 2);
    cbRadarAddress.ItemIndex := RadarAddress - 2;

    if SetTransmitterOnOrOff(FALSE) then
    begin
      bKeepGoing := True;
      iParam := 0;
      while (iParam < WorkingRadarConfig.Count) and (bKeepGoing) do
      begin
        if WorkingRadarConfig.Parameter[iParam].Display = 1 then
          bKeepGoing := SendReceiveRadarParameter(RadarAddress, iParam, rm_GetMethod);
        if bKeepGoing then
          WorkingRadarConfig.Parameter[iParam].Proposed_Value := WorkingRadarConfig.Parameter[iParam].ReadBack_Value;
        inc(iParam);
      end;

      if bKeepGoing then
      begin
        if SetTransmitterOnOrOff(True) then
        begin
          RefreshDisplayedParameterTable(True);
          bOverAllActionResult := True;
        end;
      end;

      if bOverAllActionResult then
        actWriteSensorValue.Tag := 0;
    end;
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusRadar.actReadStalkerConfigFileExecute(Sender: TObject);
begin
  LoadRadarConfigFile;
end;

procedure TfrmCallidusRadar.actRefreshComboCommExecute(Sender: TObject);
begin
  PopulatecbComPort;
end;

procedure TfrmCallidusRadar.actStartMonitoringExecute(Sender: TObject);
begin
  actStartMonitoring.Enabled := FALSE;
  Application.ProcessMessages;
  try
    try
      if actStartMonitoring.Caption <> STR_STOPMONITORING then
      begin
        DisableToute;
        actStartMonitoring.Caption := STR_STOPMONITORING;
        btnMonitoring.Caption := actStartMonitoring.Caption;
        miStartMonitoring.Caption := actStartMonitoring.Caption;
        btnMonitoring.Glyph.Assign(nil);
        ImageListRadar.GetBitmap(1, btnMonitoring.Glyph);
        WriteStatusLg('Starting monitoring mode...', 'On démarre le mode de réception de base...', COLORDANGER);
        if SetTransmitterOnOrOff(True) then
        begin
          RadarAnswer := '';
          SetVariableFromVisibleServiceSpeedParam;
          ServiceSpeed.StateMachine := tsmss_WAITING_SERVICE;
          sbRadar.Panels[IDX_PANEL_SERVICESPEEDSTATEMACHINE].Text := 'WAITING SERVICE';
          sbRadar.Panels[IDX_PANEL_SERVICETIMESHOWN].Text := '';
          bMonitorSpeed := True;
        end
        else
        begin
          actStartMonitoring.Caption := STR_STARTMONITORING;
          btnMonitoring.Caption := actStartMonitoring.Caption;
          miStartMonitoring.Caption := actStartMonitoring.Caption;
          btnMonitoring.Glyph.Assign(nil);
          ImageListRadar.GetBitmap(0, btnMonitoring.Glyph);
          WriteStatusLg('ERROR: Unable to activate transmitter on radar side...', 'ERREUR: Incapable d''activer la transmission du côté du radar...', COLORERROR);
          EnableToute;
        end;
      end
      else
      begin
        ServiceSpeed.StateMachine := tmss_STOPPED;
        bMonitorSpeed := FALSE;
        Application.ProcessMessages;
        actStartMonitoring.Caption := STR_STARTMONITORING;
        btnMonitoring.Caption := actStartMonitoring.Caption;
        miStartMonitoring.Caption := actStartMonitoring.Caption;
        btnMonitoring.Glyph.Assign(nil);
        ImageListRadar.GetBitmap(0, btnMonitoring.Glyph);
        Application.ProcessMessages;
        RadarAnswer := '';
        bOverAllActionResult := True;
        WriteStatusLg('Monitoring mode ended.', 'On a complété le mode de réception de base.', COLORSUCCESS);
        EnableToute;
      end;

    except
      EnableToute;
    end;
  finally
    actStartMonitoring.Enabled := True;
  end;
end;

{ TfrmCallidusRadar.FaisRemonterLeServiceSpeed }
procedure TfrmCallidusRadar.FaisRemonterLeServiceSpeed(pServiceSpeedInfo: PTServiceSpeed);
var
  PayloadDataRequest: TStringList;
begin
  PayloadDataRequest := TStringList.Create;
  try
    ProtocolePROTO_Radar.LoadStringListWithIdentificationInfo(PayloadDataRequest);
    if pServiceSpeedInfo <> nil then
    begin
      PayloadDataRequest.Add(CALLIDUS_CMD_GOTASERVICESPEED + '=' + IntToStr(pServiceSpeedInfo^.CurrentPeakSpeed));
      PayloadDataRequest.Add(CALLIDUS_CMD_SERVICEDIRECTION + '=' + IntToStr(pServiceSpeedInfo^.CurrentPeekDirection));
    end
    else
    begin
      PayloadDataRequest.Add(CALLIDUS_CMD_GOTASERVICESPEED + '=');
      PayloadDataRequest.Add(CALLIDUS_CMD_SERVICEDIRECTION + '=');
    end;

    ProtocolePROTO_Radar.PitchUnMessagePROTONoHandshake('', PROTO_CMD_SNDINFO, PayloadDataRequest);
  finally
    FreeAndNil(PayloadDataRequest);
  end;
end;

procedure TfrmCallidusRadar.tmrTestConnexionTimer(Sender: TObject);
var
  ServiceSpeedTemporaire: TServiceSpeed;
begin
  TTimer(Sender).Enabled := False;

  if bCurrentlyDoingNetworkCycleTest then
  begin
    case TTimer(Sender).Tag of
      0, 1:
        begin
          ServiceSpeedTemporaire.CurrentPeakSpeed := (100 + random(100));
          ServiceSpeedTemporaire.CurrentPeekDirection := 1 + random(2);
          FaisRemonterLeServiceSpeed(addr(ServiceSpeedTemporaire));
          TTimer(Sender).Interval := itnTempsOn;
          if btnIncludeTempsOff then TTimer(Sender).Tag := 2;
        end;

      2:
        begin
          FaisRemonterLeServiceSpeed(nil);
          TTimer(Sender).Interval := itnTempsOff;
          TTimer(Sender).Tag := 1;
        end;
    end;

    TTimer(Sender).Enabled := true;
  end;
end;

procedure TfrmCallidusRadar.StopNetworkTest(PayloadData: TStringList);
begin
  bFlagAbort := FALSE;
  bCurrentlyDoingNetworkCycleTest := False;
  Application.ProcessMessages;
end;

procedure TfrmCallidusRadar.actToggleDebugWindowExecute(Sender: TObject);
begin
  if frmDebugWindow.Visible then
    frmDebugWindow.Close
  else
    frmDebugWindow.Show;
end;

procedure TfrmCallidusRadar.AdvAnyGridCanEditCell(Sender: TObject; ARow, ACol: integer; var CanEdit: boolean);
begin
  CanEdit := (ACol = COL_PROPOSEVAL);
end;

procedure TfrmCallidusRadar.AdvAnyGridEditCellDone(Sender: TObject; ACol, ARow: integer);
var
  iParam: integer;
begin
  iParam := StrToIntDef(TAdvStringGrid(Sender).GridCells[0, ARow], -1);

  case WorkingRadarConfig.Parameter[iParam].DataType of
    1:
      WorkingRadarConfig.Parameter[iParam].Proposed_Value := WorkingRadarConfig.Parameter[iParam].Value_Items_Display.IndexOf(TAdvStringGrid(Sender).GridCells[COL_PROPOSEVAL, ARow]);

    2:
      WorkingRadarConfig.Parameter[iParam].Proposed_Value := StrToIntDef(TAdvStringGrid(Sender).GridCells[COL_PROPOSEVAL, ARow], 0);
  end;

  TAdvStringGrid(Sender).Refresh;
end;

procedure TfrmCallidusRadar.AdvAnyGridGetCellColor(Sender: TObject; ARow, ACol: integer; AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
begin
  if ARow > 0 then
  begin
    if TAdvStringGrid(Sender).GridCells[COL_SENSORVAL, ARow] <> TAdvStringGrid(Sender).GridCells[COL_PROPOSEVAL, ARow] then
      ABrush.Color := COL_SETTING_DIFFERENT
    else
      ABrush.Color := COL_SETTING_OK;
  end;
end;

procedure TfrmCallidusRadar.AdvAnyGridGetEditorType(Sender: TObject; ACol, ARow: integer; var AEditor: TEditorType);
var
  iParam: integer;
begin
  iParam := StrToIntDef(TAdvStringGrid(Sender).GridCells[0, ARow], -1);
  case WorkingRadarConfig.Parameter[iParam].DataType of
    1:
      begin
        AEditor := edComboList;
        TAdvStringGrid(Sender).ClearComboString;
        TAdvStringGrid(Sender).Combobox.Items.Assign(WorkingRadarConfig.Parameter[iParam].Value_Items_Display);
      end;

    2:
      begin
        if WorkingRadarConfig.Parameter[iParam].Value_Items_Display.Count > 0 then
        begin
          AEditor := edComboEdit;
          TAdvStringGrid(Sender).ClearComboString;
          TAdvStringGrid(Sender).Combobox.Items.Assign(WorkingRadarConfig.Parameter[iParam].Value_Items_Display);
        end
        else
        begin
          AEditor := edNormal;
        end;
      end;
  end;
end;

procedure TfrmCallidusRadar.aeMainApplicationEventsException(Sender: TObject; E: Exception);
var
  Msg: string;
begin
  if frmDebugWindow <> nil then
  begin
    Msg := E.Message;
    frmDebugWindow.StatusWindow.WriteStatus(E.Message, COLORERROR);
  end;
end;

procedure TfrmCallidusRadar.aeMainApplicationEventsIdle(Sender: TObject; var Done: boolean);
begin
  Application.ProcessMessages;
  if isFirstActivation then
  begin
    isFirstActivation := FALSE;
    LoadConfiguration;
    btnMonitoring.Glyph.Assign(nil);
    ImageListRadar.GetBitmap(0, btnMonitoring.Glyph);

    ProtocolePROTO_Radar.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Radar.WorkingClientUDP.Port := PORT_CALLIDUS_CONTROLLER;
    ProtocolePROTO_Radar.WorkingServerUDP.DefaultPort := PORT_CALLIDUS_RADAR;
    ProtocolePROTO_Radar.Init;
    bFirstNetworkDetection := TRUE;
    //    tmrControllerVerification.Enabled := TRUE;
  end;
end;

procedure TfrmCallidusRadar.btnApplyClick(Sender: TObject);
begin
  SetVariableFromVisibleServiceSpeedParam;
end;

procedure TfrmCallidusRadar.btnStopAutoDetectClick(Sender: TObject);
begin
  bAbortAutoDetection := True;
  Application.ProcessMessages;
end;

procedure TfrmCallidusRadar.btnStopTestEnBoucleClick(Sender: TObject);
begin
  bFlagAbort := TRUE;
  bCurrentlyDoingNetworkCycleTest := False;
  Application.ProcessMessages;
end;

procedure TfrmCallidusRadar.LoadRadarConfigFile;
var
  StalkerConfigFile: TIniFile;
  ListOfSections, ListeParamValues: TStrings;
  iSection: integer;
  LastPageName: string;
begin
  if WorkingRadarConfig <> nil then
  begin
    WorkingRadarConfig.Clear;
    WorkingRadarConfig.Free;
  end;

  IndexCommandeTransmitControl := -1;
  IndexCommandReadProductID := -1;
  LastPageName := 'Main';
  WorkingRadarConfig := TRadarConfigList.Create;

  ListOfSections := TStringList.Create;
  ListeParamValues := TStringList.Create;
  try
    StalkerConfigFile := TIniFile.Create(edConfigFile.Text);
    try
      StalkerConfigFile.ReadSections(ListOfSections);
      for iSection := 0 to pred(ListOfSections.Count) do
      begin
        StalkerConfigFile.ReadSectionValues(ListOfSections.Strings[iSection], ListeParamValues);
        WorkingRadarConfig.Add(ListOfSections.Strings[iSection], LastPageName);
        WorkingRadarConfig.Parameter[pred(WorkingRadarConfig.Count)].PopulateFieldAccordingToList(ListeParamValues);
        if ListeParamValues.Count = 0 then
        begin
          WorkingRadarConfig.Delete(pred(WorkingRadarConfig.Count));
          LastPageName := ListOfSections.Strings[iSection];
        end;
      end;
    finally
      StalkerConfigFile.Free;
    end;
  finally
    FreeAndNil(ListeParamValues);
    FreeAndNil(ListOfSections);
  end;

  RefreshDisplayedParameterTable;
end;

procedure TfrmCallidusRadar.miFullCommunicationLogClick(Sender: TObject);
begin
  ProtocolePROTO_Radar.WriteDebug := miFullCommunicationLog.Checked;
end;

procedure TfrmCallidusRadar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfiguration;
end;

procedure TfrmCallidusRadar.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if VaCommRadar.Active then
  begin
    VaCommRadar.Close;
    Application.ProcessMessages;
    Sleep(100);
    Application.ProcessMessages;
  end;
end;

procedure TfrmCallidusRadar.FormCreate(Sender: TObject);
begin
  iIndexApplication := GetApplicationNbOfThisClass(Self.ClassName);
  ProtocolePROTO_Radar.ComplementDeviceName := Format('Instance%.2d', [iIndexApplication]);
  sbNetwork.Panels[IDX_PANEL_VERSION].Text := sCALLIDUS_SYSTEM_VERSION;
  sbNetwork.Panels[IDX_PANEL_APPLICATIONO].Text := IntToStr(iIndexApplication);
  Caption := Application.Title + ' ' + sCALLIDUS_SYSTEM_VERSION;
  isFirstActivation := True;
  NomFichierConfiguration := GetConfigFilename('CallidusRadar');
  bMonitorSpeed := FALSE;
  PopulatecbComPort;
  cbComPort.Hint := 'Detected COM port are in green' + #$0A + 'Not detected are in red' + #$0A + 'Right click on drop box to refresh list';
  VaCommRadar.OnRxChar := VaCommRadarRxChar;
  sbNetwork.Panels[IDX_PANEL_LOCALIP].Text := 'local:' + GetLocalIpAddress;
  bCurrentlyDoingNetworkCycleTest := False;
end;

procedure TfrmCallidusRadar.RefreshDisplayedParameterTable(paramShowReadBackValues: boolean);
var
  iPage, iParam, iPageTarget, iCol: integer;
  NewSheet: TTabSheet;
  NewAdvStringGrid: TAdvStringGrid;
  RememberPageIndex: integer;

  procedure PopulateThisLine(RowIndex, ParamIndex: integer);
  var
    StringToShow: string;
  begin
    NewAdvStringGrid.GridCells[COL_INDEX, RowIndex] := IntToStr(ParamIndex);
    NewAdvStringGrid.GridCells[COL_SETTINGS, RowIndex] := WorkingRadarConfig.Parameter[ParamIndex].Name;

    if paramShowReadBackValues then
    begin
      case WorkingRadarConfig.Parameter[ParamIndex].DataType of
        1:
          StringToShow := WorkingRadarConfig.Parameter[ParamIndex].Value_Items_Display.Strings[WorkingRadarConfig.Parameter[ParamIndex].Value_Items_Firmware.IndexOf(IntToStr(WorkingRadarConfig.Parameter[ParamIndex].ReadBack_Value))];
        2:
          StringToShow := IntToStr(WorkingRadarConfig.Parameter[ParamIndex].ReadBack_Value);
      else
        StringToShow := 'error...';
      end;
      NewAdvStringGrid.GridCells[COL_SENSORVAL, RowIndex] := StringToShow;
    end;

    case WorkingRadarConfig.Parameter[ParamIndex].DataType of
      1:
        StringToShow := WorkingRadarConfig.Parameter[ParamIndex].Value_Items_Display.Strings[WorkingRadarConfig.Parameter[ParamIndex].Value_Items_Firmware.IndexOf(IntToStr(WorkingRadarConfig.Parameter[ParamIndex].Proposed_Value))];
      2:
        StringToShow := IntToStr(WorkingRadarConfig.Parameter[ParamIndex].Proposed_Value);
    else
      StringToShow := 'error...';
    end;
    NewAdvStringGrid.GridCells[COL_PROPOSEVAL, RowIndex] := StringToShow;

    case WorkingRadarConfig.Parameter[ParamIndex].DataType of
      1:
        StringToShow := WorkingRadarConfig.Parameter[ParamIndex].Value_Items_Display.Strings[WorkingRadarConfig.Parameter[ParamIndex].Value_Items_Firmware.IndexOf(IntToStr(WorkingRadarConfig.Parameter[ParamIndex].Default_Value))];
      2:
        StringToShow := IntToStr(WorkingRadarConfig.Parameter[ParamIndex].Default_Value);
    else
      StringToShow := 'error...';
    end;
    NewAdvStringGrid.GridCells[COL_DEFAULTVAL, RowIndex] := StringToShow;

    if WorkingRadarConfig.Parameter[ParamIndex].ValueMin <> WorkingRadarConfig.Parameter[ParamIndex].ValueMax then
      NewAdvStringGrid.GridCells[COL_RANGE, RowIndex] := IntToStr(WorkingRadarConfig.Parameter[ParamIndex].ValueMin) + ' - ' + IntToStr(WorkingRadarConfig.Parameter[ParamIndex].ValueMax);
  end;

begin
  if pcConfigParam.PageCount > 0 then
    RememberPageIndex := pcConfigParam.ActivePageIndex
  else
    RememberPageIndex := -1;

  for iPage := pred(pcConfigParam.PageCount) downto 0 do
    pcConfigParam.Pages[iPage].Free;

  for iParam := 0 to pred(WorkingRadarConfig.Count) do
  begin
    if WorkingRadarConfig.Parameter[iParam].Command_ID = 42 then
      IndexCommandeTransmitControl := iParam;
    if WorkingRadarConfig.Parameter[iParam].Command_ID = 37 then
      IndexCommandReadProductID := iParam;

    if WorkingRadarConfig.Parameter[iParam].Display = 1 then
    begin
      iPageTarget := -1;
      iPage := 0;
      while (iPageTarget = -1) and (iPage < pcConfigParam.PageCount) do
      begin
        if pcConfigParam.Pages[iPage].Caption = WorkingRadarConfig.Parameter[iParam].ConfigTypeName then
          iPageTarget := iPage
        else
          inc(iPage);
      end;

      if iPageTarget <> -1 then
      begin
        NewSheet := pcConfigParam.Pages[iPageTarget];
        NewAdvStringGrid := TAdvStringGrid(NewSheet.Components[0]);
        NewAdvStringGrid.RowCount := NewAdvStringGrid.RowCount + 1;
        PopulateThisLine(pred(NewAdvStringGrid.RowCount), iParam);
      end
      else
      begin
        NewSheet := TTabSheet.Create(pcConfigParam);
        NewSheet.Name := 'Page' + IntToStr(pcConfigParam.PageCount);
        NewSheet.Parent := pcConfigParam;
        NewSheet.PageControl := pcConfigParam;
        NewSheet.Caption := WorkingRadarConfig.Parameter[iParam].ConfigTypeName;
        NewSheet.Visible := True;

        NewAdvStringGrid := TAdvStringGrid.Create(NewSheet);
        NewAdvStringGrid.Parent := NewSheet;
        NewAdvStringGrid.Name := 'Grid' + IntToStr(pcConfigParam.PageCount);
        NewAdvStringGrid.Align := alClient;
        NewAdvStringGrid.RowCount := 2;
        NewAdvStringGrid.ColCount := NBCOLMAX;
        NewAdvStringGrid.FixedCols := 1;
        NewAdvStringGrid.FixedRows := 1;
        NewAdvStringGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing];
        NewAdvStringGrid.GridCells[COL_INDEX, 0] := 'Index';
        NewAdvStringGrid.GridCells[COL_SETTINGS, 0] := 'Settings';
        NewAdvStringGrid.GridCells[COL_SENSORVAL, 0] := 'Sensor Value';
        NewAdvStringGrid.GridCells[COL_PROPOSEVAL, 0] := 'Proposed Value';
        NewAdvStringGrid.GridCells[COL_DEFAULTVAL, 0] := 'Default Value';
        NewAdvStringGrid.GridCells[COL_RANGE, 0] := 'Valid Range';
        NewAdvStringGrid.OnCanEditCell := AdvAnyGridCanEditCell;
        NewAdvStringGrid.OnGetEditorType := AdvAnyGridGetEditorType;
        NewAdvStringGrid.OnEditCellDone := AdvAnyGridEditCellDone;
        NewAdvStringGrid.OnGetCellColor := AdvAnyGridGetCellColor;
        PopulateThisLine(1, iParam);
        Application.ProcessMessages;
      end;

    end;
  end;

  for iPage := 0 to pred(pcConfigParam.PageCount) do
  begin
    NewSheet := pcConfigParam.Pages[iPage];
    NewAdvStringGrid := TAdvStringGrid(NewSheet.Components[0]);
    for iCol := 0 to pred(NewAdvStringGrid.ColCount) do
      NewAdvStringGrid.AutoSizeCol(iCol);

    NewAdvStringGrid.ColWidths[0] := 0;
  end;

  pcConfigParam.ActivePageIndex := -1;
  if RememberPageIndex > -1 then
  begin
    if RememberPageIndex < pcConfigParam.PageCount then
      pcConfigParam.ActivePageIndex := RememberPageIndex
    else if pcConfigParam.PageCount > 0 then
      pcConfigParam.ActivePageIndex := 0;
  end
  else
  begin
    if pcConfigParam.PageCount > 0 then
      pcConfigParam.ActivePageIndex := 0;
  end;
end;

procedure TfrmCallidusRadar.PopulatecbComPort;
var
  RememberIndex: longint;
  ListeDesComm: TStringList;
  IndexCom: longint;
  StringToAdd: string;
begin
  RememberIndex := cbComPort.ItemIndex;

  cbComPort.Clear;
  ListeDesComm := TStringList.Create;
  ListeDesComm.Sort;
  VaCommRadar.GetComPortNames(ListeDesComm);
  for IndexCom := 1 to 255 do
  begin
    StringToAdd := 'COM' + Format('%d', [IndexCom]);
    if ListeDesComm.IndexOf(StringToAdd) <> -1 then
      cbComPort.Items.Add('1' + StringToAdd)
    else
      cbComPort.Items.Add('0' + StringToAdd);
  end;
  ListeDesComm.Free;

  cbComPort.ItemIndex := RememberIndex;
  if cbComPort.ItemIndex = -1 then
    cbComPort.ItemIndex := 0;

  cbComPort.Style := csOwnerDrawFixed;
  cbComPort.DropDownCount := 20;

  cbComPort.Repaint;
end;

procedure TfrmCallidusRadar.cbComPortDrawItem(Control: TWinControl; Index: integer; Rect: TRect; State: TOwnerDrawState);
var
  StringToShow: string;
begin
  with Control as TComboBox do
  begin
    StringToShow := Items.Strings[Index];

    if odSelected in State then
    begin
      if StringToShow[1] = '0' then
        Canvas.brush.Color := clRed
      else
        Canvas.brush.Color := clGreen;
      if Enabled then
        Canvas.font.Color := clWhite
      else
        Canvas.font.Color := clSilver;
    end
    else
    begin
      if StringToShow[1] = '0' then
        Canvas.font.Color := clRed
      else
        Canvas.font.Color := clGreen;
      if Enabled then
        Canvas.brush.Color := clWhite
      else
        Canvas.brush.Color := clSilver;
    end;

    Canvas.FillRect(Rect);

    Canvas.textout(Rect.Left, Rect.Top, copy(StringToShow, 2, length(StringToShow) - 1));
  end;
end;

procedure TfrmCallidusRadar.cbDetectNetworkClick(Sender: TObject);
begin
  cbDetectRadar.Enabled := cbDetectNetwork.Checked;
  cbDetectRadarClick(cbDetectRadar);
end;

procedure TfrmCallidusRadar.cbDetectRadarClick(Sender: TObject);
begin
  cbLanceMonitoring.Enabled := cbDetectRadar.Enabled and cbDetectRadar.Checked;
end;

procedure TfrmCallidusRadar.ChangeServiceSettingClick(Sender: TObject);
begin
  btnApply.Enabled := TRUE;
end;

function GetDisplayableStuff(A: AnsiString): AnsiString;
var
  iChar: integer;
begin
  result := '';
  for iChar := 1 to length(A) do
    if (ord(A[iChar]) >= $20) and (ord(A[iChar]) < $80) then
      result := result + A[iChar]
    else
      result := result + AnsiString(Format('<0x%2.2X>', [ord(A[iChar])]));
end;

function CharChainToString(A: AnsiString; bSpaceBetween: boolean = True; bReverse: boolean = FALSE): AnsiString;
var
  Index: integer;
  B: AnsiString;
begin
  result := '';

  if bReverse then
  begin
    B := A;
    A := '';
    for Index := length(B) downto 1 do
      A := A + B[Index];
  end;

  for Index := 1 to length(A) do
  begin
    if bSpaceBetween and (Index > 1) then
      result := result + ' ';
    result := result + AnsiString(Format('%2.2X', [ord(A[Index])]));
  end;
end;

function GetTimeString(paramMoment: TDateTime): string;
var
  MyHour, MyMin, MySec, MyMilliSec: word;
begin
  Decodetime(paramMoment, MyHour, MyMin, MySec, MyMilliSec);
  result := Format('%2.2d:%2.2d:%2.2d.%3.3d', [MyHour, MyMin, MySec, MyMilliSec]);
end;

function HexStringToCharChain(A: AnsiString; bReverse: boolean = FALSE): AnsiString;
var
  Index: integer;
  B, sSingleByte: AnsiString;
begin
  result := '';

  A := AnsiStrings.StringReplace(A, ' ', '', [rfReplaceAll]);
  if length(A) mod 2 = 1 then
    A := '0' + A;

  for Index := 0 to pred(length(A) div 2) do
  begin
    sSingleByte := '0x' + copy(A, (Index * 2) + 1, 2);
    result := result + AnsiChar(StrToIntDef(sSingleByte, 0));
  end;

  if bReverse then
  begin
    B := result;
    result := '';
    for Index := length(B) downto 1 do
      result := result + B[Index];
  end;
end;

{$R-}

function ComputeStalkerChecksum(A: AnsiString): word;
var
  Index: integer;
begin
  result := $0000;
  for Index := 1 to length(A) do
  begin
    if Index mod 2 = 0 then
      result := result + (256 * ord(A[Index]))
    else
      result := result + ord(A[Index]);
  end;
end;
{$R+}

function TfrmCallidusRadar.SendReceiveRadarParameter(RadarAddress, IndexParameter: integer; paramMethod: TRadarMethod; paramNoVerification: boolean = FALSE): boolean;
var
  sValue, PacketToSend: AnsiString;
  iValue: int64;
  PayloadLength, ExpectedAnswerLength: integer;
  MyChecksum, ComputedRadarChecksum, ExpectedRadarChecksum: word;
  MyTimeout: dword;
  ConfigurationValue: AnsiString;
  clCodePourCouleurError: dword;
  dwTimeoutValue: dword;
  realTimeoutValue, realTempsDeUnByte: real;
begin
  result := FALSE;

  if not paramNoVerification then
  begin
    clCodePourCouleurError := COLORERROR
  end
  else
  begin
    clCodePourCouleurError := COLORSTATUS;
    WriteStatusLg('For this particular command at this moment, we won''t validate the answer...', 'Pour cette commande particulière à ce moment, on ne validera pas la réponse...', COLORDANGER);
  end;

  try
    case paramMethod of
      rm_GetMethod:
        ConfigurationValue := AnsiChar($00);
      rm_ChangeMethod:
        ConfigurationValue := AnsiChar($01);
      rm_SetMethod:
        ConfigurationValue := HexStringToCharChain(AnsiString(Format('%X', [WorkingRadarConfig.Parameter[IndexParameter].Proposed_Value])), True);
    end;
    PayloadLength := 1 + 1 + length(ConfigurationValue); // 2015-11-26:DB-Initially I made a mistake and was including the checksum in the lenght... This has been fixed.

    // 01:Start ID
    PacketToSend := AnsiChar($EF);

    // 02:Destination Address
    PacketToSend := PacketToSend + AnsiChar(RadarAddress);

    // 03:Source Address
    PacketToSend := PacketToSend + AnsiChar($01);

    // 04:Packet Type
    PacketToSend := PacketToSend + AnsiChar(WorkingRadarConfig.Parameter[IndexParameter].Packet_Type);

    // 05:PayloadLength (LSB) The Payload Length is a 2-byte word which is the number of bytes starting with byte #7 through and
    // including the last byte before the checksum bytes.
    PacketToSend := PacketToSend + AnsiChar(PayloadLength and $FF);

    // 06:PayloadLength (MSB)
    PacketToSend := PacketToSend + AnsiChar((PayloadLength shr 8) and $FF);

    // 07:Command ID
    case paramMethod of
      rm_GetMethod:
        PacketToSend := PacketToSend + AnsiChar(WorkingRadarConfig.Parameter[IndexParameter].Command_ID);
      rm_ChangeMethod:
        PacketToSend := PacketToSend + AnsiChar(WorkingRadarConfig.Parameter[IndexParameter].Command_ID);
      rm_SetMethod:
        PacketToSend := PacketToSend + AnsiChar((WorkingRadarConfig.Parameter[IndexParameter].Command_ID or $80));
    else
      PacketToSend := PacketToSend + AnsiChar(WorkingRadarConfig.Parameter[IndexParameter].Command_ID);
    end;

    // 08:Antenna Number
    PacketToSend := PacketToSend + AnsiChar($00);

    // 09:Configuration Value
    PacketToSend := PacketToSend + ConfigurationValue;

    // 10:Checksum (LSB)
    MyChecksum := ComputeStalkerChecksum(PacketToSend);
    PacketToSend := PacketToSend + AnsiChar(MyChecksum and $FF);

    // 11:Checksum (MSB)
    PacketToSend := PacketToSend + AnsiChar((MyChecksum shr 8) and $FF);

    if EstablishConnexionWithRadar then
    begin
      case paramMethod of
        rm_GetMethod:
          WriteStatusLg(';Getting ' + WorkingRadarConfig.Parameter[IndexParameter].Name + '...', '', COLORINFO);
        rm_ChangeMethod:
          WriteStatusLg(';Changing ' + WorkingRadarConfig.Parameter[IndexParameter].Name + '...', '', COLORINFO);
        rm_SetMethod:
          WriteStatusLg(';Writing ' + WorkingRadarConfig.Parameter[IndexParameter].Name + '...', '', COLORINFO);
      end;
      WriteStatusLg('>' + CharChainToString(PacketToSend), '', COLORTX);
      RadarAnswer := '';
      bCurrentlyWaitingEF := True;

      // 2015-12-28:DB-Notre temps pour le timeout est dynamique: plus on est lent, plus le timeout est long.
      realTempsDeUnByte := ((1 / VaCommRadar.UserBaudrate) * 10 * 1000);
      realTimeoutValue := (realTempsDeUnByte * 30); // On lui laisse le temps de répondre à la commande précédente.
      realTimeoutValue := realTimeoutValue + (realTempsDeUnByte * (length(PacketToSend))); // Le temps que nos bytes à nous parte.
      realTimeoutValue := realTimeoutValue + 350; //Valeur de base, temps de réaction à répondre à une commande de même que le temps de la couche Windows à pitcher effectivement les bytes.
      realTimeoutValue := realTimeoutValue + (realTempsDeUnByte * 30); // Sa réponse, en supposant une trentaine de byte.
      dwTimeoutValue := Trunc(realTimeoutValue) + 1; //Le +1 pour tenir compte d'éventuel arrondi...
      MyTimeout := GetTickCount + dwTimeoutValue;

      VaCommRadar.WriteText(PacketToSend);
      iTxOverallCount := iTxOverallCount + length(PacketToSend);
      sbRadar.Panels[IDX_PANEL_TX].Text := Format('Tx:%d', [iTxOverallCount]);

      while ((GetTickCount < MyTimeout) and (bCurrentlyWaitingEF)) do
      begin
        Sleep(1);
        if bCurrentlyWaitingEF then
          Application.ProcessMessages;
      end;

      if not bCurrentlyWaitingEF then
      begin
        while ((GetTickCount < MyTimeout) and (length(RadarAnswer) < 8)) do
        begin
          Sleep(1);
          if length(RadarAnswer) < 8 then
            Application.ProcessMessages;
        end;

        if length(RadarAnswer) >= 8 then
        begin
          if chkbNoRadarFakeAnswer.Checked then
          begin
            RadarAnswer[2] := PacketToSend[3];
            RadarAnswer[3] := PacketToSend[2];
          end;

          if (ord(RadarAnswer[1]) = ord(PacketToSend[1])) and (ord(RadarAnswer[2]) = ord(PacketToSend[3])) and (ord(RadarAnswer[3]) = ord(PacketToSend[2])) and (ord(RadarAnswer[4]) = ord(PacketToSend[4])) and (ord(RadarAnswer[7]) = ord(PacketToSend[7])) and (ord(RadarAnswer[8]) = ord(PacketToSend[8])) and (ord(RadarAnswer[6]) = $00) then
          begin
            if chkbNoRadarFakeAnswer.Checked then
            begin
              RadarAnswer[2] := PacketToSend[2];
              RadarAnswer[3] := PacketToSend[3];
            end;

            ExpectedAnswerLength := 6 + ord(RadarAnswer[5]) + (ord(RadarAnswer[6]) * 256) + 2; // 2015-11-26:DB-Initially I forget to add the 2-bytes of the checksum. This has been fixed.
            while ((GetTickCount < MyTimeout) and (length(RadarAnswer) < ExpectedAnswerLength)) do
            begin
              Sleep(1);
              if length(RadarAnswer) < ExpectedAnswerLength then
                Application.ProcessMessages;
            end;

            if length(RadarAnswer) >= ExpectedAnswerLength then
            begin
              ComputedRadarChecksum := ComputeStalkerChecksum(copy(RadarAnswer, 1, (ExpectedAnswerLength - 2)));
              ExpectedRadarChecksum := ord(RadarAnswer[ExpectedAnswerLength - 1]) + (ord(RadarAnswer[ExpectedAnswerLength]) shl 8);
              if ComputedRadarChecksum = ExpectedRadarChecksum then
              begin
                WriteStatusLg('<' + CharChainToString(RadarAnswer), '', COLORRX);

                try
                  if paramMethod = rm_GetMethod then
                  begin
                    sValue := '0x' + CharChainToString(copy(RadarAnswer, 9, (ExpectedAnswerLength - 10)), FALSE, True);
                    iValue := StrToIntDef(sValue, 0);

                    case WorkingRadarConfig.Parameter[IndexParameter].DataType of
                      1:
                        begin
                          if chkbNoRadarFakeAnswer.Checked then
                            WorkingRadarConfig.Parameter[IndexParameter].ReadBack_Value := WorkingRadarConfig.Parameter[IndexParameter].Default_Value
                          else
                            WorkingRadarConfig.Parameter[IndexParameter].ReadBack_Value := iValue;
                        end;
                      2:
                        begin
                          if chkbNoRadarFakeAnswer.Checked then
                            WorkingRadarConfig.Parameter[IndexParameter].ReadBack_Value := WorkingRadarConfig.Parameter[IndexParameter].Default_Value
                          else
                            WorkingRadarConfig.Parameter[IndexParameter].ReadBack_Value := iValue;
                        end;
                    else
                      begin
                        WorkingRadarConfig.Parameter[IndexParameter].ReadBack_Value := 0;
                      end;
                    end;
                  end;
                except
                  WriteStatusLg('DEBUG chez FB: ' + CharChainToString(RadarAnswer), '', clBLUE);
                end;

                result := True;
              end
              else
              begin
                WriteStatusLg('<' + CharChainToString(RadarAnswer), '', clCodePourCouleurError);
                WriteStatusLg('ERROR: Answer packet seems corrupted based on checksum...', '', clCodePourCouleurError);
                WriteStatusLg('Checksum expected: 0x' + Format('%4.4X', [ExpectedRadarChecksum]), '', clCodePourCouleurError);
                WriteStatusLg('Checksum computed: 0x' + Format('%4.4X', [ComputedRadarChecksum]), '', clCodePourCouleurError);
                if paramNoVerification then
                  WriteStatusLg('But we will continue anyway as mentionned earlier...', 'Mais nous allons continuer comme mentionner plus haut...', clCodePourCouleurError);
              end;
            end
            else
            begin
              WriteStatusLg('<' + CharChainToString(RadarAnswer), '', clCodePourCouleurError);
              WriteStatusLg('ERROR: Answer seems partial, imcomplete answer to last command...', '', clCodePourCouleurError);
              if paramNoVerification then
                WriteStatusLg('But we will continue anyway as mentionned earlier...', 'Mais nous allons continuer comme mentionner plus haut...', clCodePourCouleurError);
            end;
          end
          else
          begin
            WriteStatusLg('<' + CharChainToString(RadarAnswer), '', clCodePourCouleurError);
            WriteStatusLg('ERROR: Invalid answer, no need to analyze it...', '', clCodePourCouleurError);
            if paramNoVerification then
              WriteStatusLg('But we will continue anyway as mentionned earlier...', 'Mais nous allons continuer comme mentionner plus haut...', clCodePourCouleurError);
          end;
        end
        else
        begin
          WriteStatusLg('<' + CharChainToString(RadarAnswer), '', clCodePourCouleurError);
          WriteStatusLg('ERROR: Imcomplete answer to last command...', '', clCodePourCouleurError);
          if paramNoVerification then
            WriteStatusLg('But we will continue anyway as mentionned earlier...', 'Mais nous allons continuer comme mentionner plus haut...', clCodePourCouleurError);
        end;
      end;
    end;
  except
    result := FALSE;
  end;
end;

function TfrmCallidusRadar.EstablishConnexionWithRadar: boolean;
begin
  result := FALSE;

  try
    if not VaCommRadar.Active then
    begin
      VaCommRadar.PortNum := (cbComPort.ItemIndex + 1);
      //    VaCommRadar.UserBaudrate := 9600;
      VaCommRadar.Baudrate := brUser;
      VaCommRadar.Parity := paNone;
      VaCommRadar.Databits := db8;
      VaCommRadar.Stopbits := sb1;
      iRxOverallCount := 0;
      iTxOverallCount := 0;
      VaCommRadar.Open;
    end;

    if VaCommRadar.Active then
    begin
      cbComPort.Enabled := FALSE;
      RefreshConfigRadarStatusBar;
      result := True;
    end;
  except
    result := FALSE;
  end;
end;

procedure TfrmCallidusRadar.RefreshConfigRadarStatusBar;
begin
  sbRadar.Panels[IDX_PANEL_COM].Text := ifThen(VaCommRadar.Active, 'CONNECTED on COM' + IntToStr(VaCommRadar.PortNum), 'Disconnected from COM' + IntToStr(VaCommRadar.PortNum));
  sbRadar.Panels[IDX_PANEL_RX].Text := Format('Rx:%d', [iRxOverallCount]);
  sbRadar.Panels[IDX_PANEL_TX].Text := Format('Tx:%d', [iTxOverallCount]);
  sbRadar.Panels[IDX_PANEL_SERVICESPEEDSTATEMACHINE].Text := '';
  sbRadar.Panels[IDX_PANEL_SERVICETIMESHOWN].Text := '';
end;

procedure TfrmCallidusRadar.VaCommRadarClose(Sender: TObject);
begin
  cbComPort.Enabled := True;
  RefreshConfigRadarStatusBar;
end;

procedure TfrmCallidusRadar.VaCommRadarRxChar(Sender: TObject; Count: integer);
var
  Pos0D, posEF: integer;
  sMsgToShow: AnsiString;
begin
  if Count > 0 then
  begin
    iRxOverallCount := iRxOverallCount + Count;
    sbRadar.Panels[IDX_PANEL_RX].Text := Format('Rx:%d', [iRxOverallCount]);
    RadarAnswer := RadarAnswer + VaCommRadar.ReadText;

    if bCurrentlyWaitingEF then
    begin
      posEF := pos(AnsiChar($EF), RadarAnswer);
      if (posEF > 0) then
      begin
        if (posEF <> 1) then
          RadarAnswer := AnsiStrings.RightStr(RadarAnswer, (length(RadarAnswer) - (posEF - 1)));
        bCurrentlyWaitingEF := FALSE;
      end;
    end;

    if bMonitorSpeed then
    begin
      Pos0D := pos(#$0D, RadarAnswer);
      if Pos0D <> 0 then
      begin
        sMsgToShow := AnsiStrings.LeftStr(RadarAnswer, pred(Pos0D));
        // sMsgToShow := AnsiStrings.stringReplace(sMsgToShow, ' ', '', [rfReplaceAll]);
        if sMsgToShow <> '' then
        begin
          WriteStatusLg('Rx - ' + GetDisplayableStuff(sMsgToShow), '', COLORINCOMINGSTREAM);
          if pos(AnsiChar($83), sMsgToShow) <> 0 then ProcessSpeedPacket(sMsgToShow);
        end;

        RadarAnswer := AnsiStrings.RightStr(RadarAnswer, length(RadarAnswer) - Pos0D);
        Application.ProcessMessages;
      end;
    end;
  end;
end;

procedure TfrmCallidusRadar.DisableToute;
var
  iAction: integer;
begin
  bMonitorSpeed := FALSE;
  for iAction := 0 to pred(ActionManagerRadarConfig.ActionCount) do
  begin
    case ActionManagerRadarConfig.Actions[iAction].Tag of
      998, 999: // 2015-12-10:DB-We don't disable the button to start the monitor, the toggle of the debug view, etc.
        begin
        end;
    else
      begin
        ActionManagerRadarConfig.Actions[iAction].Enabled := FALSE;
      end;
    end;

  end;
  frmDebugWindow.StatusWindow.Clear;
  frmDebugWindow.StatusWindow.Color := COLORBACK_WORKING;
  lblComPort.Enabled := FALSE;
  cbComPort.Enabled := FALSE;
  lblRadarAddress.Enabled := FALSE;
  cbRadarAddress.Enabled := FALSE;

  bOverAllActionResult := FALSE;
  InitialTabSheet := pcRadarPageControl.ActivePage;
end;

procedure TfrmCallidusRadar.EnableToute(bShowLogWindowIfError: boolean = True);
var
  iAction: integer;
  sNomFichierLog: string;
begin
  for iAction := 0 to pred(ActionManagerRadarConfig.ActionCount) do
    if (ActionManagerRadarConfig.Actions[iAction].Tag and $01) <> $01 then
      ActionManagerRadarConfig.Actions[iAction].Enabled := True;

  if bOverAllActionResult then
  begin
    frmDebugWindow.StatusWindow.Color := COLORBACK_SUCCESS;
    pcRadarPageControl.ActivePage := InitialTabSheet;
  end
  else
  begin
    frmDebugWindow.StatusWindow.Color := COLORBACK_ERROR;
    if bShowLogWindowIfError then
      if not frmDebugWindow.Visible then
        frmDebugWindow.Show;
  end;

  lblComPort.Enabled := True;
  cbComPort.Enabled := True;
  lblRadarAddress.Enabled := True;
  cbRadarAddress.Enabled := True;
  sNomFichierLog := GetLogFilename('', 'log', 'CallidusRadar');
  WriteStatusLg('Log will be saved under this name: ' + sNomFichierLog, 'Le journal sera sauvegarder sous le nom: ' + sNomFichierLog, COLORSTATUS);
  frmDebugWindow.StatusWindow.PlainText := True;
  frmDebugWindow.StatusWindow.Lines.SaveToFile(sNomFichierLog, TEncoding.ANSI);
end;

function TfrmCallidusRadar.SetTransmitterOnOrOff(StateWanted: boolean): boolean;
var
  RadarAddress: integer;
  bDoWithVerification: boolean;
begin
  // 2015-12-10:DB-Dans le cas qu'on demande à l'autre de cesser de pitcher, on va suivre le pattern suivant:
  // 1o) On envoie la commande en se fichant de savoir si ça a marché ou non.
  // 2o) On se ré-essaie une seconde fois et là on s'occupe de la réponse.
  RadarAddress := StrToIntDef(cbRadarAddress.Items.Strings[cbRadarAddress.ItemIndex], 2);
  cbRadarAddress.ItemIndex := RadarAddress - 2;
  WorkingRadarConfig.Parameter[IndexCommandeTransmitControl].Proposed_Value := Math.ifThen(StateWanted, $01, $00);
  if StateWanted = FALSE then
    bDoWithVerification := True
  else
    bDoWithVerification := FALSE;

  result := SendReceiveRadarParameter(RadarAddress, IndexCommandeTransmitControl, rm_SetMethod, bDoWithVerification);

  if (not result) and (StateWanted = FALSE) then
  begin
    result := SendReceiveRadarParameter(RadarAddress, IndexCommandeTransmitControl, rm_SetMethod);
  end;
end;

procedure TfrmCallidusRadar.actWriteSensorValueExecute(Sender: TObject);
var
  iParam, RadarAddress: integer;
  bKeepGoing: boolean;
begin
  DisableToute;
  try
    RadarAddress := StrToIntDef(cbRadarAddress.Items.Strings[cbRadarAddress.ItemIndex], 2);
    cbRadarAddress.ItemIndex := RadarAddress - 2;

    if SetTransmitterOnOrOff(FALSE) then
    begin
      bKeepGoing := True;

      // 1. First step, we'll scan our list and write ONLY the proposed settings that are different from the ones read back.
      iParam := 0;
      while (iParam < WorkingRadarConfig.Count) and (bKeepGoing) do
      begin
        if WorkingRadarConfig.Parameter[iParam].Display = 1 then
        begin
          if WorkingRadarConfig.Parameter[iParam].ReadBack_Value <> WorkingRadarConfig.Parameter[iParam].Proposed_Value then
            bKeepGoing := SendReceiveRadarParameter(RadarAddress, iParam, rm_SetMethod);
        end;
        inc(iParam);
      end;

      // 2. Second step, we read back ALL the settings.
      if bKeepGoing then
      begin
        iParam := 0;
        while (iParam < WorkingRadarConfig.Count) and (bKeepGoing) do
        begin
          if WorkingRadarConfig.Parameter[iParam].Display = 1 then
            bKeepGoing := SendReceiveRadarParameter(RadarAddress, iParam, rm_GetMethod);
          inc(iParam);
        end;
      end;

      if bKeepGoing then
      begin
        if SetTransmitterOnOrOff(True) then
        begin
          RefreshDisplayedParameterTable(True);
          bOverAllActionResult := True;
        end;
      end;

    end;
  finally
    EnableToute;
  end;
end;

{ TfrmCallidusRadar.tbTempsOffChange }
procedure TfrmCallidusRadar.ProcessSpeedPacket(sSpeedReceived: AnsiString);
var
  PeakSpeedToShow, LiveSpeedToShow: string;
  FreezeTickCount: dword;
begin
  FreezeTickCount := GetTickCount;

  if length(sSpeedReceived) = 18 then
  begin
    PeakSpeedToShow := copy(sSpeedReceived, 3, 4);
    PeakSpeedToShow := StringReplace(PeakSpeedToShow, ' ', '', [rfReplaceAll]);
    ServiceSpeed.CurrentPeakSpeed := StrToIntDef(PeakSpeedToShow, 0);

    if (PeakSpeedToShow <> '') then
    begin
      if (sSpeedReceived[2] = 'C') then
      begin
        PeakSpeedToShow := '+' + PeakSpeedToShow;
        ServiceSpeed.CurrentPeekDirection := 1;
      end
      else
      begin
        PeakSpeedToShow := '-' + PeakSpeedToShow;
        ServiceSpeed.CurrentPeekDirection := 2;
      end;
    end;

    LiveSpeedToShow := copy(sSpeedReceived, 8, 4);
    LiveSpeedToShow := StringReplace(LiveSpeedToShow, ' ', '', [rfReplaceAll]);
    ServiceSpeed.CurrentLiveSpeed := StrToIntDef(LiveSpeedToShow, 0);

    if LiveSpeedToShow <> '' then
    begin
      if (sSpeedReceived[7] = 'C') then
        LiveSpeedToShow := '+' + LiveSpeedToShow
      else
        LiveSpeedToShow := '-' + LiveSpeedToShow;
    end;
  end
  else
  begin
    ServiceSpeed.CurrentPeakSpeed := 0;
    ServiceSpeed.CurrentPeekDirection := 0;
    ServiceSpeed.CurrentLiveSpeed := 0;
  end;

  case ServiceSpeed.StateMachine of
    tsmss_WAITING_SERVICE: // On attend un service...
      begin
        if (ServiceSpeed.CurrentPeakSpeed >= ServiceSpeed.LowLimitServiceSpeed) and (ServiceSpeed.CurrentPeakSpeed <= ServiceSpeed.HighLimitServiceSpeed) then
        begin
          FaisRemonterLeServiceSpeed(addr(ServiceSpeed));
          ServiceSpeed.StateMachine := tsmss_WAITINGIDLE;
          ServiceSpeed.TickCountToSwitchBackToWaitingService := FreezeTickCount + ServiceSpeed.TimeInactivitySpeed;
          ServiceSpeed.TickCountToStopShowingService := FreezeTickCount + ServiceSpeed.TimeToShowServiceSpeed;
          sbRadar.Panels[IDX_PANEL_SERVICESPEEDSTATEMACHINE].Text := 'WAITING IDLE: ' + IntToStr(ServiceSpeed.TickCountToSwitchBackToWaitingService - FreezeTickCount);
          sbRadar.Panels[IDX_PANEL_SERVICETIMESHOWN].Text := 'SHOW SERVICE: ' + IntToStr(ServiceSpeed.TickCountToStopShowingService - FreezeTickCount);
        end
        else
        begin
          // Let's check if it's time to hide the last service speed...
          if (FreezeTickCount > ServiceSpeed.TickCountToStopShowingService) and (ServiceSpeed.TickCountToStopShowingService <> $FFFFFFFF) then
          begin
            ServiceSpeed.TickCountToStopShowingService := $FFFFFFFF;
            if ServiceSpeed.TimeToShowServiceSpeed <> 0 then
            begin
              FaisRemonterLeServiceSpeed(nil);
              sbRadar.Panels[IDX_PANEL_SERVICETIMESHOWN].Text := '';
            end;
          end
          else
          begin
            if ServiceSpeed.TickCountToStopShowingService <> $FFFFFFFF then
              sbRadar.Panels[IDX_PANEL_SERVICETIMESHOWN].Text := 'SHOW SERVICE: ' + IntToStr(ServiceSpeed.TickCountToStopShowingService - FreezeTickCount);
          end;
        end;
      end;

    tsmss_WAITINGIDLE:
      begin
        // Let's check if it's time to hide the last service speed...
        if (FreezeTickCount > ServiceSpeed.TickCountToStopShowingService) and (ServiceSpeed.TickCountToStopShowingService <> $FFFFFFFF) then
        begin
          ServiceSpeed.TickCountToStopShowingService := $FFFFFFFF;
          if ServiceSpeed.TimeToShowServiceSpeed <> 0 then
          begin
            FaisRemonterLeServiceSpeed(nil);
            sbRadar.Panels[IDX_PANEL_SERVICETIMESHOWN].Text := '';
          end;
        end
        else
        begin
          if ServiceSpeed.TickCountToStopShowingService <> $FFFFFFFF then
            sbRadar.Panels[IDX_PANEL_SERVICETIMESHOWN].Text := 'SHOW SERVICE: ' + IntToStr(ServiceSpeed.TickCountToStopShowingService - FreezeTickCount);
        end;

        //
        if (ServiceSpeed.CurrentLiveSpeed >= ServiceSpeed.LowLimitInactivitySpeed) and (ServiceSpeed.CurrentLiveSpeed <= ServiceSpeed.HighLimitInactivitySpeed) then
        begin
          ServiceSpeed.TickCountToSwitchBackToWaitingService := FreezeTickCount + ServiceSpeed.TimeInactivitySpeed;
          sbRadar.Panels[IDX_PANEL_SERVICESPEEDSTATEMACHINE].Text := 'WAITING IDLE: ' + IntToStr(ServiceSpeed.TickCountToSwitchBackToWaitingService - FreezeTickCount);
        end
        else
        begin
          if FreezeTickCount > ServiceSpeed.TickCountToSwitchBackToWaitingService then
          begin
            ServiceSpeed.StateMachine := tsmss_WAITING_SERVICE;
            sbRadar.Panels[IDX_PANEL_SERVICESPEEDSTATEMACHINE].Text := 'WAITING SERVICE';
          end
          else
          begin
            sbRadar.Panels[IDX_PANEL_SERVICESPEEDSTATEMACHINE].Text := 'WAITING IDLE: ' + IntToStr(ServiceSpeed.TickCountToSwitchBackToWaitingService - FreezeTickCount);
          end;
        end;
      end;
  end;
end;

procedure TfrmCallidusRadar.SetVisibleServiceSpeedParamFromVariable;
begin
  edLowServiceSpeed.Text := IntToStr(ServiceSpeed.LowLimitServiceSpeed);
  edHighServiceSpeed.Text := IntToStr(ServiceSpeed.HighLimitServiceSpeed);
  edShowTimeServiceSpeed.Text := IntToStr(ServiceSpeed.TimeToShowServiceSpeed);
  edLowInactivitySpeed.Text := IntToStr(ServiceSpeed.LowLimitInactivitySpeed);
  edHighInactivitySpeed.Text := IntToStr(ServiceSpeed.HighLimitInactivitySpeed);
  edInactivityTime.Text := IntToStr(ServiceSpeed.TimeInactivitySpeed);
end;

procedure TfrmCallidusRadar.SetVariableFromVisibleServiceSpeedParam;
begin
  ServiceSpeed.LowLimitServiceSpeed := StrToIntDef(edLowServiceSpeed.Text, 50);
  ServiceSpeed.HighLimitServiceSpeed := StrToIntDef(edHighServiceSpeed.Text, 200);
  ServiceSpeed.TimeToShowServiceSpeed := StrToIntDef(edShowTimeServiceSpeed.Text, 2000);
  ServiceSpeed.LowLimitInactivitySpeed := StrToIntDef(edLowInactivitySpeed.Text, 40);
  ServiceSpeed.HighLimitInactivitySpeed := StrToIntDef(edHighInactivitySpeed.Text, 200);
  ServiceSpeed.TimeInactivitySpeed := StrToIntDef(edInactivityTime.Text, 5000);
  SetVisibleServiceSpeedParamFromVariable;
  btnApply.Enabled := FALSE;
end;

procedure TfrmCallidusRadar.WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
begin
  if sDebugLineFrench = '' then
    sDebugLineFrench := sDebugLineEnglish;
  frmDebugWindow.StatusWindow.WriteStatusLg(sDebugLineEnglish, sDebugLineFrench, clColorRequested);
end;

procedure TfrmCallidusRadar.LoadConfiguration;
var
  ConfigFile: TIniFile;
  sConfigSectionName, sMaybeCom, sMaybeAddress: string;
  iIndex: integer;
  bDebugWasVisible: boolean;
begin
  sConfigSectionName := Format('Config%.2d', [iIndexApplication]);

  ConfigFile := TIniFile.Create(NomFichierConfiguration);
  try
    with ConfigFile do
    begin
      LoadWindowConfig(ConfigFile, Self, sConfigSectionName);
      LoadWindowConfig(ConfigFile, frmDebugWindow, 'Debug' + sConfigSectionName);
      pcRadarPageControl.ActivePageIndex := ReadInteger(sConfigSectionName, 'pcRadarPageControl', 0);
      edConfigFile.Text := ReadString(sConfigSectionName, 'edConfigFile', '');
      cbRadarAddress.Clear;
      for iIndex := 2 to 254 do
        cbRadarAddress.Items.Add(IntToStr(iIndex));
      sMaybeAddress := ReadString(sConfigSectionName, 'cbRadarAddress', '2');
      if cbRadarAddress.Items.IndexOf(sMaybeAddress) <> -1 then
        cbRadarAddress.ItemIndex := cbRadarAddress.Items.IndexOf(sMaybeAddress)
      else
        cbRadarAddress.ItemIndex := 0;
      sMaybeCom := ReadString(sConfigSectionName, 'RadarPortNumber', 'COM1');
      if cbComPort.Items.IndexOf(sMaybeCom) <> -1 then
        cbComPort.ItemIndex := cbComPort.Items.IndexOf(sMaybeCom)
      else if cbComPort.Items.Count > 0 then
        cbComPort.ItemIndex := 0;
      VaCommRadar.PortNum := (cbComPort.ItemIndex + 1);
      RefreshConfigRadarStatusBar;

      ServiceSpeed.LowLimitServiceSpeed := ReadInteger(sConfigSectionName, 'LowLimitServiceSpeed', 50);
      ServiceSpeed.HighLimitServiceSpeed := ReadInteger(sConfigSectionName, 'HighLimitServiceSpeed', 200);
      ServiceSpeed.TimeToShowServiceSpeed := ReadInteger(sConfigSectionName, 'TimeToShowServiceSpeed', 2000);
      ServiceSpeed.LowLimitInactivitySpeed := ReadInteger(sConfigSectionName, 'LowLimitInactivitySpeed', 40);
      ServiceSpeed.HighLimitInactivitySpeed := ReadInteger(sConfigSectionName, 'HighLimitInactivitySpeed', 200);
      ServiceSpeed.TimeInactivitySpeed := ReadInteger(sConfigSectionName, 'TimeInactivitySpeed', 5000);
      SetVisibleServiceSpeedParamFromVariable;
      bDebugWasVisible := ReadBool(sConfigSectionName, 'bDebugWasVisible', FALSE);
      if bDebugWasVisible then
        frmDebugWindow.Show;
      cbSaveLogEachTimeWhenQuiting.Checked := ReadBool(sConfigSectionName, 'cbSaveLogEachTimeWhenQuiting', True);
      miFullCommunicationLog.Checked := ReadBool(sConfigSectionName, 'miFullCommunicationLog', FALSE);
      //miFullCommunicationLog.Checked := False;
      miFullCommunicationLogClick(miFullCommunicationLog);
      cbKeepRetryingAutodetect.Checked := ReadBool(sConfigSectionName, 'cbKeepRetryingAutodetect', TRUE);
      cbTryAllBaudRate.Checked := ReadBool(sConfigSectionName, 'cbTryAllBaudRate', FALSE);
      cbDetectNetwork.Checked := ReadBool(sConfigSectionName, 'cbDetectNetwork', FALSE);
      cbDetectRadar.Checked := ReadBool(sConfigSectionName, 'cbDetectRadar', FALSE);
      cbLanceMonitoring.Checked := ReadBool(sConfigSectionName, 'cbLanceMonitoring', FALSE);
      cbDetectNetworkClick(cbDetectNetwork);

      itnTempsOn := ReadInteger(sConfigSectionName, 'tbTempsOn', 0);
      itnTempsOff := ReadInteger(sConfigSectionName, 'tbTempsOff', 0);
      btnIncludeTempsOff := ReadBool(sConfigSectionName, 'ckbSendAClearScreenBetweenSpeed', True);
      // ..LoadConfiguration
    end;
  finally
    ConfigFile.Free;
  end;

  if FileExists(edConfigFile.Text) then
    LoadRadarConfigFile;
end;

procedure TfrmCallidusRadar.SaveConfiguration;
var
  ConfigFile: TIniFile;
  sConfigSectionName: string;
begin
  sConfigSectionName := Format('Config%.2d', [iIndexApplication]);

  ConfigFile := TIniFile.Create(NomFichierConfiguration);
  try
    with ConfigFile do
    begin
      SaveWindowConfig(ConfigFile, Self, sConfigSectionName);
      SaveWindowConfig(ConfigFile, frmDebugWindow, 'Debug' + sConfigSectionName);
      WriteInteger(sConfigSectionName, 'pcRadarPageControl', pcRadarPageControl.ActivePageIndex);
      WriteString(sConfigSectionName, 'edConfigFile', edConfigFile.Text);
      WriteString(sConfigSectionName, 'cbRadarAddress', cbRadarAddress.Items.Strings[cbRadarAddress.ItemIndex]);
      WriteString(sConfigSectionName, 'RadarPortNumber', cbComPort.Items.Strings[cbComPort.ItemIndex]);
      SetVariableFromVisibleServiceSpeedParam;
      WriteInteger(sConfigSectionName, 'LowLimitServiceSpeed', ServiceSpeed.LowLimitServiceSpeed);
      WriteInteger(sConfigSectionName, 'HighLimitServiceSpeed', ServiceSpeed.HighLimitServiceSpeed);
      WriteInteger(sConfigSectionName, 'TimeToShowServiceSpeed', ServiceSpeed.TimeToShowServiceSpeed);
      WriteInteger(sConfigSectionName, 'LowLimitInactivitySpeed', ServiceSpeed.LowLimitInactivitySpeed);
      WriteInteger(sConfigSectionName, 'HighLimitInactivitySpeed', ServiceSpeed.HighLimitInactivitySpeed);
      WriteInteger(sConfigSectionName, 'TimeInactivitySpeed', ServiceSpeed.TimeInactivitySpeed);
      WriteBool(sConfigSectionName, 'bDebugWasVisible', frmDebugWindow.Visible);
      WriteBool(sConfigSectionName, 'cbSaveLogEachTimeWhenQuiting', cbSaveLogEachTimeWhenQuiting.Checked);
      WriteBool(sConfigSectionName, 'miFullCommunicationLog', miFullCommunicationLog.Checked);
      WriteBool(sConfigSectionName, 'cbKeepRetryingAutodetect', cbKeepRetryingAutodetect.Checked);
      WriteBool(sConfigSectionName, 'cbTryAllBaudRate', cbTryAllBaudRate.Checked);
      WriteBool(sConfigSectionName, 'cbDetectNetwork', cbDetectNetwork.Checked);
      WriteBool(sConfigSectionName, 'cbDetectRadar', cbDetectRadar.Checked);
      WriteBool(sConfigSectionName, 'cbLanceMonitoring', cbLanceMonitoring.Checked);

      WriteInteger(sConfigSectionName, 'tbTempsOn', itnTempsOn);
      WriteInteger(sConfigSectionName, 'tbTempsOff', itnTempsOff);
      WriteBool(sConfigSectionName, 'ckbSendAClearScreenBetweenSpeed', btnIncludeTempsOff);
      // ..SaveConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

{ TfrmCallidusRadar.AutoDetectRadar }
// 1. On ferme le COM s'il était ouvert.
// 2. On rafraîchis nos liste de COM au début d'une boucle pour être sûr que nous sommes à jour.
// 3. On s'essaie à 9600 bps au début à tous les COM's.
// 4. Si on est configuré pour ça, on essaie les autres baud rate après.
// 5. Si on est configuré pour ça, on essaie tous les baud rate.
function TfrmCallidusRadar.AutoDetectRadar: boolean;
var
  iRememberCom, iComPromeneur, iIndexBaudRate: integer;
  bFlagFirstAttempt, bRadarFound: boolean;
const
  BAUDRATETABLE: array[0..9] of integer = (9600, 300, 600, 1200, 2400, 4800, 19200, 38400, 57600, 115200);
begin
  try
    pcRadarPageControl.ActivePage := tsOptionsAutoDetection;
    pnlAutoDetection.Visible := True;
    btnStopAutoDetect.Visible := True;
    bAbortAutoDetection := FALSE;
    pcRadarPageControl.Enabled := False;
    Application.ProcessMessages;

    try
      bRadarFound := FALSE;
      bFlagFirstAttempt := TRUE;
      iRememberCom := cbComPort.ItemIndex;

      repeat
        if pnlAutoDetection.Color = clRed then
          pnlAutoDetection.Color := clMaroon
        else
          pnlAutoDetection.Color := clRed;
        PopulatecbComPort;

        if bFlagFirstAttempt then
        begin
          iComPromeneur := cbComPort.ItemIndex;
          WriteStatusLg('Since it''s the first attempt of auto-detection, we''ll test with current configured COM...', 'Puis que c''est notre première auto-détection, on teste pour commencer avec le COM présentement ajusté...', COLORDANGER);
        end
        else
        begin
          iComPromeneur := 0;
        end;

        while (iComPromeneur < cbComPort.Items.Count) and (not bRadarFound) and (not bAbortAutoDetection) do
        begin
          cbComPort.ItemIndex := iComPromeneur;
          Application.ProcessMessages;
          try
            if length(cbComPort.Items.Strings[cbComPort.ItemIndex]) > 0 then
            begin
              if cbComPort.Items.Strings[cbComPort.ItemIndex][1] = '1' then
              begin
                iIndexBaudRate := 0;

                while (iIndexBaudRate < length(BAUDRATETABLE)) and (not bRadarFound) and (not bAbortAutoDetection) do
                begin
                  try
                    CloseConnexion;
                    WriteStatusLg(Format('We will try to detect on COM%d @ %d bps', [iComPromeneur + 1, BAUDRATETABLE[iIndexBaudRate]]), Format('Nous allons nous essayer sur le COM%d à %d bps', [iComPromeneur + 1, BAUDRATETABLE[iIndexBaudRate]]), COLORDANGER);
                    VaCommRadar.UserBaudrate := BAUDRATETABLE[iIndexBaudRate];
                    if SetTransmitterOnOrOff(FALSE) then
                    begin
                      WriteStatusLg(Format('RADAR was detected successfully on COM%d @ %d bps', [iComPromeneur + 1, BAUDRATETABLE[iIndexBaudRate]]), Format('Le RADAR a été détecté avec succès sur le COM%d à %d bps', [iComPromeneur + 1, BAUDRATETABLE[iIndexBaudRate]]), COLORSUCCESS);
                      bRadarFound := True;
                    end
                    else
                    begin
                      WriteStatusLg(Format('Sorry, RADAR was not detected on COM%d @ %d bps', [iComPromeneur + 1, BAUDRATETABLE[iIndexBaudRate]]), Format('Désolé, le RADAR n''a pas été détecté sur le COM%d à %d bps', [iComPromeneur + 1, BAUDRATETABLE[iIndexBaudRate]]), COLORFATIGUANTE);
                    end;
                  except
                    WriteStatusLg('ERROR: Major exception error happened...', 'ERREUR: Un exception majeure est arrivée là...', COLORERROR);
                  end;

                  if not bRadarFound then inc(iIndexBaudRate);
                  if not cbTryAllBaudRate.Checked then iIndexBaudRate := length(BAUDRATETABLE);
                end;
              end;
            end;
          except
            WriteStatusLg('ERROR: Major exception error happened...', 'ERREUR: Un exception majeure est arrivée là...', COLORERROR);
          end;

          if not bRadarFound then inc(iComPromeneur);

          if (bFlagFirstAttempt) and (not bRadarFound) and (not bAbortAutoDetection) then
          begin
            iComPromeneur := 0;
            bFlagFirstAttempt := FALSE;
            WriteStatusLg('Since we did not find RADAR, we will now looping through ALL the detected COM ports...', 'Puisque nous n''avons pas détecter de RADAR, nous allons maintenant parcourir TOUS les COM''s qui ont été détectés...', COLORDANGER);
          end;
        end; //while (iComPromeneur < cbComPort.Items.Count) and (not bRadarFound) do
      until (bRadarFound) or (not cbKeepRetryingAutodetect.Checked) or (bAbortAutoDetection);

      if not bRadarFound then cbComPort.ItemIndex := iRememberCom;
      result := bRadarFound and (not bAbortAutoDetection);
      CloseConnexion;
    finally
      pnlAutoDetection.Visible := False;
      btnStopAutoDetect.Visible := False;
      pcRadarPageControl.Enabled := True;
      if bAbortAutoDetection then MessageDlg('ATTENTION! Vous avez annulé l''auto-détection!', mtWarning, [mbOk], 0);
    end;
  except
    result := FALSE;
  end;
end;

{ TfrmCallidusRadar.actAutodetectionExecute }
procedure TfrmCallidusRadar.actAutodetectionExecute(Sender: TObject);
begin
  DisableToute;
  try
    bOverAllActionResult := AutoDetectRadar;
  finally
    EnableToute;
  end;
end;

{ TfrmCallidusRadar.ProtocolePROTO_RadarServerSocketValidPacketReceived }
procedure TfrmCallidusRadar.ProtocolePROTO_RadarServerPacketReceived(Sender: TObject; ABinding: TIdSocketHandle; const AData: TIdBytes; Answer7: AnsiString; PayloadData: TStringList);
begin
  case TProtocoleProto(Sender).CommandList.IndexOf(Answer7) of
    PROTO_CMD_DISCRTC:
      begin
        ProcessInfoForSpeedParam(PayloadData);
      end;

    PROTO_CMD_STRTTST:
      begin
        StartNetworkTest(PayloadData);
      end;

    PROTO_CMD_STOPTST:
      begin
        StopNetworkTest(PayloadData);
      end;

    PROTO_CMD_GETRDRP:
      begin
        SendBackToHostCurrentParameters;
      end;
  end;
end;

procedure TfrmCallidusRadar.SendBackToHostCurrentParameters;
var
  PayloadDataRequest: TStringList;
begin
  PayloadDataRequest := TStringList.Create;
  try
    PayloadDataRequest.Add(CALLIDUS_CMD_SET_RADAR_LOW_LIMIT + '=' + edLowServiceSpeed.Text);
    PayloadDataRequest.Add(CALLIDUS_CMD_SET_RADAR_HIG_LIMIT + '=' + edHighServiceSpeed.Text);
    PayloadDataRequest.Add(CALLIDUS_CMD_SET_RADAR_SHOW_TIME + '=' + edShowTimeServiceSpeed.Text);
    PayloadDataRequest.Add(CALLIDUS_CMD_SET_RADAR_LOWINACSP + '=' + edLowInactivitySpeed.Text);
    PayloadDataRequest.Add(CALLIDUS_CMD_SET_RADAR_HIGINACSP + '=' + edHighInactivitySpeed.Text);
    PayloadDataRequest.Add(CALLIDUS_CMD_SET_RADAR_INAC_TIME + '=' + edInactivityTime.Text);

    ProtocolePROTO_Radar.PitchUnMessagePROTONoHandshake('', PROTO_CMD_RDRINFO, PayloadDataRequest);
  finally
    FreeAndNil(PayloadDataRequest);
  end;
end;

procedure TfrmCallidusRadar.StartNetworkTest(PayloadData: TStringList);
var
  slVariablesNames, slVariablesValues: TStringList;
  iAnyValue: integer;
begin
  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;
  try
    CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);

    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_INFO_TEMPSON);
    if iAnyValue <> -1 then itnTempsOn := StrToIntDef(slVariablesValues.Strings[iAnyValue], 0);
    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_INFO_TEMPOFF);
    if iAnyValue <> -1 then itnTempsOff := StrToIntDef(slVariablesValues.Strings[iAnyValue], 0);
    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_INFO_USETOFF);
    if iAnyValue <> -1 then btnIncludeTempsOff := (StrToIntDef(slVariablesValues.Strings[iAnyValue], 0) = 1);

    if not bCurrentlyDoingNetworkCycleTest then
    begin
      bFlagAbort := FALSE;
      bCurrentlyDoingNetworkCycleTest := True;
      tmrTestConnexion.Tag := 0;
      tmrTestConnexion.Interval := 10;
      tmrTestConnexion.Enabled := True;
      Application.ProcessMessages;
    end;

  finally
    FreeAndNil(slVariablesNames);
    FreeAndNil(slVariablesValues);
  end;
end;

procedure TfrmCallidusRadar.ProcessInfoForSpeedParam(PayloadData: TStringList);
var
  slVariablesNames, slVariablesValues: TStringList;
  iAnyValue: integer;
begin
  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;
  try
    CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);

    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SET_RADAR_LOW_LIMIT);
    if iAnyValue <> -1 then edLowServiceSpeed.Text := slVariablesValues.Strings[iAnyValue];
    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SET_RADAR_HIG_LIMIT);
    if iAnyValue <> -1 then edHighServiceSpeed.Text := slVariablesValues.Strings[iAnyValue];
    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SET_RADAR_SHOW_TIME);
    if iAnyValue <> -1 then edShowTimeServiceSpeed.Text := slVariablesValues.Strings[iAnyValue];
    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SET_RADAR_LOWINACSP);
    if iAnyValue <> -1 then edLowInactivitySpeed.Text := slVariablesValues.Strings[iAnyValue];
    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SET_RADAR_HIGINACSP);
    if iAnyValue <> -1 then edHighInactivitySpeed.Text := slVariablesValues.Strings[iAnyValue];
    iAnyValue := slVariablesNames.IndexOf(CALLIDUS_CMD_SET_RADAR_INAC_TIME);
    if iAnyValue <> -1 then edInactivityTime.Text := slVariablesValues.Strings[iAnyValue];
    SetVariableFromVisibleServiceSpeedParam;
  finally
    FreeAndNil(slVariablesNames);
    FreeAndNil(slVariablesValues);
  end;
end;

end.

