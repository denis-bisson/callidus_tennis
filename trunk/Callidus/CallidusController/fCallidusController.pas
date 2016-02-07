unit fCallidusController;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, Vcl.Menus, Vcl.ComCtrls,
  Vcl.StdCtrls, System.Win.ScktComp, Vcl.AppEvnts,

  // Third Party
  IdGlobal,

  // My Stuff
  uCommonStuff, Vcl.ExtCtrls, IdUDPServer, IdSocketHandle, IdBaseComponent,
  IdComponent, IdUDPBase, uProtocolePROTO, EnhancedLabeledEdit, Vcl.CheckLst,
  MyEnhancedCheckList, Vcl.ToolWin, System.ImageList, Vcl.ImgList;

type
  tDeviceType = (dtUnknown, dtCallidusRadar, dtCallidusDisplay);

  TCallidusDevice = class
  public
    DeviceType: tDeviceType;
    sIPAddress: string;
    sComputerName: string;
    sName: string;
    sComplementName: string;
    dwLastTimeItWasSeen: dword;
    constructor Create(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string);
    function GetDisplayName: string;
    function GetFullName: string;
  end;

  TCallidusDeviceList = class(TList)
  private
    function GetDevice(Index: integer): TCallidusDevice;
  public
    constructor Create;
    procedure Clear; override;
    function Add(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string): integer;
    property Device[Index: integer]: TCallidusDevice read GetDevice;
  end;

  TfrmCallidusController = class(TForm)
    MyStatusBar: TStatusBar;
    mmMainMenu: TMainMenu;
    Actions1: TMenuItem;
    amMainActionManager: TActionManager;
    actCloseApplication: TAction;
    Closeapplication1: TMenuItem;
    ServerSocketForRadar: TServerSocket;
    evMainApplicationEvents: TApplicationEvents;
    actToggleDebugWindow: TAction;
    View1: TMenuItem;
    oggleDebugWindow1: TMenuItem;
    actStartServicing: TAction;
    N1: TMenuItem;
    StartServicing1: TMenuItem;
    ProtocolePROTO_Radar: TProtocole_PROTO;
    miSaveLogEachTime: TMenuItem;
    ProtocolePROTO_Display: TProtocole_PROTO;
    csSocketDisplay: TClientSocket;
    actTestCommWithDisplay: TAction;
    estcommunicationwithCallidusDisplay1: TMenuItem;
    actCloseAllCallidusApplications: TAction;
    Action11: TMenuItem;
    AutoStartTimer: TTimer;
    IdUDPServerController: TIdUDPServer;
    ProtocolePROTO_Detection: TProtocole_PROTO;
    pgMainPagecontrol: TPageControl;
    Devices: TTabSheet;
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
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton4: TToolButton;
    ToolButton3: TToolButton;
    ToolButton7: TToolButton;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    ToolButton8: TToolButton;
    pnlBackground: TPanel;
    cbCommenditaireIndex: TComboBox;
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
    Label8: TLabel;
    Label4: TLabel;
    edServiceSpeedUnit: TGlobal6LabeledEdit;
    lbDeviceDetected: TListBox;
    RefreshListTimer: TTimer;
    pnlSpeedCote2: TPanel;
    Label3: TLabel;
    tsPlayer: TTabSheet;
    EditJoueur1: TLabeledEdit;
    EditJoueur2: TLabeledEdit;
    Button1: TButton;
    actSwapPlayers: TAction;
    cbShowPlayerName: TCheckBox;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label11: TLabel;
    pnlCouleurPlayerRectangle: TPanel;
    edRectangleHeight: TLabeledEdit;
    edPlayerSizeText: TLabeledEdit;
    pnlCouleurPlayerText1: TPanel;
    Label9: TLabel;
    pnlCouleurPlayerText2: TPanel;
    edPlayerPosY: TLabeledEdit;
    ToolButton9: TToolButton;
    cbCommenditairePleinEcran: TComboBox;
    Label10: TLabel;
    actStartPub: TAction;
    tsPub: TTabSheet;
    ToolButton10: TToolButton;
    Label12: TLabel;
    clCommenditaire: TCheckListGlobal6;
    Button2: TButton;
    rgPubType: TRadioGroup;
    cbDisplayFullScreenTime: TComboBox;
    Label13: TLabel;
    TimerPublicityFullScreen: TTimer;
    procedure actCloseApplicationExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure evMainApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actToggleDebugWindowExecute(Sender: TObject);
    procedure actStartServicingExecute(Sender: TObject);
    procedure WriteStatusLg(sDebugLineEnglish: string; sDebugLineFrench: string = ''; clColorRequested: dword = COLORSTATUS);
    procedure ProtocolePROTO_RadarServerSocketValidPacketReceived(Sender: TObject; Socket: TCustomWinSocket; Answer7: AnsiString; PayloadData: TStringList);
    procedure actTestCommWithDisplayExecute(Sender: TObject);
    function InformeDisplayDuneNouvelleVitesse(paramInfoSpeed: TServiceSpeed): boolean;
    function SendDisplayGenericCommand(ProtoCommand: integer; deviceType: tDeviceType; params: array of string): boolean;
    procedure DisableToute;
    procedure EnableToute;
    procedure actCloseAllCallidusApplicationsExecute(Sender: TObject);
    procedure AutoStartTimerTimer(Sender: TObject);
    procedure actFlushCurrentDetectedListExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miFullCommunicationLogClick(Sender: TObject);
    procedure evMainApplicationEventsException(Sender: TObject; E: Exception);
    procedure pnlBackgroundClick(Sender: TObject);
    procedure actSetInFullScreenExecute(Sender: TObject);
    procedure actSetInNormalScreenExecute(Sender: TObject);
    procedure AddToMyArray(var Params: array of string; var icurrentIndexInArray: integer; const sToAdd: string);
    procedure CleanMonArray(var Params: array of string);
    procedure edServiceSpeedUnitSubCheckboxClick(Sender: TObject);
    procedure lbDeviceDetectedDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure RefreshListTimerTimer(Sender: TObject);
    procedure actSwapPlayersExecute(Sender: TObject);
    procedure actStartPubExecute(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DoLaPub;
    procedure TimerPublicityFullScreenTimer(Sender: TObject);

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
  public
    { Public declarations }
  end;

var
  frmCallidusController: TfrmCallidusController;

implementation

{$R *.dfm}

uses
  // Delphi
  IniFiles, StrUtils,

  // Third party

  // My stuff
  fDebugWindow;

const
  IDX_PANEL_LOCALIP = 0;

  { TCallidusDevice.Create }
constructor TCallidusDevice.Create(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string);
begin
  Self.DeviceType := paramDeviceType;
  Self.sIPAddress := paramIPAddress;
  Self.sComputerName := paramComputerName;
  Self.sName := paramName;
  Self.sComplementName := paramComplementName;
  Self.dwLastTimeItWasSeen := GetTickCount;
end;

{ TCallidusDevice.GetDisplayName }
function TCallidusDevice.GetDisplayName: string;
begin
  result := Self.sName + ' - ' + Self.sComputerName + ' - ' + Self.sComplementName;
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
function TCallidusDeviceList.Add(const paramDeviceType: tDeviceType; const paramIPAddress: string; const paramComputerName: string; const paramName: string; const paramComplementName: string): integer;
var
  WorkingCallidusDevice: TCallidusDevice;
  iPromeneur: integer;
  bAlreadyPresent: boolean;
begin
  result := -1;
  iPromeneur := 0;
  bAlreadyPresent := FALSE;

  while (iPromeneur < count) and (not bAlreadyPresent) do
  begin
    bAlreadyPresent :=
      ((TCallidusDevice(Items[iPromeneur]).DeviceType = paramDeviceType) and
      (TCallidusDevice(Items[iPromeneur]).sIPAddress = paramIPAddress) and
      (TCallidusDevice(Items[iPromeneur]).sComputerName = paramComputerName) and
      (TCallidusDevice(Items[iPromeneur]).sName = paramName) and
      (TCallidusDevice(Items[iPromeneur]).sComplementName = paramComplementName));

    inc(iPromeneur);
  end;

  if not bAlreadyPresent then
  begin
    WorkingCallidusDevice := TCallidusDevice.Create(paramDeviceType, paramIPAddress, paramComputerName, paramName, paramComplementName);
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

procedure TfrmCallidusController.TimerPublicityFullScreenTimer(Sender: TObject);
begin
  TimerPublicityFullScreen.Enabled := False;
  try
    DoLaPub;
  finally
    TimerPublicityFullScreen.Enabled := True;
  end;
end;

procedure TfrmCallidusController.DoLaPub;
var
  iMaybeIndex: integer;
  sNomFichier: string;
  iPreviousIndex: integer;
  iLastChecked, iNbChecked, iIndex: integer;
begin
  if clCommenditaire.Items.Count > 0 then
  begin
    iMaybeIndex := 0;
    iNbChecked := 0;
    iLastChecked := 0;

    if clCommenditaire.ItemIndex = -1 then
      clCommenditaire.ItemIndex := 0;

    for iIndex := 0 to pred(clCommenditaire.Items.Count) do
      if clCommenditaire.Checked[iIndex] then
      begin
        inc(iNbChecked);
        iLastChecked := iIndex;
      end;

    if iNbChecked = 0 then
      clCommenditaire.Checked[0] := True;

    iPreviousIndex := clCommenditaire.ItemIndex;

    case rgPubType.ItemIndex of
      0:
        begin
          iMaybeIndex := clCommenditaire.ItemIndex;
        end;

      1, 2:
        begin
          if iNbChecked = 1 then
          begin
            iMaybeIndex := iLastchecked
          end
          else
          begin
            case rgPubType.ItemIndex of
              1:
                begin
                  repeat
                    clCommenditaire.ItemIndex := ((clCommenditaire.ItemIndex + 1) mod clCommenditaire.Items.Count);
                    iMaybeIndex := clCommenditaire.ItemIndex;
                  until clCommenditaire.Checked[iMaybeIndex]
                end;

              2:
                begin
                  repeat
                    iMaybeIndex := random(clCommenditaire.Items.Count);
                  until (clCommenditaire.Checked[iMaybeIndex]) and (iMaybeIndex <> iPreviousIndex);
                end;
            end;
          end;
        end;
    end;

    if clCommenditaire.ItemIndex <> -1 then
    begin
      sNomFichier := clCommenditaire.Items.Strings[iMaybeIndex];
      bOverAllActionResult := SendDisplayGenericCommand(PROTO_CMD_DISCRTC, dtCallidusDisplay, [CALLIDUS_CMD_SET_FULL_SCREEN_PUBLICITY + '=' + sNomFichier]);
    end;
  end;
end;

procedure TfrmCallidusController.actStartPubExecute(Sender: TObject);
var
  sNomFichier: string;
begin
  DisableToute;
  try
    DoLaPub;
    TimerPublicityFullScreen.Interval := 1000 * StrToIntDef(cbDisplayFullScreenTime.Items.Strings[cbDisplayFullScreenTime.ItemIndex], 2000);
    TimerPublicityFullScreen.Enabled := True;
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.actStartServicingExecute(Sender: TObject);
begin
  try
    ServerSocketForRadar.Port := PORT_FOR_SENDING_CONTROLLER;
    WriteStatusLg('About to open server...', 'Sur le point d''ouvrir le serveur...', COLORDANGER);
    ServerSocketForRadar.Open;
    Application.ProcessMessages;
    if ServerSocketForRadar.Active then
    begin
      WriteStatusLg('Server opened successfully!', 'Le serveur a été ouvert avec succès!', COLORSUCCESS);

      IdUDPServerController.DefaultPort := PORT_FOR_IDENTIFICATION;
      if not IdUDPServerController.Active then
        IdUDPServerController.Active := TRUE;
    end
    else
    begin
      WriteStatusLg('ERROR: Failed to open server!', 'ERREUR: Problème d''ouverture du serveur...,COLORERROR)', COLORERROR);
    end;
  except
    WriteStatusLg('ERROR: Exception while in "actStartServicingExecute"...', 'ERREUR: Exception durant "actStartServicingExecute"...', COLORERROR);
  end;
end;

procedure TfrmCallidusController.actSwapPlayersExecute(Sender: TObject);
var
  sTempo: string;
begin
  sTempo := EditJoueur1.Text;
  EditJoueur1.Text := EditJoueur2.Text;
  EditJoueur2.Text := sTempo;
end;

procedure TfrmCallidusController.actSetInFullScreenExecute(Sender: TObject);
begin
  DisableToute;
  try
    bOverAllActionResult := SendDisplayGenericCommand(PROTO_CMD_DISCRTC, dtCallidusDisplay, [CALLIDUS_CMD_ADJUSTSCREEN + '=' + sDISPLAY_PARAM_FULLSCREEN]);
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.actSetInNormalScreenExecute(Sender: TObject);
begin
  DisableToute;
  try
    bOverAllActionResult := SendDisplayGenericCommand(PROTO_CMD_DISCRTC, dtCallidusDisplay, [CALLIDUS_CMD_ADJUSTSCREEN + '=' + sDISPLAY_PARAM_NORMALSCREEN]);
  finally
    EnableToute;
  end;
end;

procedure TfrmCallidusController.actTestCommWithDisplayExecute(Sender: TObject);
var
  ServiceSpeedTemporaire: TServiceSpeed;
begin
  DisableToute;
  try
    ServiceSpeedTemporaire.CurrentPeakSpeed := (100 + random(100));
    ServiceSpeedTemporaire.CurrentPeekDirection := (1 + random(2));
    bOverAllActionResult := InformeDisplayDuneNouvelleVitesse(ServiceSpeedTemporaire);
  finally
    EnableToute;
  end;
end;

function TfrmCallidusController.SendDisplayGenericCommand(ProtoCommand: integer; deviceType: tDeviceType; params: array of string): boolean;
var
  PayloadDataRequest, PayloadDataAnswer: TStringList;
  Answer: AnsiString;
  iDevice, iParam: integer;
begin
  PayloadDataRequest := TStringList.Create;
  PayloadDataAnswer := TStringList.Create;
  try
    result := TRUE;

    for iParam := 0 to pred(length(params)) do
      if params[iParam] <> '' then
        PayloadDataRequest.Add(params[iParam]);

    for iDevice := 0 to pred(CallidusDeviceList.Count) do
    begin
      if CallidusDeviceList.Device[iDevice].DeviceType = deviceType then
      begin
        ProtocolePROTO_Display.WorkingClientSocket.Address := CallidusDeviceList.Device[iDevice].sIPAddress;
        ProtocolePROTO_Display.WorkingClientSocket.Port := PORT_FOR_SENDING_DISPLAY;
        if not ProtocolePROTO_Display.PitchUnMessageAndGetResponsePROTO(ProtoCommand, PayloadDataRequest, Answer) > 0 then
          result := FALSE;
        Application.ProcessMessages;
      end;
    end;

  finally
    FreeAndNil(PayloadDataAnswer);
    FreeAndNil(PayloadDataRequest);
  end;
end;

procedure TfrmCallidusController.AddToMyArray(var Params: array of string; var icurrentIndexInArray: integer; const sToAdd: string);
begin
  Params[icurrentIndexInArray] := sToAdd;
  inc(icurrentIndexInArray);
end;

procedure TfrmCallidusController.CleanMonArray(var Params: array of string);
var
  iElement: integer;
begin
  for iElement := 0 to pred(length(Params)) do Params[iElement] := '';
end;

function TfrmCallidusController.InformeDisplayDuneNouvelleVitesse(paramInfoSpeed: TServiceSpeed): boolean;
var
  Params: array of string;
  iDevice: integer;
  sSpeedValueToShow, sSpeedUnitToShow, sSpeedRatio: string;
  icurrentIndexInArray: integer;
begin
  SetLength(Params, 20);
  CleanMonArray(Params);
  icurrentIndexInArray := 0;

  sSpeedValueToShow := '';
  sSpeedUnitToShow := '';
  sSpeedRatio := '25';

  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICEPOSY + '=' + edPositionSpeedY.Text);
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICESIZY + '=' + edTailleSpeedY.Text);
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICESPEED + '=' + IntToStr(paramInfoSpeed.CurrentPeakSpeed));
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICESHADOWSIZE + '=' + IntToStr(cbShadowSize.ItemIndex));
  AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORBACK + '=' + IntToStr(pnlBackground.Color));

  case paramInfoSpeed.CurrentPeekDirection of
    1:
      begin
        AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORSPEED + '=' + IntToStr(pnlSpeedCote1.Color));
        AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORSPEEDSHADOW + '=' + IntToStr(pnlSpeedShadow.Color));
        if cbShowPlayerName.Checked then
        begin
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERNAME + '=' + EditJoueur1.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERTXTCOLOR + '=' + IntToStr(pnlCouleurPlayerText1.Color));
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERTXTSIZE + '=' + edPlayerSizeText.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERTEXTY + '=' + edPlayerPosY.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERRECTHEIGHT + '=' + edRectangleHeight.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERRECTCOLOR + '=' + IntToStr(pnlCouleurPlayerRectangle.Color));
        end;
      end;
    2:
      begin
        AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORSPEED + '=' + IntToStr(pnlSpeedCote2.Color));
        AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORSPEEDSHADOW + '=' + IntToStr(pnlSpeedShadow.Color));
        if cbShowPlayerName.Checked then
        begin
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERNAME + '=' + EditJoueur2.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERTXTCOLOR + '=' + IntToStr(pnlCouleurPlayerText2.Color));
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERTXTSIZE + '=' + edPlayerSizeText.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERTEXTY + '=' + edPlayerPosY.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERRECTHEIGHT + '=' + edRectangleHeight.Text);
          AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_PLAYERRECTCOLOR + '=' + IntToStr(pnlCouleurPlayerRectangle.Color));
        end;
      end;
    else
      begin
        AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORSPEED + '=' + IntToStr(pnlSpeedCote1.Color));
        AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORSPEEDSHADOW + '=' + IntToStr(pnlSpeedShadow.Color));
      end;
  end;

  if edServiceSpeedUnit.Checkbox.Checked then
  begin
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICEUNITPOSY + '=' + edUnitPosY.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICEUNITSIZY + '=' + edTailleUnitY.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICEUNIT + '=' + edServiceSpeedUnit.Text);
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORUNIT + '=' + IntToStr(pnlUnit.Color));
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_COLORUNITSHADOW + '=' + IntToStr(pnlUnitShadow.Color));
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SHOWSERVICEUNITSHDY + '=' + IntToStr(cbUnitShadowSize.ItemIndex));
  end;

  if (cbCommenditaireIndex.ItemIndex >= 1) and (cbCommenditaireIndex.ItemIndex < pred(cbCommenditaireIndex.Items.Count)) then
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SSS_COMMENDITAIRE + '=' + IntToStr(cbCommenditaireIndex.ItemIndex))
  else if cbCommenditaireIndex.ItemIndex = pred(cbCommenditaireIndex.Items.Count) then
    AddToMyArray(Params, icurrentIndexInArray, CALLIDUS_CMD_SSS_COMMENDITAIRE + '=' + IntToStr(Random(cbCommenditaireIndex.Items.Count - 2) + 1));

  result := SendDisplayGenericCommand(PROTO_CMD_SNDINFO, dtCallidusDisplay, Params);
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

