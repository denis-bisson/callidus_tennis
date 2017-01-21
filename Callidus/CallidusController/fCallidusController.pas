unit fCallidusController;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan,
  Vcl.Menus, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.AppEvnts, Vcl.ExtCtrls,
  Vcl.CheckLst, Vcl.ToolWin, System.ImageList, Vcl.ImgList,

  // Third Party
  IdGlobal, IdUDPServer, IdSocketHandle, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPClient,

  // Callidus
  uCommonStuff, uProtocoleProto, uCheckListCallidus, uLabeledEditCallidus;

type
  tDeviceType = (dtUnknown, dtCallidusRadar, dtCallidusDisplay);

  TCallidusDevice = class
  public
    DeviceType: tDeviceType;
    sIPAddress: string;
    sComputerName: string;
    sName: string;
    sComplementName: string;
    sVersionNo: string;
    dwLastTimeItWasSeen: dword;
    constructor Create(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string; paramVersionName: string);
    function GetDisplayName: string;
    function GetFullName: string;
  end;

  TCallidusDeviceList = class(TList)
  private
    function GetDevice(Index: integer): TCallidusDevice;
  public
    constructor Create;
    procedure Clear; override;
    function Add(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string; const paramRemoteVersion: string): integer;
    property Device[Index: integer]: TCallidusDevice read GetDevice;
  end;

  TSpecificOrNot = (sonAllOfAKind, sonSelected, sonFirst);

  TfrmCallidusController = class(TForm)
    MyStatusBar: TStatusBar;
    mmMainMenu: TMainMenu;
    Actions1: TMenuItem;
    amMainActionManager: TActionManager;
    actCloseApplication: TAction;
    Closeapplication1: TMenuItem;
    evMainApplicationEvents: TApplicationEvents;
    actToggleDebugWindow: TAction;
    View1: TMenuItem;
    oggleDebugWindow1: TMenuItem;
    actStartServicing: TAction;
    N1: TMenuItem;
    StartServicing1: TMenuItem;
    ProtocolePROTO_Radar: TProtocoleProto;
    miSaveLogEachTime: TMenuItem;
    ProtocolePROTO_Display: TProtocoleProto;
    estcommunicationwithCallidusDisplay1: TMenuItem;
    actCloseAllCallidusApplications: TAction;
    Action11: TMenuItem;
    tmrBroadcastServerLocation: TTimer;
    IdUDPServerController: TIdUDPServer;
    ProtocolePROTO_Controller: TProtocoleProto;
    pgMainPagecontrol: TPageControl;
    tsApplicationSatellite: TTabSheet;
    Label1: TLabel;
    actFlushCurrentDetectedList: TAction;
    Flushcurrentdetectedlist1: TMenuItem;
    miFullCommunicationLog: TMenuItem;
    cbCommenditaireFullScreen: TTabSheet;
    ColorDialog1: TColorDialog;
    actSetInFullScreen: TAction;
    actSetInNormalScreen: TAction;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButton6: TToolButton;
    ToolButton4: TToolButton;
    ToolButton7: TToolButton;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    pnlBackground: TPanel;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    pnlSpeedCote1: TPanel;
    pnlSpeedShadow: TPanel;
    edPositionSpeedY: TLabeledEdit;
    edTailleSpeedY: TLabeledEdit;
    cbShadowSize: TComboBox;
    gbSpeedUnit: TGroupBox;
    lblUnitColor: TLabel;
    lblUnitShadowcolor: TLabel;
    lblUnitTailleShadow: TLabel;
    pnlUnit: TPanel;
    pnlUnitShadow: TPanel;
    edUnitPosY: TLabeledEdit;
    edTailleUnitY: TLabeledEdit;
    cbUnitShadowSize: TComboBox;
    Label4: TLabel;
    edServiceSpeedUnit: tLabeledEditCallidus;
    lbDeviceDetected: TListBox;
    RefreshListTimer: TTimer;
    actStartPub: TAction;
    tsPub: TTabSheet;
    ToolButton10: TToolButton;
    Label12: TLabel;
    clCommenditaire: tCheckListCallidus;
    btnCommandFull: TButton;
    rgPubType: TRadioGroup;
    cbDisplayFullScreenTime: TComboBox;
    Label13: TLabel;
    TimerPublicityFullScreen: TTimer;
    TabSheet1: TTabSheet;
    clCommdtBanniere: tCheckListCallidus;
    lblBanniereFileList: TLabel;
    btnBanniere: TButton;
    rgModePubBanniere: TRadioGroup;
    lblHelpBanniere: TLabel;
    lblHelpFullScreen: TLabel;
    tsRadar: TTabSheet;
    ckbPubBanniere: TCheckBox;
    IdUDPClientRadar: TIdUDPClient;
    actMasterSelfIdentification: TAction;
    ToolButton9: TToolButton;
    actLaunchCallidusRadar: TAction;
    actLaunchCallidusDisplay: TAction;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    IdUDPClientDisplay: TIdUDPClient;
    gbRadarConfiguration: TGroupBox;
    edShowTimeServiceSpeed: TLabeledEdit;
    edInactivityTime: TLabeledEdit;
    edHighInactivitySpeed: TLabeledEdit;
    edHighServiceSpeed: TLabeledEdit;
    edLowServiceSpeed: TLabeledEdit;
    edLowInactivitySpeed: TLabeledEdit;
    btnSendRadarParameters: TButton;
    gbNetworkTest: TGroupBox;
    btnStartNetworkTest: TButton;
    ckbTempsOffBetweenTest: TCheckBox;
    edtRadarTestTempsOff: TLabeledEdit;
    edtRadarTestTempsOn: TLabeledEdit;
    actStartNetworkTest: TAction;
    actStopNetworkTest: TAction;
    btnStopNetworkTest: TButton;
    actSendRadarParams: TAction;
    actGetRadarParams: TAction;
    btnReadRadarParameters: TButton;
    actGetResolution: TAction;
    Button1: TButton;
    lblHintForResolution: TLabel;
    lblResolution: TLabel;
    procedure actCloseApplicationExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure evMainApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actToggleDebugWindowExecute(Sender: TObject);
    procedure WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
    function InformeDisplayDuneNouvelleVitesse(paramInfoSpeed: TServiceSpeed): boolean;
    function SendCommandToRemoteStation(WhereWichToSend: TSpecificOrNot; ProtoCommand: integer; deviceType: tDeviceType; params: array of string): boolean;
    procedure DisableToute;
    procedure EnableToute;
    procedure actCloseAllCallidusApplicationsExecute(Sender: TObject);
    procedure actFlushCurrentDetectedListExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miFullCommunicationLogClick(Sender: TObject);
    procedure evMainApplicationEventsException(Sender: TObject; E: Exception);
    procedure pnlBackgroundClick(Sender: TObject);
    procedure actSetInFullScreenExecute(Sender: TObject);
    procedure actSetInNormalScreenExecute(Sender: TObject);
    procedure edServiceSpeedUnitSubCheckboxClick(Sender: TObject);
    procedure lbDeviceDetectedDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure RefreshListTimerTimer(Sender: TObject);
    procedure actStartPubExecute(Sender: TObject);
    procedure btnCommanditClick(Sender: TObject);
    function DoLaPub: boolean;
    procedure TimerPublicityFullScreenTimer(Sender: TObject);
    procedure btnStopPubClick(Sender: TObject);
    function GetPubFileName(iDispatcher: integer; var sFilename: string): boolean;
    function GenericValidResponse(slPayloadDataAnswer: TStringList): boolean;
    procedure ckbPubBanniereClick(Sender: TObject);
    procedure actMasterSelfIdentificationExecute(Sender: TObject);
    procedure actLaunchApplicationExecute(Sender: TObject);
    procedure ProtocolePROTO_ControllerServerPacketReceived(Sender: TObject; ABinding: TIdSocketHandle; const AData: TIdBytes; Answer7: AnsiString; PayloadData: TStringList);
    procedure AjouteOrUpdateOutListWithThisDevice(const sRemoteStationAddress: string; PayloadData: TStringList);
    procedure actStartNetworkTestExecute(Sender: TObject);
    procedure actStopNetworkTestExecute(Sender: TObject);
    procedure actSendRadarParamsExecute(Sender: TObject);
    procedure actGetRadarParamsExecute(Sender: TObject);
    procedure ProcessInfoForSpeedParam(PayloadData: TStringList);
    procedure actGetResolutionExecute(Sender: TObject);
    procedure tmrBroadcastServerLocationTimer(Sender: TObject);

  private
    { Private declarations }
    isFirstActivation: Boolean;
    NomFichierConfiguration: string;
    bFlagAcknowledge: Boolean;
    RxBuffer: TIdBytes;
    RxIndex: Integer;
    bOverAllActionResult: Boolean;
    CallidusDeviceList: TCallidusDeviceList;
    ListeDesDevicesLastTrenteSecondes: TStringList;
    bModePublicite: boolean;
    PanelStop: TPanel;
    LabelPub: TLabel;
    BoutonStop: TButton;
    bDoingAnAction: boolean;
  public
    { Public declarations }
  end;

