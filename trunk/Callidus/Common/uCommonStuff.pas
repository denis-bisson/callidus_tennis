unit uCommonStuff;

interface

uses
  // Delphi
  vcl.Graphics, vcl.Forms, IniFiles, Classes,

  // Third party
  IdGlobal;

// My stuff

procedure LoadWindowConfig(ConfigFile: TIniFile; WorkingForm: TForm; SectionName: string);
procedure SaveWindowConfig(ConfigFile: TIniFile; WorkingForm: TForm; SectionName: string);
function GetLocalIpAddress: string;
function GetSystemPath(Folder: integer): string;
function GetMyDocumentPath: string;
function GetLogFilename(sPrefix: string; sFileExtension: string; ApplicationName: string): string;
function GetConfigFilename(ApplicationName: string): string;
procedure CloseAllCallidusApplications;
function Callidus_GetNetworkUsername: string;
function Callidus_GetComputerName: string;
procedure CallidusSplitVariablesNamesAndValues(slPayloadData, slVariablesNames, slVariablesValues: TStringList);
function GetApplicationNbOfThisClass(sClassName: string): integer;

const
  COLORTX = clGreen;
  COLORRX = clNavy;
  COLORINFO = clGray;
  COLORBACK_WORKING = $D0FFFF;
  COLORBACK_SUCCESS = $D0FFD0;
  COLORBACK_ERROR = $D0D0FF;
  COLORINCOMINGSTREAM = clPurple;
  COLORFATIGUANTE = $D070FF;

  COLORERROR = clRed;
  COLORSUCCESS = clGreen;
  COLORDANGER = clOlive;
  COLORSTATUS = clBlack;

  CALLIDUSCONTROLLERCONFIGSECTION = 'CallidusControllerConfig';
  CALLIDUSDISPLAYCONFIGSECTION = 'CallidusDisplayConfig';
  DEBUGWINDOWSECTION = 'DebugWindow';

  TIMEOUT_FOR_CONNEXION = 3000;
  TIMEOUT_FOR_SIMPLE_MESSAGE = 3000;

  CALLIDUS_CMD_SHOWSERVICESPEED = 'Speed';
  CALLIDUS_CMD_SHOWSERVICEUNIT = 'Unit';
  CALLIDUS_CMD_SHOWSERVICERATIO = 'FontRatio';
  CALLIDUS_CMD_SHOWSERVICESHADOWSIZE = 'ShadowSz';
  CALLIDUS_CMD_GOTASERVICESPEED = 'NewServiceSpeed';
  CALLIDUS_CMD_COLORBACK = 'ColBack';
  CALLIDUS_CMD_COLORSPEED = 'ColSpeed';
  CALLIDUS_CMD_COLORSPEEDSHADOW = 'ColSpeedShad';
  CALLIDUS_CMD_COLORUNIT = 'ColUnit';
  CALLIDUS_CMD_COLORUNITSHADOW = 'ColUnitShad';

  CALLIDUS_INFO_COMPUTERNAME = 'ComputerName';
  CALLIDUS_INFO_DEVICETYPE = 'DeviceType';
  CALLIDUS_INFO_COMPLEMENTNAME = 'ComplementName';

  DEVICETYPE_RADAR = 'CallidusRadar';

implementation

uses
  // Delphi
  System.SysUtils, ShlObj, Windows, Messages, StrUtils,

  // Third party
  IdIPAddrMon;

// My stuff

const
  MAX_PATH = 250;

procedure LoadWindowConfig(ConfigFile: TIniFile; WorkingForm: TForm; SectionName: string);
begin
  WorkingForm.WindowState := TWindowState(ConfigFile.ReadInteger(SectionName, 'WindowState', ord(wsNormal)));

  if WorkingForm.WindowState <> wsMaximized then
  begin
    if WorkingForm.WindowState = wsMinimized then
      WorkingForm.WindowState := wsNormal;
    WorkingForm.Width := ConfigFile.ReadInteger(SectionName, 'width', WorkingForm.Constraints.MinWidth);
    WorkingForm.Height := ConfigFile.ReadInteger(SectionName, 'height', WorkingForm.Constraints.MinHeight);
  end;

  WorkingForm.Left := ConfigFile.ReadInteger(SectionName, 'left', (Screen.Width - WorkingForm.Width) div 2);
  WorkingForm.Top := ConfigFile.ReadInteger(SectionName, 'top', (Screen.Height - WorkingForm.Height) div 2);
end;

procedure SaveWindowConfig(ConfigFile: TIniFile; WorkingForm: TForm; SectionName: string);
begin
  ConfigFile.WriteInteger(SectionName, 'WindowState', ord(WorkingForm.WindowState));
  if WorkingForm.WindowState <> wsMaximized then
  begin
    ConfigFile.WriteInteger(SectionName, 'width', WorkingForm.Width);
    ConfigFile.WriteInteger(SectionName, 'height', WorkingForm.Height);
  end;

  ConfigFile.WriteInteger(SectionName, 'left', WorkingForm.Left);
  ConfigFile.WriteInteger(SectionName, 'top', WorkingForm.Top);