procedure TfrmCallidusController.AutoStartTimerTimer(Sender: TObject);
begin
  AutoStartTimer.Enabled := FALSE;
  actStartServicingExecute(actStartServicing);
end;

procedure TfrmCallidusController.Button2Click(Sender: TObject);
var
  sNomFichierList: string;
begin
  sNomFichierList := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + 'PubFullScreen.lst';
  if FileExists(sNomFichierList) then
  begin
    clCommenditaire.Clear;
    clCommenditaire.Items.LoadFromFile(sNomFichierList);
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

procedure TfrmCallidusController.evMainApplicationEventsIdle(Sender: TObject; var Done: Boolean);
begin
  Application.ProcessMessages;
  if isFirstActivation then
  begin
    isFirstActivation := FALSE;
    LoadConfiguration;
    ProtocolePROTO_Detection.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Detection.WorkingServerUDP.DefaultPort := PORT_FOR_IDENTIFICATION;
    ProtocolePROTO_Detection.Init;
    ProtocolePROTO_Radar.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Radar.WorkingServerSocket.Port := PORT_FOR_SENDING_CONTROLLER;
    ProtocolePROTO_Radar.Init;
    ProtocolePROTO_Display.MessageWindow := frmDebugWindow.StatusWindow;
    ProtocolePROTO_Display.Init;
    AutoStartTimer.Enabled := TRUE;
    RefreshListTimer.Enabled := True;
  end;