var
  frmCallidusController: TfrmCallidusController;

const
  STOPPER = 'MyleneStopThemAll!';

implementation

{$R *.dfm}

uses
  // Delphi
  IniFiles, StrUtils, ShellAPI,

  // Third party

  // Callidus
  fDebugWindow;

const
  IDX_PANEL_VERSION = 0;
  IDX_PANEL_LOCALIP = 1;

  { TCallidusDevice.Create }
constructor TCallidusDevice.Create(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string; paramVersionName: string);
begin
  Self.DeviceType := paramDeviceType;
  Self.sIPAddress := paramIPAddress;
  Self.sComputerName := paramComputerName;
  Self.sVersionNo := paramVersionName;
  Self.sName := paramName;
  Self.sComplementName := paramComplementName;
  Self.dwLastTimeItWasSeen := GetTickCount;
end;

{ TCallidusDevice.GetDisplayName }
function TCallidusDevice.GetDisplayName: string;
begin
  result := Self.sName + ' - ' + Self.sComputerName + ' - ' + Self.sComplementName + ' - ' + Self.sVersionNo;
end;

{ TCallidusDevice.GetFullName }
function TCallidusDevice.GetFullName: string;
begin
  result := Self.sName + ' - ' + Self.sComputerName + ' - ' + Self.sComplementName + '(' + Self.sIPAddress + ')';
end;

{ TCallidusDeviceList.Create }
constructor TCallidusDeviceList.Create;
begin
  inherited Create;
end;

{ TCallidusDeviceList.Clear }
procedure TCallidusDeviceList.Clear;
var
  i: integer;
begin
  for i := pred(Count) downto 0 do
    Device[i].Free;
  inherited Clear;
end;

{ TCallidusDeviceList.Add }
function TCallidusDeviceList.Add(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string; const paramRemoteVersion: string): integer;
var
  WorkingCallidusDevice: TCallidusDevice;
  iPromeneur: integer;
  bAlreadyPresent: boolean;
begin
  result := -1;
  iPromeneur := 0;
  bAlreadyPresent := False;

  while (iPromeneur < count) and (not bAlreadyPresent) do
  begin
    bAlreadyPresent :=
      ((TCallidusDevice(Items[iPromeneur]).DeviceType = paramDeviceType) and
      (TCallidusDevice(Items[iPromeneur]).sIPAddress = paramIPAddress) and
      (TCallidusDevice(Items[iPromeneur]).sComputerName = paramComputerName) and
      (TCallidusDevice(Items[iPromeneur]).sName = paramName) and
      (TCallidusDevice(Items[iPromeneur]).sComplementName = paramComplementName) and
      (TCallidusDevice(Items[iPromeneur]).sVersionNo = paramRemoteVersion));

    inc(iPromeneur);
  end;

  if not bAlreadyPresent then
  begin
    WorkingCallidusDevice := TCallidusDevice.Create(paramDeviceType, paramIPAddress, paramComputerName, paramName, paramComplementName, paramRemoteVersion);
    result := inherited Add(WorkingCallidusDevice);
  end
  else
  begin
    TCallidusDevice(Items[pred(iPromeneur)]).dwLastTimeItWasSeen := GetTickCount;
  end;
end;

{ TCallidusDeviceList.GetDevice }
function TCallidusDeviceList.GetDevice(Index: integer): TCallidusDevice;
begin
  result := TCallidusDevice(Items[Index]);
end;

procedure TfrmCallidusController.actCloseAllCallidusApplicationsExecute(Sender: TObject);
begin
  CloseAllCallidusApplications;
end;

procedure TfrmCallidusController.actCloseApplicationExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmCallidusController.actFlushCurrentDetectedListExecute(Sender: TObject);
begin
  lbDeviceDetected.Clear;
end;

procedure TfrmCallidusController.actGetRadarParamsExecute(Sender: TObject);
begin
  DisableToute;
  try
    bOverAllActionResult := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_GETRDRP, dtCallidusRadar, []);
  finally
    EnableToute;
  end;
end;

{ TfrmCallidusController.actGetResolutionExecute }
procedure TfrmCallidusController.actGetResolutionExecute(Sender: TObject);
begin
  DisableToute;
  try
    lblHintForResolution.Visible := False;
    lblResolution.Visible := False;
    bOverAllActionResult := SendCommandToRemoteStation(sonSelected, PROTO_CMD_GETRESO, dtCallidusDisplay, []);
  finally
    EnableToute;
  end;
end;

{ TfrmCallidusController.actLaunchApplicationExecute }
procedure TfrmCallidusController.actLaunchApplicationExecute(Sender: TObject);
var
  sCommand, sParams, sWorkingDir: string;
  iResult: word;