end;

function GetLocalIpAddress: string;
var
  iIP: integer;
  IdIPAddrMonitorer: TIdIPAddrMon;
begin
  result := '';
  IdIPAddrMonitorer := TIdIPAddrMon.Create(Application.MainForm);
  try
    IdIPAddrMonitorer.CheckAdapters(Application.MainForm);
    iIP := 0;
    while (iIP < IdIPAddrMonitorer.IPAddresses.Count) and (result = '') do
      if pos('.', IdIPAddrMonitorer.IPAddresses.Strings[iIP]) <> 0 then
        result := IdIPAddrMonitorer.IPAddresses.Strings[iIP]
      else
        inc(iIP);
    if result = '' then
      result := '0.0.0.0';
  finally
    FreeAndNil(IdIPAddrMonitorer);
  end;
end;

function GetSystemPath(Folder: integer): string;
var
  PIDL: PItemIDList;
  TempDirname: array[0..MAX_PATH] of char;
begin
  result := '';
  SHGetSpecialFolderLocation(Application.Handle, Folder, PIDL);
  if SHGetPathFromIDList(PIDL, TempDirname) then
    result := TempDirname;
end;

// Functions used for getting the "My Documents" folder or the user personnal path...

function GetMyDocumentPath: string;
begin
  result := IncludeTrailingPathDelimiter(GetSystemPath(CSIDL_PERSONAL));
end;

function GetConfigFilename(ApplicationName: string): string;
begin
  result := IncludeTrailingPathDelimiter(GetMyDocumentPath) + 'Callidus';
  if not directoryexists(result) then
    createdir(result);

  result := IncludeTrailingPathDelimiter(result) + ApplicationName;
  if not directoryexists(result) then
    createdir(result);

  result := IncludeTrailingPathDelimiter(result) + 'Config';
  if not directoryexists(result) then
    createdir(result);

  result := IncludeTrailingPathDelimiter(result) + 'Config.ini';
end;

function GetLogFilename(sPrefix: string; sFileExtension: string; ApplicationName: string): string;
var
  sPath: string;
  iAttemptNo: integer;
  wYear, wMonth, wDay, wHour, wMin, wSec, wMSec: word;
  dtFreezeMoment: tDateTime;
begin
  dtFreezeMoment := now;
  DecodeDate(dtFreezeMoment, wYear, wMonth, wDay);
  DecodeTime(dtFreezeMoment, wHour, wMin, wSec, wMSec);

  sPrefix := sPrefix + Format('%4.4d-%2.2d-%2.2d@%2.2d-%2.2d-%2.2d', [wYear, wMonth, wDay, wHour, wMin, wSec]);

  sPath := IncludeTrailingPathDelimiter(GetMyDocumentPath) + 'Callidus';
  if not directoryexists(sPath) then
    createdir(sPath);

  sPath := IncludeTrailingPathDelimiter(sPath) + ApplicationName;
  if not directoryexists(sPath) then
    createdir(sPath);

  sPath := IncludeTrailingPathDelimiter(sPath) + 'Logs';
  if not directoryexists(sPath) then
    createdir(sPath);

  sPath := IncludeTrailingPathDelimiter(sPath);

  iAttemptNo := 0;

  repeat
    result := sPath + sPrefix + Format('_%4.4d', [iAttemptNo]) + '.' + sFileExtension;
    inc(iAttemptNo);
  until not FileExists(result);

end;

function FitWithZero(paramValue: dword; paramNbOfZeros: integer): string;
begin
  result := IntToStr(paramValue);
  while length(result) < paramNbOfZeros do
    result := '0' + result;
end;

function FitOn(paramNbOfChars: integer; paramInitialString: string): string;
begin
  result := paramInitialString;
  while length(result) < paramNbOfChars do
    result := result + ' ';
end;

function EnumWindowsToStringList(wHandle: HWND; lParam: integer): Bool; stdcall; export;
var
  Title, ClassName: pChar;
  Chaine1, Chaine2: string;
begin

  try
    result := TRUE;
    Title := Stralloc(100);
    ClassName := Stralloc(100);
    GetWindowText(wHandle, Title, 99);
    GetClassName(wHandle, ClassName, 99);
    Chaine1 := Title;
    Chaine2 := ClassName;
    TStringList(lParam).Add('Handle: ' + FitWithZero(wHandle, 10) + '  Window Title: ' + (FitOn(100, Chaine1)) + ' Class Name: ' + Chaine2);
    strDispose(Title);
    strDispose(ClassName);
  except
    TStringList(lParam).Add('Gotcha!');
    result := TRUE; // Anyway....
  end;

end;