end;

procedure TfrmCallidusController.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ProtocolePROTO_Radar.ShutDownService;
  ProtocolePROTO_Detection.ShutDownService;
  ProtocolePROTO_Display.ShutDownService;
  Application.ProcessMessages;
  SaveConfiguration;
end;

procedure TfrmCallidusController.FormCreate(Sender: TObject);
begin
  NomFichierConfiguration := GetConfigFilename('CallidusController');
  isFirstActivation := True;
  MyStatusBar.Panels[IDX_PANEL_LOCALIP].Text := 'local:' + GetLocalIpAddress;
  Caption := Application.Title;
  RxIndex := 0;
  SetLength(RxBuffer, 16000);
  CallidusDeviceList := TCallidusDeviceList.Create;
  ListeDesDevicesLastTrenteSecondes := TStringList.Create;
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
  sMaybeRatio: string;
  iRatio: integer;
begin
  ConfigFile := TIniFile.Create(NomFichierConfiguration);
  try
    with ConfigFile do
    begin
      LoadWindowConfig(ConfigFile, Self, CALLIDUSCONTROLLERCONFIGSECTION);
      LoadWindowConfig(ConfigFile, frmDebugWindow, DEBUGWINDOWSECTION);
      bDebugWasVisible := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'bDebugWasVisible', FALSE);
      if bDebugWasVisible then
        frmDebugWindow.Show;
      miSaveLogEachTime.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'cbSaveLogEachTimeWhenQuiting', True);
      //    miFullCommunicationLog.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'miFullCommunicationLog', False);
      miFullCommunicationLog.Checked := False;
      miFullCommunicationLogClick(miFullCommunicationLog);
      edServiceSpeedUnit.Checkbox.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'edServiceSpeedUnitcb', TRUE);
      edServiceSpeedUnit.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edServiceSpeedUnited2', 'kmh');
      sMaybeRatio := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'sMaybeRatio', '25%');
      cbShadowSize.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbShadowSize', 10);
      cbUnitShadowSize.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbUnitShadowSize', 5);
      pnlBackground.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlBackground', clGreen);
      pnlSpeedCote1.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeed', clWhite);
      pnlSpeedCote2.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeed2', clYellow);
      pnlSpeedShadow.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeedShadow', clBlack);
      pnlUnit.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnit', clYellow);
      pnlUnitShadow.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnitShadow', clBlack);
      pgMainPagecontrol.ActivePageIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pgMainPagecontrol', 0);
      edPositionSpeedY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edPositionSpeedY', '230');
      edTailleSpeedY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleSpeedY', '600');
      edUnitPosY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edUnitPosY', '380');
      edTailleUnitY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleUnitY', '170');
      cbCommenditaireIndex.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbCommenditaireIndex', pred(cbCommenditaireIndex.Items.Count));
      edServiceSpeedUnitSubCheckboxClick(edServiceSpeedUnit.Checkbox);
      EditJoueur1.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'EditJoueur1', 'Joueur #1');
      EditJoueur2.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'EditJoueur2', 'Joueur #2');
      cbShowPlayerName.Checked := ReadBool(CALLIDUSCONTROLLERCONFIGSECTION, 'cbShowPlayerName', False);
      edRectangleHeight.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edRectangleHeight', '120');
      pnlCouleurPlayerRectangle.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pnlCouleurPlayerRectangle', clBlack);
      pnlCouleurPlayerText1.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pnlCouleurPlayerText1', clWhite);
      pnlCouleurPlayerText2.Color := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pnlCouleurPlayerText2', clYellow);
      edPlayerSizeText.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edSizeText', '70');
      edPlayerPosY.Text := ReadString(CALLIDUSCONTROLLERCONFIGSECTION, 'edPlayerPosY', '120');
      cbCommenditairePleinEcran.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbCommenditairePleinEcran', 0);
      cbDisplayFullScreenTime.ItemIndex := ReadInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbDisplayFullScreenTime', 5);
      // ..LoadConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