begin
  case TComponent(Sender).Tag of
    1: sCommand := ExtractFilePath(paramstr(0)) + 'CallidusDisplay.exe' + #0;
    2: sCommand := ExtractFilePath(paramstr(0)) + 'CallidusRadar.exe' + #0;
  else
    sCommand := '';
  end;

  if sCommand <> '' then
  begin
    sParams := '' + #0;
    sWorkingDir := ExcludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + #0;
    iResult := ShellExecute(0, 'open', @sCommand[1], @sParams[1], @sWorkingDir[1], SW_NORMAL);
    if iResult < 32 then
      MessageDlg('Failed to execute ' + sCommand + #$0A + #$0A + SysErrorMessage(GetLastError), mtError, [mbOk], 0);
  end;
end;

procedure TfrmCallidusController.actMasterSelfIdentificationExecute(Sender: TObject);
begin
  ProtocolePROTO_Radar.AnyUDPClientSendIdentification;
  ProtocolePROTO_Display.AnyUDPClientSendIdentification;
end;

procedure TfrmCallidusController.TimerPublicityFullScreenTimer(Sender: TObject);
begin
  TimerPublicityFullScreen.Enabled := False;
  try
    DoLaPub;
  finally
    if bModePublicite then
      TimerPublicityFullScreen.Enabled := True;
  end;
end;

procedure TfrmCallidusController.tmrBroadcastServerLocationTimer(Sender: TObject);
begin
  tmrBroadcastServerLocation.Enabled:=False;
  try
     actMasterSelfIdentificationExecute(actMasterSelfIdentification);
  finally
    tmrBroadcastServerLocation.Interval:=15000;
    tmrBroadcastServerLocation.Enabled:=True;
  end;
end;

function TfrmCallidusController.DoLaPub: boolean;
var
  sLocalFilename: string;
begin
  result := False;
  if GetPubFileName(1, sLocalFilename) then
    result := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_DISCRTC, dtCallidusDisplay, [CALLIDUS_CMD_SET_FULL_SCREEN_PUBLICITY + '=' + sLocalFilename]);
end;

{ TfrmCallidusController.GetPubFileName }
// Routine pour aller chercher le nom du fichier de publicité à prendre.
// Elle sert autant pour la bande de pub lors de l'affichage de vitesse de service QUE pour la grosse publicité en mode pub.
// On fait juste lui spécifié le bon dispatcher et elle travaillera selon les paramètres indiqué pour la checklist et le mode.
function TfrmCallidusController.GetPubFileName(iDispatcher: integer; var sFilename: string): boolean;
var
  iMaybeIndex: integer;
  sNomFichier: string;
  iPreviousIndex: integer;
  iNbChecked, iIndex, iFirstCheck: integer;
  chklst: tCheckListCallidus;
  rgMode: TRadioGroup;
begin
  result := False;

  chklst := nil;
  rgMode := nil;
  iNbChecked := 0;

  case iDispatcher of
    1:
      begin
        chklst := clCommenditaire;
        rgMode := rgPubType;
      end;
    2:
      begin
        chklst := clCommdtBanniere;
        rgMode := rgModePubBanniere;
      end;
  end;

  if (chklst <> nil) and (rgMode <> nil) then
  begin
    if chklst.Items.Count > 0 then
    begin
      iFirstCheck := -1;
      if chklst.ItemIndex = -1 then
        chklst.ItemIndex := 0;

      for iIndex := 0 to pred(chklst.Items.Count) do
      begin
        if chklst.Checked[iIndex] then
        begin
          if iFirstCheck = -1 then
            iFirstCheck := iIndex;
          inc(iNbChecked);
        end;
      end;

      if iNbChecked = 0 then
      begin
        chklst.Checked[0] := True;
        iFirstCheck := 0;
        iNbChecked := 1;
      end;

      case rgMode.ItemIndex of
        1, 2:
          begin
            if chklst.Checked[chklst.ItemIndex] = False then
              chklst.ItemIndex := iFirstCheck;
          end;
      end;

      iMaybeIndex := chklst.ItemIndex;

      case rgMode.ItemIndex of
        1:
          begin
            if iNbChecked = 1 then
              chklst.ItemIndex := iFirstCheck
            else
            begin
              repeat
                chklst.ItemIndex := ((chklst.ItemIndex + 1) mod chklst.Items.Count);
              until chklst.Checked[chklst.ItemIndex];
            end;
          end;

        2:
          begin
            if iNbChecked = 1 then
              chklst.ItemIndex := iFirstCheck
            else
            begin
              iPreviousIndex := chklst.ItemIndex;
              repeat
                chklst.ItemIndex := random(chklst.Items.Count);
              until (chklst.Checked[chklst.ItemIndex]) and (chklst.ItemIndex <> iPreviousIndex);
            end;
          end;
      end;

      if chklst.ItemIndex <> -1 then
      begin
        sFilename := chklst.Items.Strings[iMaybeIndex];
        result := True;
      end;
    end;
  end;
end;

procedure TfrmCallidusController.actStartPubExecute(Sender: TObject);
var
  sNomFichier: string;
begin
  DisableToute;
  try
    PanelStop := TPanel.Create(self);
    PanelStop.Parent := self;
    PanelStop.Top := 0;
    PanelStop.Left := 0;
    PanelStop.Width := width;
    PanelStop.Height := Height;
    PanelStop.Constraints.MinWidth := PanelStop.Width;
    PanelStop.Visible := True;
    PanelStop.Anchors := [akLeft, akTop, akRight, akBottom];

    LabelPub := TLabel.Create(PanelStop);
    LabelPub.Parent := PanelStop;
    LabelPub.Font.Size := 40;
    LabelPub.Top := (50 * Height) div 100;
    LabelPub.Font.Style := [fsBold];
    LabelPub.Font.Color := clRed;
    LabelPub.Caption := 'MODE PUB';
    LabelPub.Left := (Width - LabelPub.Width) div 2;
    LabelPub.Anchors := [akTop];
    LabelPub.Constraints.MinWidth := LabelPub.Width;
    LabelPub.Visible := True;

    BoutonStop := TButton.Create(PanelStop);
    BoutonStop.Parent := PanelStop;
    BoutonStop.Width := 300;
    BoutonStop.Height := 60;
    BoutonStop.Left := ((Width - BoutonStop.Width) div 2);
    BoutonStop.Top := 100;
    BoutonStop.Anchors := [akTop];
    BoutonStop.Font.Size := 20;
    BoutonStop.Font.Style := [fsBold];
    BoutonStop.Caption := 'Cessez la pub';
    BoutonStop.Constraints.MinWidth := BoutonStop.Width;
    BoutonStop.OnClick := btnStopPubClick;
    BoutonStop.Visible := True;

    bModePublicite := True;
    bOverAllActionResult := DoLaPub;
    TimerPublicityFullScreen.Interval := 1000 * StrToIntDef(cbDisplayFullScreenTime.Items.Strings[cbDisplayFullScreenTime.ItemIndex], 2000);
    TimerPublicityFullScreen.Enabled := True;
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.actStopNetworkTestExecute(Sender: TObject);
begin
  DisableToute;
  try
    bOverAllActionResult := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_STOPTST, dtCallidusRadar, []);
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.actSendRadarParamsExecute(Sender: TObject);
var
  Params: array of string;
  icurrentIndexInArray: integer;