procedure PlaceInTStringListAllWindows(var ListeWindowTitle: TStringList; var ListeWindowClass: TStringList; var ListeWindowHandle: TStringList);
var
  ListeTempo: TStringList;
  WindowHandle, NomWindow, ClassWindow, LigneLue: string;
  IndexProg: longint;
begin
  if ListeWindowTitle <> nil then
    ListeWindowTitle := TStringList.Create;

  ListeWindowTitle.Sorted := FALSE;
  ListeWindowTitle.Clear;

  if ListeWindowClass <> nil then
    ListeWindowClass := TStringList.Create;
  ListeWindowClass.Sorted := FALSE;
  ListeWindowClass.Clear;

  if ListeWindowHandle <> nil then
    ListeWindowHandle := TStringList.Create;
  ListeWindowHandle.Sorted := FALSE;
  ListeWindowHandle.Clear;

  ListeTempo := TStringList.Create;
  ListeTempo.Sorted := FALSE;
  ListeTempo.Clear;

  EnumWindows(@EnumWindowsToStringList, integer(ListeTempo));

  for IndexProg := 0 to ListeTempo.Count - 1 do
  begin
    // 1
    // 1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9
    // 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    // Handle: 01577158  Window Title: HelpInsightWindow                                                                                    Class Name: THelpInsightWindowImpl
    LigneLue := ListeTempo.Strings[IndexProg];

    WindowHandle := Trim(Copy(LigneLue, 09, 10));
    NomWindow := Trim(Copy(LigneLue, 35, 100));
    ClassWindow := Trim(Copy(LigneLue, 148, 100));

    ListeWindowTitle.Add(NomWindow);
    ListeWindowClass.Add(ClassWindow);
    ListeWindowHandle.Add(WindowHandle);
  end;

  FreeAndNil(ListeTempo);
end;

procedure CloseAllCallidusApplications;
var
  slWindowTitle, slWindowClass, slWindowHandle: TStringList;
  iWindowPromeneur: integer;
  iwindowsHandle: THandle;
begin
  PlaceInTStringListAllWindows(slWindowTitle, slWindowClass, slWindowHandle);

  iWindowPromeneur := 0;
  while iWindowPromeneur < slWindowClass.Count do
  begin

    if (slWindowClass.Strings[iWindowPromeneur] = 'TfrmCallidusDisplay') or (slWindowClass.Strings[iWindowPromeneur] = 'TfrmCallidusRadar') or (slWindowClass.Strings[iWindowPromeneur] = 'TfrmCallidusController') then
    begin
      iwindowsHandle := StrToInt64(slWindowHandle.Strings[iWindowPromeneur]);
      SendMessage(iwindowsHandle, WM_CLOSE, 0, 0);
    end;
    inc(iWindowPromeneur);
  end;
end;

function GetApplicationNbOfThisClass(sClassName: string): integer;
var
  slWindowTitle, slWindowClass, slWindowHandle: TStringList;
  iWindowPromeneur: integer;
begin
  result := 0;

  PlaceInTStringListAllWindows(slWindowTitle, slWindowClass, slWindowHandle);

  iWindowPromeneur := 0;
  while iWindowPromeneur < slWindowClass.Count do
  begin
    if slWindowClass.Strings[iWindowPromeneur] = sClassName then inc(result);
    inc(iWindowPromeneur);
  end;
end;

{ Callidus_GetNetworkUsername }
function Callidus_GetNetworkUsername: string;
var
  LocalNetworkUsername: array[0..255] of char;
  Longueur: dword;
begin
  result := 'Unknown';

  Longueur := 250;
  if Windows.GetUserName(LocalNetworkUsername, Longueur) then
    result := LocalNetworkUsername;
end;

{ Callidus_GetComputerName }

function Callidus_GetComputerName: string;
var
  LocalComputerName: array[0..255] of char;
  Longueur: dword;
begin
  Longueur := 250;
  if Windows.GetComputerName(LocalComputerName, Longueur) then
    result := LocalComputerName
  else
    result := 'Unknown';
end;

{ CallidusSplitVariablesNamesAndValues }

procedure CallidusSplitVariablesNamesAndValues(slPayloadData, slVariablesNames, slVariablesValues: TStringList);
var
  iVariable, posEgal: integer;
  sVariableName, sVariableValue: string;
begin
  slVariablesNames.Clear;
  slVariablesValues.Clear;
  if slPayloadData.Count > 0 then
  begin
    for iVariable := 0 to pred(slPayloadData.Count) do
    begin
      posEgal := pos('=', slPayloadData.Strings[iVariable]);
      if posEgal > 0 then
      begin
        sVariableName := leftstr(slPayloadData.Strings[iVariable], (posEgal - 1));
        sVariableValue := rightstr(slPayloadData.Strings[iVariable], (length(slPayloadData.Strings[iVariable]) - posEgal));
        if (sVariableName <> '') then
        begin
          slVariablesNames.Add(sVariableName);
          slVariablesValues.Add(sVariableValue);
        end;
      end;
    end;

  end;
end;

end.