procedure TfrmCallidusController.miFullCommunicationLogClick(Sender: TObject);
begin
  ProtocolePROTO_Detection.WriteDebug := miFullCommunicationLog.Checked;
  ProtocolePROTO_Display.WriteDebug := miFullCommunicationLog.Checked;
  ProtocolePROTO_Radar.WriteDebug := miFullCommunicationLog.Checked;
end;

procedure TfrmCallidusController.pnlBackgroundClick(Sender: TObject);
var
  dispatcher: integer;
  pnlWorking: TPanel;
begin
  pnlWorking := nil;

  with sender as TComponent do Dispatcher := tag;
  case Dispatcher of
    1: pnlWorking := pnlBackground;
    2: pnlWorking := pnlSpeedCote1;
    3: pnlWorking := pnlSpeedShadow;
    4: pnlWorking := pnlUnit;
    5: pnlWorking := pnlUnitShadow;
    6: pnlWorking := pnlSpeedCote2;
    7: pnlWorking := pnlCouleurPlayerRectangle;
    8: pnlWorking := pnlCouleurPlayerText1;
    9: pnlWorking := pnlCouleurPlayerText2;
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
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeed2', pnlSpeedCote2.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlSpeedShadow', pnlSpeedShadow.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnit', pnlUnit.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'colorpnlUnitShadow', pnlUnitShadow.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pgMainPagecontrol', pgMainPagecontrol.ActivePageIndex);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edPositionSpeedY', edPositionSpeedY.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleSpeedY', edTailleSpeedY.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edUnitPosY', edUnitPosY.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edTailleUnitY', edTailleUnitY.Text);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbCommenditaireIndex', cbCommenditaireIndex.ItemIndex);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'EditJoueur1', EditJoueur1.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'EditJoueur2', EditJoueur2.Text);
      WriteBool(CALLIDUSCONTROLLERCONFIGSECTION, 'cbShowPlayerName', cbShowPlayerName.Checked);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edRectangleHeight', edRectangleHeight.Text);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pnlCouleurPlayerRectangle', pnlCouleurPlayerRectangle.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pnlCouleurPlayerText1', pnlCouleurPlayerText1.Color);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'pnlCouleurPlayerText2', pnlCouleurPlayerText2.Color);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edSizeText', edPlayerSizeText.Text);
      WriteString(CALLIDUSCONTROLLERCONFIGSECTION, 'edPlayerPosY', edPlayerPosY.Text);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbCommenditairePleinEcran', cbCommenditairePleinEcran.ItemIndex);
      WriteInteger(CALLIDUSCONTROLLERCONFIGSECTION, 'cbDisplayFullScreenTime', cbDisplayFullScreenTime.ItemIndex);
      // ..SaveConfiguration
    end;
  finally
    ConfigFile.Free;
  end;