begin
  DisableToute;
  try
    SetLength(Params, 20);
    CleanMonArray(Params);
    icurrentIndexInArray := 0;

    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SET_RADAR_LOW_LIMIT + '=' + edLowServiceSpeed.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SET_RADAR_HIG_LIMIT + '=' + edHighServiceSpeed.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SET_RADAR_SHOW_TIME + '=' + edShowTimeServiceSpeed.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SET_RADAR_LOWINACSP + '=' + edLowInactivitySpeed.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SET_RADAR_HIGINACSP + '=' + edHighInactivitySpeed.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SET_RADAR_INAC_TIME + '=' + edInactivityTime.Text);

    bOverAllActionResult := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_DISCRTC, dtCallidusRadar, Params);
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.actSetInFullScreenExecute(Sender: TObject);
begin
  DisableToute;
  try
    bOverAllActionResult := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_DISCRTC, dtCallidusDisplay, [CALLIDUS_CMD_ADJUSTSCREEN + '=' + sDISPLAY_PARAM_FULLSCREEN]);
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.actSetInNormalScreenExecute(Sender: TObject);
begin
  DisableToute;
  try
    bOverAllActionResult := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_DISCRTC, dtCallidusDisplay, [CALLIDUS_CMD_ADJUSTSCREEN + '=' + sDISPLAY_PARAM_NORMALSCREEN]);
  finally
    EnableToute;
  end;
end;

function TfrmCallidusController.SendCommandToRemoteStation(WhereWichToSend: TSpecificOrNot; ProtoCommand: integer; deviceType: tDeviceType; params: array of string): boolean;
var
  PayloadDataRequest, PayloadDataAnswer: TStringList;
  Answer: AnsiString;
  iDevice, iParam: integer;

  procedure LocalEnvoieLaCommande;
  begin
    case deviceType of
      dtCallidusDisplay: ProtocolePROTO_Display.PitchUnMessagePROTONoHandshake(CallidusDeviceList.Device[iDevice].sIPAddress, ProtoCommand, PayloadDataRequest);
      dtCallidusRadar: ProtocolePROTO_Radar.PitchUnMessagePROTONoHandshake(CallidusDeviceList.Device[iDevice].sIPAddress, ProtoCommand, PayloadDataRequest);
    end;
  end;

begin
  result := False;
  if not bDoingAnAction then
  begin
    bDoingAnAction := True;
    try
      PayloadDataRequest := TStringList.Create;
      PayloadDataAnswer := TStringList.Create;
      try
        for iParam := 0 to pred(length(params)) do
          if params[iParam] <> '' then
            PayloadDataRequest.Add(params[iParam]);

        //case WhereWichToSend of
        case WhereWichToSend of
          sonAllOfAKind:
            begin
              for iDevice := pred(CallidusDeviceList.Count) downto 0 do
                if CallidusDeviceList.Device[iDevice].DeviceType = deviceType then LocalEnvoieLaCommande;
            end;

          sonSelected:
            begin
              iDevice := -1;
              if lbDeviceDetected.ItemIndex <> -1 then
              begin
                if CallidusDeviceList.Device[lbDeviceDetected.ItemIndex].DeviceType = deviceType then
                begin
                  iDevice := lbDeviceDetected.ItemIndex;
                end;
              end;

              if iDevice <> -1 then
                LocalEnvoieLaCommande
              else
              begin
                pgMainPagecontrol.ActivePage := tsApplicationSatellite;
                MessageDlg('L''application-satellite sélectionné n''est pas du type requis pour la commande demandée!', mtError, [mbOk], 0);
              end;
            end;

          sonFirst:
            begin
            end;
        end;

        result := True;
      finally
        FreeAndNil(PayloadDataAnswer);
        FreeAndNil(PayloadDataRequest);
      end;
    finally
      bDoingAnAction := False;
    end;
  end;
end;

function TfrmCallidusController.GenericValidResponse(slPayloadDataAnswer: TStringList): boolean;
var
  slVariablesNames: TStringList;
  slVariablesValues: TStringList;
  iIndexParam: integer;
  sVariableValue: string;
begin
  result := True;
  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;
  try
    CallidusSplitVariablesNamesAndValues(slPayloadDataAnswer, slVariablesNames, slVariablesValues);

    iIndexParam := slVariablesNames.IndexOf(CALLIDUS_RSP_FILENOTFOUNT);
    if iIndexParam <> -1 then
    begin
      result := False;
      frmDebugWindow.StatusWindow.WriteStatus('ERREUR: IL MANQUE UN FICHIER SUR UN DISPLAY!', COLORERROR);
      frmDebugWindow.StatusWindow.WriteStatus('Version du dispositif remote: ' + slVariablesValues.Strings[iIndexParam], COLORERROR);
      if not frmDebugWindow.Visible then
        frmDebugWindow.Visible := True;
    end

  finally
    FreeAndNil(slVariablesNames);
    FreeAndNil(slVariablesValues);
  end;
end;

function TfrmCallidusController.InformeDisplayDuneNouvelleVitesse(paramInfoSpeed: TServiceSpeed): boolean;
var
  Params: array of string;
  iDevice: integer;
  sSpeedValueToShow, sSpeedUnitToShow, sSpeedRatio, sLocalPubFilename: string;
  icurrentIndexInArray: integer;
begin
  SetLength(Params, 20);
  CleanMonArray(Params);
  icurrentIndexInArray := 0;

  sSpeedValueToShow := '';
  sSpeedUnitToShow := '';
  sSpeedRatio := '25';

  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_POSITIY + '=' + edPositionSpeedY.Text);
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_SIZEHGT + '=' + edTailleSpeedY.Text);
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_SERVSPD + '=' + IntToStr(paramInfoSpeed.CurrentPeakSpeed));
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_SHDWSIZ + '=' + IntToStr(cbShadowSize.ItemIndex));
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_BACKCLR + '=' + IntToStr(pnlBackground.Color));
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_SPDCOLO + '=' + IntToStr(pnlSpeedCote1.Color));
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_SHDWCOL + '=' + IntToStr(pnlSpeedShadow.Color));

  if edServiceSpeedUnit.Checkbox.Checked then
  begin
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_UNIPOSY + '=' + edUnitPosY.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_UNISIZE + '=' + edTailleUnitY.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_UNIUNIT + '=' + edServiceSpeedUnit.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_UNICOLO + '=' + IntToStr(pnlUnit.Color));
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_UNISCOL + '=' + IntToStr(pnlUnitShadow.Color));
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_UNISHSZ + '=' + IntToStr(cbUnitShadowSize.ItemIndex));
  end;

  if ckbPubBanniere.Checked then
    if GetPubFileName(2, sLocalPubFilename) then
      AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SSS_COMMENDITAIRE + '=' + sLocalPubFilename);

  result := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_SNDINFO, dtCallidusDisplay, Params);
end;

procedure TfrmCallidusController.lbDeviceDetectedDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  SinceWhenItWasSeen: dword;
  PertinentColor: tcolor;
begin
  //dwLastTimeItWasSeen

  with Control as TListBox do
  begin
    if Index < CallidusDeviceList.Count then
    begin
      SinceWhenItWasSeen := (GetTickcount - TCallidusDevice(CallidusDeviceList.Items[Index]).dwLastTimeItWasSeen);
      case SinceWhenItWasSeen of
        0..31000: PertinentColor := clGreen;
        31001..120000: PertinentColor := clOlive;
      else
        PertinentColor := clRed;
      end;
    end
    else
    begin
      PertinentColor := clRed;
      SinceWhenItWasSeen := 0;
    end;

    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(Rect);

    Canvas.Font.Color := PertinentColor;
    Canvas.TextOut(Rect.Left, Rect.Top, Items.Strings[Index] + ' (' + GetElapsedTime(SinceWhenItWasSeen) + ')');
  end;
end;

procedure TfrmCallidusController.actToggleDebugWindowExecute(Sender: TObject);
begin
  if frmDebugWindow.Visible then
    frmDebugWindow.Close
  else
    frmDebugWindow.Show;
end;

procedure TfrmCallidusController.actStartNetworkTestExecute(Sender: TObject);
var
  Params: array of string;
  iDevice: integer;
  sSpeedValueToShow, sSpeedUnitToShow, sSpeedRatio, sLocalPubFilename: string;
  icurrentIndexInArray: integer;
begin
  DisableToute;
  try
    SetLength(Params, 20);
    CleanMonArray(Params);
    icurrentIndexInArray := 0;
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_TEMPSON + '=' + edtRadarTestTempsOn.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_TEMPOFF + '=' + edtRadarTestTempsOff.Text);
    if ckbTempsOffBetweenTest.Checked then
      AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_USETOFF + '=' + '1')
    else
      AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_INFO_USETOFF + '=' + '0');

    bOverAllActionResult := SendCommandToRemoteStation(sonAllOfAKind, PROTO_CMD_STRTTST, dtCallidusRadar, Params);
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.btnCommanditClick(Sender: TObject);
var
  sNomFichierList, sListFilename: string;
  slFichierDejacoches: TStringList;
  Dispatcher, iMaybeIndex, iIndexfile: integer;
  LocalChecklist: tCheckListCallidus;

begin
  LocalChecklist := nil;

  with Sender as TComponent do
    Dispatcher := tag;
  case Dispatcher of
    1:
      begin
        LocalChecklist := clCommenditaire;
        sListFilename := 'PubFullScreen.lst'
      end;
    2:
      begin
        LocalChecklist := clCommdtBanniere;
        sListFilename := 'PubBanniere.lst'
      end;
  end;

  slFichierDejacoches := TStringList.Create;
  try
    // 1. On s'assure que nous avons déjà le fichier sinon on ne fait rien.
    sNomFichierList := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + sListFilename;
    if FileExists(sNomFichierList) then
    begin
      // 2. On gardera en mémoire les fichiers qui sont déjà cochés
      for iIndexfile := 0 to pred(LocalChecklist.Items.Count) do
        if LocalChecklist.Checked[iIndexfile] then
          slFichierDejacoches.Add(LocalChecklist.Items.Strings[iIndexFile]);

      // 3. On flush notre list.
      LocalChecklist.Clear;

      // 4. On load notre fichier.
      LocalChecklist.Items.LoadFromFile(sNomFichierList);

      //5. On tente de recocher ceux qu'on avait déjà de cochés.
      for iIndexfile := 0 to pred(slFichierDejacoches.Count) do
      begin
        iMaybeIndex := LocalChecklist.Items.IndexOf(slFichierDejacoches.Strings[iIndexFile]);
        if iMaybeIndex <> -1 then
          LocalChecklist.Checked[iMaybeIndex] := True;
      end;
    end;
  finally
    FreeAndNil(slFichierDejacoches);
  end;
end;

procedure TfrmCallidusController.btnStopPubClick(Sender: TObject);
begin
  bModePublicite := False;
  Application.ProcessMessages;
  TimerPublicityFullScreen.Enabled := False;
  Application.ProcessMessages;
  if LabelPub <> nil then
    FreeAndNil(LabelPub);
  if BoutonStop <> nil then
    FreeAndNil(BoutonStop);
  if PanelStop <> nil then
    FreeAndNil(PanelStop);
  TimerPublicityFullScreen.Enabled := False; //Si t'as pas arrêté le 1er coup, tu vas arrêter ici!
  Application.ProcessMessages;
end;

procedure TfrmCallidusController.ckbPubBanniereClick(Sender: TObject);
begin
  with Sender as TCheckbox do
  begin
    rgModePubBanniere.Enabled := Checked;
    btnBanniere.Enabled := Checked;
    lblBanniereFileList.Enabled := Checked;
    clCommdtBanniere.Enabled := Checked;
    lblHelpBanniere.Enabled := Checked;
  end;
end;

procedure TfrmCallidusController.evMainApplicationEventsException(Sender: TObject; E: Exception);
var
  Msg: string;
begin
  if frmDebugWindow <> nil then
  begin
    Msg := E.Message;
    //    frmDebugWindow.StatusWindow.WriteStatus(E.Message, COLORERROR);
    frmDebugWindow.StatusWindow.Lines.Add('ERRRRRRRRROOORRRRRR!!!! : ' + E.Message);
  end;
end;

procedure TfrmCallidusController.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ProtocolePROTO_Radar.ShutDownService;
  ProtocolePROTO_Controller.ShutDownService;
  ProtocolePROTO_Display.ShutDownService;
  Application.ProcessMessages;
  SaveConfiguration;
end;