end;

{ ProtocolePROTO_RadarServerSocketValidPacketReceived }

procedure TfrmCallidusController.ProtocolePROTO_RadarServerSocketValidPacketReceived(Sender: TObject; Socket: TCustomWinSocket; Answer7: AnsiString; PayloadData: TStringList);
var
  PayloadDataRequest, slVariablesNames, slVariablesValues: TStringList;
  iNewPos, iIndexDevice, iIndexComputerName, iIndexComplementName, iIndexCommand, iIndexGeneric: Integer;
  sRemoteDevice: string;
  sPerte: AnsiString;
  localDeviceType: tDeviceType;
  ServiceSpeedInfo: TServiceSpeed;
begin
  slVariablesNames := TStringList.Create;
  slVariablesValues := TStringList.Create;
  try
    iIndexCommand := ProtocolePROTO_Radar.CommandList.IndexOf(Answer7);

    case iIndexCommand of
      PROTO_CMD_IMALIVE:
        begin
          CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);
          ProtocolePROTO_Radar.ServerSocketReplyAnswer(Socket, PROTO_CMD_SMPLACK, nil);
          iIndexDevice := slVariablesNames.IndexOf(CALLIDUS_INFO_DEVICETYPE);
          iIndexComputerName := slVariablesNames.IndexOf(CALLIDUS_INFO_COMPUTERNAME);
          iIndexComplementName := slVariablesNames.IndexOf(CALLIDUS_INFO_COMPLEMENTNAME);
          if (iIndexDevice <> -1) and (iIndexComputerName <> -1) and (iIndexComplementName <> -1) then
          begin
            localDeviceType := dtUnknown;
            if slVariablesValues.Strings[iIndexDevice] = 'Callidus-Radar' then localDeviceType := dtCallidusRadar;
            if slVariablesValues.Strings[iIndexDevice] = 'Callidus-Display' then localDeviceType := dtCallidusDisplay;

            iNewPos := CallidusDeviceList.Add(localDeviceType, Socket.RemoteAddress, slVariablesValues.Strings[iIndexComputerName], slVariablesValues.Strings[iIndexDevice], slVariablesValues.Strings[iIndexComplementName]);
            if iNewPos <> -1 then
            begin
              sRemoteDevice := TCallidusDevice(CallidusDeviceList.Device[iNewPos]).GetDisplayName;
              lbDeviceDetected.Items.Add(sRemoteDevice);
              WriteStatusLg('New device detected: ' + TCallidusDevice(CallidusDeviceList.Device[iNewPos]).GetFullName, 'Nouvel appareil détecté: ' + TCallidusDevice(CallidusDeviceList.Device[iNewPos]).GetFullName, COLORSUCCESS);
            end;
          end;

        end;

      PROTO_CMD_SNDINFO:
        begin
          CallidusSplitVariablesNamesAndValues(PayloadData, slVariablesNames, slVariablesValues);
          ProtocolePROTO_Radar.ServerSocketReplyAnswer(Socket, PROTO_CMD_SMPLACK, nil);
          Application.ProcessMessages;

          ServiceSpeedInfo.CurrentPeakSpeed := -2;
          iIndexGeneric := slVariablesNames.IndexOf(CALLIDUS_CMD_GOTASERVICESPEED);
          if iIndexGeneric <> -1 then ServiceSpeedInfo.CurrentPeakSpeed := StrToIntDef(slVariablesValues.Strings[iIndexGeneric], -1);
          iIndexGeneric := slVariablesNames.IndexOf(CALLIDUS_CMD_SERVICEDIRECTION);
          if iIndexGeneric <> -1 then ServiceSpeedInfo.CurrentPeekDirection := StrToIntDef(slVariablesValues.Strings[iIndexGeneric], 0);
          if ServiceSpeedInfo.CurrentPeakSpeed <> -2 then InformeDisplayDuneNouvelleVitesse(ServiceSpeedInfo);
        end;
    end;

  finally
    FreeAndNil(slVariablesNames);
    FreeAndNil(slVariablesValues);
  end;
end;

procedure TfrmCallidusController.RefreshListTimerTimer(Sender: TObject);
begin
  RefreshListTimer.Enabled := FALSE;
  try
    lbDeviceDetected.Refresh;
  finally
    RefreshListTimer.Enabled := TRUE;
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
  bOverAllActionResult := FALSE;
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

end.