procedure TfrmCallidusController.FormCreate(Sender: TObject);
begin
  lblHintForResolution.Visible := False;
  lblResolution.Visible := False;

  NomFichierConfiguration := GetConfigFilename('CallidusController');
  lblHelpBanniere.Caption := 'Les noms des fichiers de publicité pour les bannières au-dessus de la vitesse doivent être dans un fichier texte';
  lblHelpBanniere.Caption := lblHelpBanniere.Caption + #$0A + 'appelé "PubBanniere.lst". Le path complet NE DOIT pas être inclus, juste le nom du fichier et son extension.';
  lblHelpBanniere.Caption := lblHelpBanniere.Caption + #$0A + 'On assume que les mêmes fichiers avec les mêmes noms se trouvent dans le même répertoire que l''exécutable';
  lblHelpBanniere.Caption := lblHelpBanniere.Caption + #$0A + 'des CALLIDUS-DISPLAY';

  lblHelpFullScreen.Caption := 'Les noms des fichiers de publicité pour les bannières au-dessus de la vitesse doivent être dans un fichier texte';
  lblHelpFullScreen.Caption := lblHelpFullScreen.Caption + #$0A + 'appelé "PubFullScreen.lst". Le path complet NE DOIT pas être inclus, juste le nom du fichier et son extension.';
  lblHelpFullScreen.Caption := lblHelpFullScreen.Caption + #$0A + 'On assume que les mêmes fichiers avec les mêmes noms se trouvent dans le même répertoire que l''exécutable';
  lblHelpFullScreen.Caption := lblHelpFullScreen.Caption + #$0A + 'des CALLIDUS-DISPLAY';

  isFirstActivation := True;
  MyStatusBar.Panels[IDX_PANEL_VERSION].Text := sCALLIDUS_SYSTEM_VERSION;
  MyStatusBar.Panels[IDX_PANEL_LOCALIP].Text := 'local:' + GetLocalIpAddress;
  Caption := Application.Title + ' ' + sCALLIDUS_SYSTEM_VERSION + ' (2016-03-13)';
  RxIndex := 0;
  SetLength(RxBuffer, 16000);
  CallidusDeviceList := TCallidusDeviceList.Create;
  ListeDesDevicesLastTrenteSecondes := TStringList.Create;
  bModePublicite := False;
  bDoingAnAction := False;
end;

procedure TfrmCallidusController.FormDestroy(Sender: TObject);
begin
  FreeAndNil(CallidusDeviceList);
  FreeAndNil(ListeDesDevicesLastTrenteSecondes);
end;

procedure TfrmCallidusController.LoadConfiguration;
var
  ConfigFile: TIniFile;
  bDebugWasVisible: Boolean;
  sMaybeRatio, sMaybeFilename: string;
  iRatio: integer;

  procedure LoadThisCheckList(paramCheckList: tCheckListCallidus; sPrefix: string);
  var
    iRendu, iMaybePos: integer;
  begin
    iRendu := 0;
    repeat
      sMaybeFilename := ConfigFile.ReadString(CALLIDUSCONTROLLERCONFIGSECTION, sPrefix + IntToStr(iRendu), STOPPER);
      iMaybePos := paramCheckList.Items.IndexOf(sMaybeFilename);
      if iMaybePos <> -1 then
        paramCheckList.Checked[iMaybePos] := True;
      inc(iRendu);
    until sMaybeFilename = STOPPER;

    sMaybeFilename := ConfigFile.ReadString(CALLIDUSCONTROLLERCONFIGSECTION, sPrefix + 'Selected', STOPPER);
    iMaybePos := paramCheckList.Items.IndexOf(sMaybeFilename);
    if iMaybePos <> -1 then
      paramCheckList.ItemIndex := iMaybePos
    else
      paramCheckList.ItemIndex := -1;
  end;

begin
  ConfigFile := TIniFile.Create(NomFichierConfiguration);
  try
    with ConfigFile do
    begin
      LoadWindowConfig(ConfigFile, Self, CALLIDUSCONTROLLERCONFIGSECTION);
      LoadWindowConfig(ConfigFile, frmDebugWindow, DEBUGWINDOWSECTION);
      bDebugWasVisible := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'bDebugWasVisible', False);
      if bDebugWasVisible then
        frmDebugWindow.Show;
      miSaveLogEachTime.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'cbSaveLogEachTimeWhenQuiting', True);
      miFullCommunicationLog.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'miFullCommunicationLog', False);
      //    miFullCommunicationLog.Checked := False;
      miFullCommunicationLogClick(miFullCommunicationLog);
      edServiceSpeedUnit.Checkbox.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'edServiceSpeedUnitcb', True);
      edServiceSpeedUnit.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edServiceSpeedUnited2', 'kmh');
      sMaybeRatio := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'sMaybeRatio', '25%');
      cbShadowSize.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbShadowSize', 10);
      cbUnitShadowSize.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbUnitShadowSize', 5);
      pnlBackground.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlBackground', clGreen);
      pnlSpeedCote1.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeed', clWhite);
      pnlSpeedShadow.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeedShadow', clBlack);
      pnlUnit.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnit', clYellow);
      pnlUnitShadow.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnitShadow', clBlack);
      pgMainPagecontrol.ActivePageIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pgMainPagecontrol', 0);
      edPositionSpeedY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edPositionSpeedY', '230');
      edTailleSpeedY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleSpeedY', '600');
      edUnitPosY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edUnitPosY', '380');
      edTailleUnitY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleUnitY', '170');
      edServiceSpeedUnitSubCheckboxClick(edServiceSpeedUnit.Checkbox);
      cbDisplayFullScreenTime.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbDisplayFullScreenTime', 5);
      rgPubType.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'rgPubType', 1);
      rgModePubBanniere.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'rgModePubBanniere', 0);
      LoadThisCheckList(clCommenditaire, 'fsPub');
      LoadThisCheckList(clCommdtBanniere, 'bnPub');
      edLowServiceSpeed.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'LowLimitServiceSpeed', '50');
      edHighServiceSpeed.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'HighLimitServiceSpeed', '200');
      edShowTimeServiceSpeed.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'TimeToShowServiceSpeed', '2000');
      edLowInactivitySpeed.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'LowLimitInactivitySpeed', '40');
      edHighInactivitySpeed.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'HighLimitInactivitySpeed', '200');
      edInactivityTime.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'TimeInactivitySpeed', '5000');
      ckbPubBanniere.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'ckbPubBanniere', True);
      ckbPubBanniereClick(ckbPubBanniere);
      edtRadarTestTempsOn.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edtRadarTestTempsOn', '250');
      edtRadarTestTempsOff.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edtRadarTestTempsOff', '100');
      ckbTempsOffBetweenTest.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'ckbTempsOffBetweenTest', True);
      // ..LoadConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

procedure TfrmCallidusController.miFullCommunicationLogClick(Sender: TObject);
begin
  ProtocolePROTO_Controller.WriteDebug := miFullCommunicationLog.Checked;
  ProtocolePROTO_Display.WriteDebug := miFullCommunicationLog.Checked;
  ProtocolePROTO_Radar.WriteDebug := miFullCommunicationLog.Checked;
end;

procedure TfrmCallidusController.pnlBackgroundClick(Sender: TObject);
var
  dispatcher: integer;
  pnlWorking: TPanel;
begin
  pnlWorking := nil;

  with sender as TComponent do
    Dispatcher := tag;
  case Dispatcher of
    1: pnlWorking := pnlBackground;
    2: pnlWorking := pnlSpeedCote1;
    3: pnlWorking := pnlSpeedShadow;
    4: pnlWorking := pnlUnit;
    5: pnlWorking := pnlUnitShadow;
  end;

  if pnlWorking <> nil then
  begin
    ColorDialog1.Color := pnlWorking.Color;
    if ColorDialog1.Execute then
      pnlWorking.Color := ColorDialog1.Color;
  end;

end;

procedure TfrmCallidusController.SaveConfiguration;
var
  ConfigFile: TIniFile;

  procedure SaveThisCheckList(paramCheckList: tCheckListCallidus; sPrefix: string);
  var
    iIndexfile, iRendu: integer;
  begin
    iRendu := 0;
    for iIndexFile := 0 to pred(paramCheckList.Items.Count) do
      if paramCheckList.Checked[iIndexfile] then
      begin
        ConfigFile.WriteString(CALLIDUSCONTROLLERCONFIGSECTION, sPrefix + IntToStr(iRendu), paramCheckList.Items.Strings[iIndexFile]);
        inc(iRendu);
      end;
    ConfigFile.WriteString(CALLIDUSCONTROLLERCONFIGSECTION, sPrefix + IntToStr(iRendu), STOPPER);

    if paramCheckList.ItemIndex <> -1 then
      ConfigFile.WriteString(CALLIDUSCONTROLLERCONFIGSECTION, sPrefix + 'Selected', paramCheckList.Items.Strings[paramCheckList.ItemIndex]);
  end;

begin
  ConfigFile := TIniFile.Create(NomFichierConfiguration);
  try
    with ConfigFile do
    begin
      SaveWindowConfig(ConfigFile, Self, CALLIDUSCONTROLLERCONFIGSECTION);
      SaveWindowConfig(ConfigFile, frmDebugWindow, DEBUGWINDOWSECTION);
      WriteBool(CALLIDUSCONTROLLERCONFIGSECTION, 'bDebugWasVisible', frmDebugWindow.Visible);
      WriteBool(CALLIDUSCONTROLLERCONFIGSECTION, 'cbSaveLogEachTimeWhenQuiting', miSaveLogEachTime.Checked);
      WriteBool(CALLIDUSCONTROLLERCONFIGSECTION, 'miFullCommunicationLog', miFullCommunicationLog.Checked);
      WriteBool(CALLIDUSCONTROLLERCONFIGSECTION, 'edServiceSpeedUnitcb', edServiceSpeedUnit.Checkbox.Checked);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edServiceSpeedUnited2', edServiceSpeedUnit.Text);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbShadowSize', cbShadowSize.ItemIndex);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbUnitShadowSize', cbUnitShadowSize.ItemIndex);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlBackground', pnlBackground.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeed', pnlSpeedCote1.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeedShadow', pnlSpeedShadow.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnit', pnlUnit.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnitShadow', pnlUnitShadow.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pgMainPagecontrol', pgMainPagecontrol.ActivePageIndex);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edPositionSpeedY', edPositionSpeedY.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleSpeedY', edTailleSpeedY.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edUnitPosY', edUnitPosY.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleUnitY', edTailleUnitY.Text);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbDisplayFullScreenTime', cbDisplayFullScreenTime.ItemIndex);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'rgPubType', rgPubType.ItemIndex);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'rgModePubBanniere', rgModePubBanniere.ItemIndex);
      SaveThisCheckList(clCommenditaire, 'fsPub');
      SaveThisCheckList(clCommdtBanniere, 'bnPub');
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'LowLimitServiceSpeed', edLowServiceSpeed.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'HighLimitServiceSpeed', edHighServiceSpeed.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'TimeToShowServiceSpeed', edShowTimeServiceSpeed.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'LowLimitInactivitySpeed', edLowInactivitySpeed.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'HighLimitInactivitySpeed', edHighInactivitySpeed.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'TimeInactivitySpeed', edInactivityTime.Text);
      WriteBool(CALLIDUSCONTROLLERCONFIGSECTION, 'ckbPubBanniere', ckbPubBanniere.Checked);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edtRadarTestTempsOn', edtRadarTestTempsOn.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edtRadarTestTempsOff', edtRadarTestTempsOff.Text);
      WriteBool(CALLIDUSCONTROLLERCONFIGSECTION, 'ckbTempsOffBetweenTest', ckbTempsOffBetweenTest.Checked);
      // ..SaveConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

{ TfrmCallidusController.ProtocolePROTO_ControllerServerPacketReceived}
procedure TfrmCallidusController.ProtocolePROTO_ControllerServerPacketReceived(Sender: TObject; ABinding: TIdSocketHandle; const AData: TIdBytes; Answer7: AnsiString; PayloadData: TStringList);
var
  slVariablesNames, slVariablesValues: TStringList;
  ServiceSpeedInfo: TServiceSpeed;
  iIndexGeneric: integer;
begin
  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;

  try
    case TProtocoleProto(Sender).CommandList.IndexOf(Answer7) of
      PROTO_CMD_IMALIVE:
        begin
          AjouteOrUpdateOutListWithThisDevice(ABinding.PeerIP, PayloadData);
        end;

      PROTO_CMD_SNDINFO:
        begin
          CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);

          if bModePublicite = False then
          begin
            ServiceSpeedInfo.CurrentPeakSpeed := -2;
            iIndexGeneric := slVariablesNames.IndexOf(CALLIDUS_CMD_GOTASERVICESPEED);
            if iIndexGeneric <> -1 then ServiceSpeedInfo.CurrentPeakSpeed := StrToIntDef(slVariablesValues.Strings[iIndexGeneric], -1);
            iIndexGeneric := slVariablesNames.IndexOf(CALLIDUS_CMD_SERVICEDIRECTION);
            if iIndexGeneric <> -1 then ServiceSpeedInfo.CurrentPeekDirection := StrToIntDef(slVariablesValues.Strings[iIndexGeneric], 0);
            if ServiceSpeedInfo.CurrentPeakSpeed <> -2 then InformeDisplayDuneNouvelleVitesse(ServiceSpeedInfo);
          end;
        end;

      PROTO_CMD_RDRINFO:
        begin
          ProcessInfoForSpeedParam(PayloadData);
          CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);
          iIndexGeneric := slVariablesNames.IndexOf(CALLIDUS_INFO_RESOLXY);
          if iIndexGeneric <> -1 then
          begin
            lblResolution.Caption := slVariablesValues.Strings[iIndexGeneric];
            lblHintForResolution.Visible := True;
            lblResolution.Visible := True;
          end;
        end;

      PROTO_CMD_RESOLIS:
        begin

        end;
    end;

  finally
    slVariablesNames.Free;
    slVariablesValues.Free;
  end;
end;

procedure TfrmCallidusController.RefreshListTimerTimer(Sender: TObject);
begin
  RefreshListTimer.Enabled := False;
  try
    lbDeviceDetected.Refresh;
  finally
    RefreshListTimer.Enabled := True;
  end;
end;

procedure TfrmCallidusController.WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
begin
  if sDebugLineFrench = '' then
    sDebugLineFrench := sDebugLineEnglish;
  frmDebugWindow.StatusWindow.WriteStatusLg(sDebugLineEnglish, sDebugLineFrench, clColorRequested);
end;

procedure TfrmCallidusController.DisableToute;
var
  iAction: Integer;
begin
  frmDebugWindow.StatusWindow.Clear;
  frmDebugWindow.StatusWindow.Color := COLORBACK_WORKING;
  bOverAllActionResult := False;
end;

procedure TfrmCallidusController.edServiceSpeedUnitSubCheckboxClick(Sender: TObject);
begin
  edUnitPosY.Enabled := edServiceSpeedUnit.Checkbox.Checked;
  edTailleUnitY.Enabled := edServiceSpeedUnit.Checkbox.Checked;
  pnlUnit.Enabled := edServiceSpeedUnit.Checkbox.Checked;
  pnlUnitShadow.Enabled := edServiceSpeedUnit.Checkbox.Checked;
  lblUnitTailleShadow.Enabled := edServiceSpeedUnit.Checkbox.Checked;
  cbUnitShadowSize.Enabled := edServiceSpeedUnit.Checkbox.Checked;
  lblUnitColor.Enabled := edServiceSpeedUnit.Checkbox.Checked;
  lblUnitShadowcolor.Enabled := edServiceSpeedUnit.Checkbox.Checked;
end;

procedure TfrmCallidusController.EnableToute;
var
  iAction: Integer;
  sNomFichierLog: string;
begin
  for iAction := 0 to pred(amMainActionManager.ActionCount) do
    if (amMainActionManager.Actions[iAction].Tag and $01) <> $01 then
      amMainActionManager.Actions[iAction].Enabled := True;
  if bOverAllActionResult then
  begin
    frmDebugWindow.StatusWindow.Color := COLORBACK_SUCCESS;
  end
  else
  begin
    frmDebugWindow.StatusWindow.Color := COLORBACK_ERROR;
    if not frmDebugWindow.Visible then
      frmDebugWindow.Show;
  end;

  sNomFichierLog := GetLogFilename('', 'log', 'CallidusServer');
  WriteStatusLg('Log will be saved under this name: ' + sNomFichierLog, 'Le journal sera sauvegarder sous le nom: ' + sNomFichierLog, COLORSTATUS);
  frmDebugWindow.StatusWindow.PlainText := True;
  frmDebugWindow.StatusWindow.Lines.SaveToFile(sNomFichierLog, TEncoding.ANSI);
end;

{ TfrmCallidusController.evMainApplicationEventsIdle}
procedure TfrmCallidusController.evMainApplicationEventsIdle(Sender: TObject; var Done: Boolean);
begin
  Application.ProcessMessages;
  if isFirstActivation then
  begin
    isFirstActivation := False;
    btnCommanditClick(btnCommandFull);
    btnCommanditClick(btnBanniere);
    LoadConfiguration;

    ProtocolePROTO_Controller.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Controller.WorkingServerUDP.DefaultPort := PORT_CALLIDUS_CONTROLLER;
    ProtocolePROTO_Controller.Init;

    ProtocolePROTO_Radar.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Radar.WorkingClientUDP.Port := PORT_CALLIDUS_RADAR;
    ProtocolePROTO_Radar.Init;

    ProtocolePROTO_Display.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Display.WorkingClientUDP.Port := PORT_CALLIDUS_DISPLAY;
    ProtocolePROTO_Display.Init;

    tmrBroadcastServerLocation.Interval:=2000;
    tmrBroadcastServerLocation.Enabled:=True;
  end;
end;

{ TfrmCallidusController.AjouteOrUpdateOutListWithThisDevice}
procedure TfrmCallidusController.AjouteOrUpdateOutListWithThisDevice(const sRemoteStationAddress: string; PayloadData: TStringList);
var
  PayloadDataRequest, slVariablesNames, slVariablesValues: TStringList;
  iNewPos, iIndexDevice, iIndexComputerName, iIndexComplementName, iIndexCommand, iIndexGeneric, iIndexVersionName: Integer;
  sRemoteDevice, sRemoteVersion: string;
  sPerte: AnsiString;
  localDeviceType: tDeviceType;
  ServiceSpeedInfo: TServiceSpeed;
begin
  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;
  try
    CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);
    iIndexDevice := slVariablesNames.IndexOf(CALLIDUS_INFO_DEVICETYPE);
    iIndexComputerName := slVariablesNames.IndexOf(CALLIDUS_INFO_COMPUTERNAME);
    iIndexComplementName := slVariablesNames.IndexOf(CALLIDUS_INFO_COMPLEMENTNAME);
    iIndexVersionName := slVariablesNames.IndexOf(CALLIDUS_INFO_VERSION);
    if iIndexVersionName = -1 then
      sRemoteVersion := 'Inconnue!'
    else
      sRemoteVersion := slVariablesValues.Strings[iIndexVersionName];

    if (iIndexDevice <> -1) and (iIndexComputerName <> -1) and (iIndexComplementName <> -1) then
    begin
      localDeviceType := dtUnknown;
      if slVariablesValues.Strings[iIndexDevice] = sCALLIDUS_DEVICE_NAME_RADAR then
        localDeviceType := dtCallidusRadar;
      if slVariablesValues.Strings[iIndexDevice] = sCALLIDUS_DEVICE_NAME_DISPLAY then
        localDeviceType := dtCallidusDisplay;

      iNewPos := CallidusDeviceList.Add(localDeviceType, sRemoteStationAddress, slVariablesValues.Strings[iIndexComputerName], slVariablesValues.Strings[iIndexDevice], slVariablesValues.Strings[iIndexComplementName], sRemoteVersion);
      if iNewPos <> -1 then
      begin
        sRemoteDevice := TCallidusDevice(CallidusDeviceList.Device[iNewPos]).GetDisplayName;
        lbDeviceDetected.Items.Add(sRemoteDevice);
        WriteStatusLg('New device detected: ' + TCallidusDevice(CallidusDeviceList.Device[iNewPos]).GetFullName, 'Nouvel appareil détecté: ' + TCallidusDevice(CallidusDeviceList.Device[iNewPos]).GetFullName, COLORSUCCESS);
        if sRemoteVersion <> sCALLIDUS_SYSTEM_VERSION then
        begin
          frmDebugWindow.StatusWindow.WriteStatus('ERREUR: ICOMPATIBILITÉ DE VERSION POUR CE DEVICE!', COLORERROR);
          frmDebugWindow.StatusWindow.WriteStatus('Version du CALLIDUS-CONTROLLER: ' + sCALLIDUS_SYSTEM_VERSION, COLORERROR);
          frmDebugWindow.StatusWindow.WriteStatus(' Version application-satellite: ' + sRemoteVersion, COLORERROR);
          if not frmDebugWindow.Visible then frmDebugWindow.Show;
        end;
      end;
    end;

  finally
    FreeAndNil(slVariablesNames);
    FreeAndNil(slVariablesValues);
  end;
end;

procedure TfrmCallidusController.ProcessInfoForSpeedParam(PayloadData: TStringList);
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
  finally
    FreeAndNil(slVariablesNames);
    FreeAndNil(slVariablesValues);
  end;
end;

end.

