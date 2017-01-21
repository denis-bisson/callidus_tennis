unit uProtocoleProto;

interface

uses
  // Delphi
  Classes, Types, Vcl.StdCtrls, Vcl.Forms, Vcl.Graphics,

  // Third party
  IdUDPClient, IdUDPServer, IdGlobal, IdSocketHandle, IdBaseComponent,
  IdComponent, IdUDPBase,

  // Callidus
  uRichEditCallidus;

const
  PROTO_CMD_NULLLLL = $00;
  PROTO_CMD_WHOSERV = $01;
  PROTO_CMD_SERVRIS = $02;
  PROTO_CMD_IMALIVE = $03;
  PROTO_CMD_SMPLACK = $04;
  PROTO_CMD_ATICKET = $05;
  PROTO_CMD_SPLTEST = $06;
  PROTO_CMD_AREUYTR = $07;
  PROTO_CMD_SNDINFO = $08;
  PROTO_CMD_DISCRTC = $09;
  PROTO_CMD_STRTTST = $0A;
  PROTO_CMD_STOPTST = $0B;
  PROTO_CMD_GETRDRP = $0C;
  PROTO_CMD_RDRINFO = $0D;
  PROTO_CMD_GETRESO = $0E;
  PROTO_CMD_RESOLIS = $0F;

  // ATTENTION! Si t'ajoutes une nouvelle commande, il faut aussi l'ajouter dans "FCommandList"...

  IDX_PROTO_LENGTH = 0;
  IDX_PROTO_SEQ = 3;
  IDX_PROTO_LEFT_BRACKET = 4;
  IDX_PROTO_COMMAND = 5;
  IDX_PROTO_CLOSE_BRACKET = 12;
  IDX_PROTO_PAYLOAD_DATA = 13;

  PORT_FOR_IDENTIFICATION = 2191;
  PORT_FOR_SENDING_CONTROLLER = 2192;
  PORT_FOR_SENDING_DISPLAY = 2193;
  PORT_FOR_SENDING_RADAR = 2194;

  PORT_CALLIDUS_CONTROLLER = 2192;
  PORT_CALLIDUS_DISPLAY = 2193;
  PORT_CALLIDUS_RADAR = 2194;

  IP_ADDRESS_NULL: string = '0.0.0.0';

  RXBUFFERSIZE = 30000;

type
  TServerPacketReceivedEvent = procedure(Sender: TObject; ABinding: TIdSocketHandle; const AData: TIdBytes; Answer7: AnsiString; PayloadData: TStringList) of object;

  TProtocoleProto = class(TComponent)
  private
    FHostControllerAddress: string;
    FWriteDebugFlag: boolean;
    FMessageWindow: tRichEditCallidus;
    FClientUDP: TIdUDPClient;
    FServerUDP: TIdUDPServer;
    FSequenceNumber: byte;
    FLastSequenceNumber: byte;
    FCommandList: TStringList;
    FRxClientBuffer: TIdBytes;
    FRxServerBuffer: TIdBytes;
    FRxClientBufferIndex: integer;
    FRxServerBufferIndex: integer;
    FOnServerPacketReceived: TServerPacketReceivedEvent;
    FFriendlyNameForLog: string;
    FDeviceName: string;
    FComplementDeviceName: string;
    FMyIpAddress: array of byte;
    FServerIpAddress: array of byte;
    procedure FromReceivedStuffLoadPacketInfo(paramBuffer: TIdBytes; var Answer7: AnsiString; var PayloadDataReceived: TStringList);
    function MyCrc16(Pointer: PByte; NbBytes: integer; InitialCRC: word): word;
  public
    property CommandList: TStringList read FCommandList write FCommandList;
    constructor Create(AOwner: TComponent); override;
    function Init: boolean;
    function PreparePacket(CommandAnswerIndex: integer; PayloadData: TStringList; paramTxBuffer: TIdBytes; MaximumPossibleSize: integer): integer;
    function isValidPacketReceived(paramBuffer: TIdBytes; paramBufferIndex: integer): boolean;
    procedure PitchUnMessagePROTONoHandshake(DestinationAddress:string; CommandIndex: integer; PayloadDataIn: TStringList);
    procedure AnyUDPClientConnected(Sender: TObject);
    procedure AnyUDPClientDisconnected(Sender: TObject);
    procedure AnyUDPClientStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure AnyUDPClientSendIdentification;
    procedure AnyUDPServerAfterBind(Sender: TObject);
    procedure AnyUDPServerBeforeBind(AHandle: TIdSocketHandle);
    procedure AnyUDPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure AnyUDPServerException(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: string; const AExceptionClass: TClass);
    procedure AnyUDPServerRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure WriteStatusLg(MsgInEnglish, MsgInFrench: string; ColorToUse: TColor);
    procedure WriteStatus(MsgInEnglish: string; ColorToUse: TColor);
    function GetHotControllerAddress: boolean;
    procedure SendIamAliveMessage;
    procedure LoadStringListWithIdentificationInfo(paramSl: TStringList);
    procedure ShutDownService;
  published
    property HostControllerAddress: string read FHostControllerAddress write FHostControllerAddress;
    property WorkingClientUDP: TIdUDPClient read FClientUDP write FClientUDP;
    property WorkingServerUDP: TIdUDPServer read FServerUDP write FServerUDP;
    property MessageWindow: tRichEditCallidus read FMessageWindow write FMessageWindow;
    property WriteDebug: boolean read FWriteDebugFlag write FWriteDebugFlag;
    property FriendlyNameForLog: string read FFriendlyNameForLog write FFriendlyNameForLog;
    property DeviceName: string read FDeviceName write FDeviceName;
    property ComplementDeviceName: string read FComplementDeviceName write FComplementDeviceName;
    property OnServerPacketReceived: TServerPacketReceivedEvent read FOnServerPacketReceived write FOnServerPacketReceived;
  end;

procedure Register;

implementation

uses
  // Delphi
  System.SysUtils, Windows, StrUtils,

  // Third party

  // My Stuff
  uCommonStuff;

{$R uProtocoleProto.dcr}

constructor TProtocoleProto.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFriendlyNameForLog := 'Unknown';
  FHostControllerAddress := IP_ADDRESS_NULL;
end;

{ TProtocoleProto.init }

function TProtocoleProto.Init: boolean;
var
  sWorkingAddress: string;
  posDot1, posDot2, posDot3: integer;
begin
  try
    FSequenceNumber := 0;
    FLastSequenceNumber := 0;

    FRxClientBufferIndex := 0;
    SetLength(FRxClientBuffer, RXBUFFERSIZE);
    FRxServerBufferIndex := 0;
    SetLength(FRxServerBuffer, RXBUFFERSIZE);

    sWorkingAddress := GetLocalIpAddress;
    SetLength(FMyIpAddress, 4);
    SetLength(FServerIpAddress, 4);
    posDot1 := pos('.', sWorkingAddress);
    FMyIpAddress[0] := StrToIntDef(copy(sWorkingAddress, 1, pred(posDot1)), 0);
    posDot2 := posEx('.', sWorkingAddress, posDot1 + 1);
    FMyIpAddress[1] := StrToIntDef(copy(sWorkingAddress, posDot1 + 1, pred(posDot2 - posDot1)), 0);
    posDot3 := posEx('.', sWorkingAddress, posDot2 + 1);
    FMyIpAddress[2] := StrToIntDef(copy(sWorkingAddress, posDot2 + 1, pred(posDot3 - posDot2)), 0);
    FMyIpAddress[3] := StrToIntDef(RightStr(sWorkingAddress, length(sWorkingAddress) - posDot3), 0);
    FServerIpAddress[0] := 0;
    FServerIpAddress[1] := 0;
    FServerIpAddress[2] := 0;
    FServerIpAddress[3] := 0;

    FCommandList := TStringList.Create;
    FCommandList := TStringList.Create;
    FCommandList.Sorted := False;
    FCommandList.Add('NULLLLL'); // $00
    FCommandList.Add('WHOSERV'); // $01
    FCommandList.Add('SERVRIS'); // $02
    FCommandList.Add('IMALIVE'); // $03
    FCommandList.Add('SMPLACK'); // $04
    FCommandList.Add('ATICKET'); // $05
    FCommandList.Add('SPLTEST'); // $06
    FCommandList.Add('AREUYTR'); // $07
    FCommandList.Add('SNDINFO'); // $08
    FCommandList.Add('DISCRTC'); // $09
    FCommandList.Add('STRTTST'); // $0A
    FCommandList.Add('STPTTST'); // $0B
    FCommandList.Add('GETRDRP'); // $0C
    FCommandList.Add('RDRINFO'); // $0D
    FCommandList.Add('GETRESO'); // $0E
    FCommandList.Add('RESOLIS'); // $0F

    if FClientUDP <> nil then
    begin
      FClientUDP.OnConnected := AnyUDPClientConnected;
      FClientUDP.OnDisconnected := AnyUDPClientDisconnected;
      FClientUDP.OnStatus := AnyUDPClientStatus;
      FClientUDP.Active := True;
    end;

    if FServerUDP <> nil then
    begin
      FServerUDP.OnBeforeBind := AnyUDPServerBeforeBind;
      FServerUDP.OnAfterBind := AnyUDPServerAfterBind;
      FServerUDP.OnUDPRead := AnyUDPServerRead;
      FServerUDP.OnUDPException := AnyUDPServerException;
      FServerUDP.OnStatus := AnyUDPServerStatus;
      FServerUDP.Active := True;
    end;

    result := True;
  except
    result := False;
  end;
end;

{ TProtocoleProto.GetHotControllerAddress}
function TProtocoleProto.GetHotControllerAddress: boolean;
var
  TxBuffer, RxBuffer: TIdBytes;
  iChar, iNbBytesToSend, iNbBytesReceived: integer;
  slPayloadDataReceived: TStringList;
  sAnswer: AnsiString;
  FreezeTime: DWord;
  sBroadCastAddress: string;
begin
  result := False;
  FHostControllerAddress := IP_ADDRESS_NULL;

  SetLength(TxBuffer, 100);
  iNbBytesToSend := PreparePacket(PROTO_CMD_WHOSERV, nil, TxBuffer, length(TxBuffer));
  SetLength(TxBuffer, iNbBytesToSend);

  if FClientUDP.Active then
  begin
    FClientUDP.Active := False;
    FClientUDP.BroadcastEnabled := True;
  end;

  if not FClientUDP.Active then
    FClientUDP.Active := True;

  if FClientUDP.Active then
  begin
    sBroadCastAddress := Format('%d.%d.%d.255', [FMyIpAddress[0], FMyIpAddress[1], FMyIpAddress[2]]);
    if FWriteDebugFlag then
      WriteStatusLg('About to broadcast at ' + sBroadCastAddress + ' our request for controller address...', 'Sur le point de diffuser sur ' + sBroadCastAddress + ' notre requête de recherche du contrôleur...', COLORDANGER);
    FClientUDP.SendBuffer(sBroadCastAddress, FClientUDP.Port, TxBuffer);
    WriteStatusLg('Request to identify controller sent!', 'La requête pour identifier le contrôleur a été envoyée!', COLORSUCCESS);
    //On va attendre ici 2 secondes au pire pire pire
    FreezeTime := GetTickCount;
    while (FreezeTime + 1980 < FreezeTime) do
    begin
      sleep(10);
      if FreezeTime + 1980 < FreezeTime then
        Application.ProcessMessages;
    end;
    SetLength(RxBuffer, 100);
    iNbBytesReceived := FClientUDP.ReceiveBuffer(RxBuffer, 20);
    SetLength(RxBuffer, iNbBytesReceived);
    if isValidPacketReceived(RxBuffer, iNbBytesReceived) then
    begin
      slPayloadDataReceived := TStringList.Create;
      try
        FromReceivedStuffLoadPacketInfo(RxBuffer, sAnswer, slPayloadDataReceived);
        case FCommandList.IndexOf(sAnswer) of
          PROTO_CMD_SERVRIS:
            begin
              for iChar := 0 to pred(4) do
                FServerIpAddress[iChar] := RxBuffer[IDX_PROTO_PAYLOAD_DATA + iChar];
              FHostControllerAddress := Format('%d.%d.%d.%d', [FServerIpAddress[0], FServerIpAddress[1], FServerIpAddress[2], FServerIpAddress[3]]);

              WriteStatusLg('Controller has been detected at: ' + HostControllerAddress, 'Le contrôleur a été détecté à: ' + HostControllerAddress, COLORSUCCESS);
              result := True;
            end;
        else
          begin
            WriteStatusLg('ERROR: Unable to received valid IP address in answer from controller...', 'ERREUR: Incapable de recevoir une adresse valide dasn la réponse du contrôleur...', COLORERROR);
          end;
        end;
      finally
        FreeAndNil(slPayloadDataReceived);
      end;
    end
    else
    begin
      WriteStatusLg('ERROR: Unable to received valid IP address from controller...', 'ERREUR: Incapable de recevoir une adresse valide du contrôleur...', COLORERROR);
    end;
  end
  else
  begin
    WriteStatusLg('ERROR: UDP client is not active when it should be!', 'ERREUR: Le client UDP n''est pas actif alors qu''il devrait l''être!', COLORERROR);
  end;
end;

{ TProtocoleProto.PitchUnMessagePROTONoHandshake }
procedure TProtocoleProto.PitchUnMessagePROTONoHandshake(DestinationAddress:string; CommandIndex: integer; PayloadDataIn: TStringList);
var
  TxBuffer: TIdBytes;
  NbBytestoSend: integer;
begin
  if (FClientUDP <> nil) and ((FHostControllerAddress <> IP_ADDRESS_NULL) or (DestinationAddress<>'')) then
  begin
    try
      SetLength(TxBuffer, 2000);
      // 3. We now attempt to send our message.
      WriteStatusLg('Will now send our message...', 'On va maintenant envoyer notre message...', COLORDANGER);
      FRxClientBufferIndex := 0;
      NbBytestoSend := PreparePacket(CommandIndex, PayloadDataIn, TxBuffer, length(TxBuffer));
      if NbBytestoSend > 0 then
      begin
        if DestinationAddress='' then
          FClientUDP.SendBuffer(FHostControllerAddress, FClientUDP.Port, TxBuffer)
        else
          FClientUDP.SendBuffer(DestinationAddress, FClientUDP.Port, TxBuffer);
        WriteStatusLg('Message sent!', 'Message envoyé!', COLORSUCCESS);
      end
    except
    end;
  end
  else
  begin
//    WriteStatusLg('We can''t send anything because we don''t know remote address OR our client UDP is not ready...', 'On n''envoie rien car on ne connait pa sl''adresse de destination ou le client UDP n''est pas prêt...', COLORSUCCESS);
  end;
end;

function TProtocoleProto.PreparePacket(CommandAnswerIndex: integer; PayloadData: TStringList; paramTxBuffer: TIdBytes; MaximumPossibleSize: integer): integer;
var
  iIndexInPayloadData, iLineNumber, iNbBytes, iIndexChar, iPacketLength: integer;
  sWorking, sCommandAnswer: string;
  wComputedCRC16: word;
begin
  try
    if CommandAnswerIndex < FCommandList.Count then
    begin
      for iIndexChar := 0 to pred(sizeof(paramTxBuffer)) do
        paramTxBuffer[iIndexChar] := $00;

      paramTxBuffer[IDX_PROTO_SEQ] := FSequenceNumber;
      paramTxBuffer[IDX_PROTO_LEFT_BRACKET] := ord('[');

      sCommandAnswer := FCommandList.Strings[CommandAnswerIndex];
      for iIndexChar := 0 to pred(length(sCommandAnswer)) do
        paramTxBuffer[IDX_PROTO_COMMAND + iIndexChar] := ord(sCommandAnswer[iIndexChar + 1]);

      paramTxBuffer[IDX_PROTO_CLOSE_BRACKET] := ord(']');

      iLineNumber := 0;
      iIndexInPayloadData := IDX_PROTO_PAYLOAD_DATA;
      if PayloadData <> nil then
      begin
        while iLineNumber < PayloadData.Count do
        begin
          sWorking := PayloadData.Strings[iLineNumber];
          iNbBytes := length(sWorking);
          for iIndexChar := 0 to pred(iNbBytes) do
            paramTxBuffer[iIndexInPayloadData + iIndexChar] := ord(sWorking[iIndexChar + 1]);
          paramTxBuffer[iIndexInPayloadData + iNbBytes] := $0D;
          paramTxBuffer[iIndexInPayloadData + iNbBytes + 1] := $0A;
          iIndexInPayloadData := iIndexInPayloadData + iNbBytes + 2;

          inc(iLineNumber);
        end;
      end
      else
      begin
        case CommandAnswerIndex of
          PROTO_CMD_WHOSERV, PROTO_CMD_SERVRIS:
            begin
              for iIndexChar := 0 to pred(4) do
                paramTxBuffer[iIndexInPayloadData + iIndexChar] := FMyIpAddress[iIndexChar];
              iIndexInPayloadData := iIndexInPayloadData + 4;
            end;
        end;
      end;

      iPacketLength := iIndexInPayloadData + 2;
      paramTxBuffer[IDX_PROTO_LENGTH + 0] := (iPacketLength shr 16) and $FF;
      paramTxBuffer[IDX_PROTO_LENGTH + 1] := (iPacketLength shr 8) and $FF;
      paramTxBuffer[IDX_PROTO_LENGTH + 2] := (iPacketLength and $FF);

      wComputedCRC16 := MyCrc16(addr(paramTxBuffer[0]), iPacketLength - 2, $0000);
      paramTxBuffer[iPacketLength - 2] := ((wComputedCRC16 shr 8) and $FF);
      paramTxBuffer[iPacketLength - 1] := (wComputedCRC16 and $FF);

      result := iPacketLength;
    end
    else
    begin
      WriteStatusLg('ERROR: Command to send in "PreparePacket" is larger than the supported one... Contact the author!', 'ERREUR: La commande a envoyée dans la routine "PreparePacket" est trop grande! Contactez l''auteur!', COLORERROR);
      result := -1;
    end;
  except
    result := -1;
  end;
end;

function TProtocoleProto.isValidPacketReceived(paramBuffer: TIdBytes; paramBufferIndex: integer): boolean;
var
  bKeepGoing: boolean;
  iExpectedAnswerPacketLength, iChar: integer;
  sAnswerReceived: AnsiString;
  ComputedCRC16, ExpectedCRC16: word;
begin
  result := False;
  bKeepGoing := True;
  iExpectedAnswerPacketLength := 0;

  try
    // 1. Enough byte to begin to check something?
    if bKeepGoing then
    begin
      if paramBufferIndex < 3 then
        bKeepGoing := False;
    end;

    // 2. Packet length is valid?
    if bKeepGoing then
    begin
      iExpectedAnswerPacketLength := (paramBuffer[IDX_PROTO_LENGTH + 0] shl 16) or (paramBuffer[IDX_PROTO_LENGTH + 1] shl 8) or (paramBuffer[IDX_PROTO_LENGTH + 2]);
      if (iExpectedAnswerPacketLength < (IDX_PROTO_PAYLOAD_DATA + 2)) or (iExpectedAnswerPacketLength > RXBUFFERSIZE) then
        bKeepGoing := False;
    end;

    // 3. All the bytes received?
    if bKeepGoing then
    begin
      if paramBufferIndex < iExpectedAnswerPacketLength then
        bKeepGoing := False;
    end;

    // 4. Answer between brackets?
    if bKeepGoing then
    begin
      if (paramBuffer[IDX_PROTO_LEFT_BRACKET] <> ord('[')) or (paramBuffer[IDX_PROTO_CLOSE_BRACKET] <> ord(']')) then
        bKeepGoing := False;
    end;

    // 5. Only letters in answer?
    if bKeepGoing then
    begin
      sAnswerReceived := '';
      iChar := 0;
      while (iChar < 7) and (bKeepGoing) do
      begin
        sAnswerReceived := sAnswerReceived + AnsiChar(paramBuffer[IDX_PROTO_COMMAND + iChar]);
        if (paramBuffer[IDX_PROTO_COMMAND + iChar] < ord('A')) or (paramBuffer[IDX_PROTO_COMMAND + iChar] > ord('Z')) then
          bKeepGoing := False
        else
          inc(iChar);
      end;
    end;

    // 6. CRC16's are matching?
    if bKeepGoing then
    begin
      FLastSequenceNumber := paramBuffer[IDX_PROTO_SEQ];
      ComputedCRC16 := MyCrc16(addr(paramBuffer[0]), (iExpectedAnswerPacketLength - 2), $0000);
      ExpectedCRC16 := ((paramBuffer[iExpectedAnswerPacketLength - 2] shl 8) or paramBuffer[iExpectedAnswerPacketLength - 1]);
      if (ComputedCRC16 <> ExpectedCRC16) then
        bKeepGoing := False;
    end;

    // 7. If everything is good, we have an answer sir!
    if bKeepGoing then
      result := True;
  except
    result := False;
  end;
end;

procedure TProtocoleProto.FromReceivedStuffLoadPacketInfo(paramBuffer: TIdBytes; var Answer7: AnsiString; var PayloadDataReceived: TStringList);
var
  iChar, iExpectedAnswerPacketLength, iPromeneur, iPayloadLength: integer;
  sBuildingString: string;
begin
  Answer7 := '';
  if PayloadDataReceived <> nil then
    PayloadDataReceived.Clear;

  for iChar := 0 to 6 do
    Answer7 := Answer7 + AnsiChar(paramBuffer[IDX_PROTO_COMMAND + iChar]);

  iExpectedAnswerPacketLength := (paramBuffer[IDX_PROTO_LENGTH + 0] shl 16) or (paramBuffer[IDX_PROTO_LENGTH + 1] shl 8) or (paramBuffer[IDX_PROTO_LENGTH + 2]);
  if iExpectedAnswerPacketLength > 0 then
  begin
    iPayloadLength := iExpectedAnswerPacketLength - (3 + 1 + 1 + 7 + 1 + 2);
    if iPayloadLength > 0 then
    begin
      iPromeneur := 0;
      sBuildingString := '';
      while iPromeneur < (iPayloadLength - 1) do
      begin
        case paramBuffer[IDX_PROTO_PAYLOAD_DATA + iPromeneur] of
          $0D, $0A:
            begin
              if (paramBuffer[IDX_PROTO_PAYLOAD_DATA + iPromeneur + 1] = $0A) then
              begin
                if pos('=', sBuildingString) <> 0 then
                  if PayloadDataReceived <> nil then
                    PayloadDataReceived.Add(sBuildingString);
              end;
              sBuildingString := '';
            end;

        else
          begin
            sBuildingString := sBuildingString + AnsiChar(paramBuffer[IDX_PROTO_PAYLOAD_DATA + iPromeneur]);
          end;
        end;
        inc(iPromeneur);
      end;
    end;
  end;
end;

procedure TProtocoleProto.WriteStatusLg(MsgInEnglish, MsgInFrench: string; ColorToUse: TColor);
begin
  if FMessageWindow <> nil then
  begin
    if FWriteDebugFlag or (ColorToUse = ColorError) then
    begin
      FMessageWindow.WriteStatusLg(FFriendlyNameForLog + ':' + MsgInEnglish, FFriendlyNameForLog + ':' + MsgInFrench, ColorToUse);
    end;
  end;
end;
procedure TProtocoleProto.WriteStatus(MsgInEnglish: string; ColorToUse: TColor);
begin
  if FMessageWindow <> nil then
  begin
    if FWriteDebugFlag or (ColorToUse = ColorError) then
    begin
      FMessageWindow.WriteStatusLg(FFriendlyNameForLog + ':' + MsgInEnglish, FFriendlyNameForLog + ':' + MsgInEnglish, ColorToUse);
    end;
  end;
end;

function TProtocoleProto.MyCrc16(Pointer: PByte; NbBytes: integer; InitialCRC: word): word;
const
  { (* }
  CRCTable: array[$00..$FF] of word = ($0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241, $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440, $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40, $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841, $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40, $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41, $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641, $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040, $F001,
    $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240, $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441, $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41, $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840, $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41, $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40, $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640, $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041, $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441, $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41, $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840, $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41, $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40, $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640, $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041, $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241, $9601, $56C0, $5780, $9741, $5500, $95C1, $9481,
    $5440, $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40, $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841, $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40, $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41, $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641, $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040);
  { *) }
var
  Index: longint;
  c: word;
begin
  result := InitialCRC;
  for Index := 1 to NbBytes do
  begin
    c := ((result and $FF) xor Pointer^);
    inc(Pointer);
    result := CRCTable[c] xor (result shr 8);
  end;
end;

procedure TProtocoleProto.AnyUDPClientConnected(Sender: TObject);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Client Connected', 'Client UDP connecté', COLORSTATUS);
end;

procedure TProtocoleProto.AnyUDPClientDisconnected(Sender: TObject);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Client Disconnected', 'Client UDP déconnecté', COLORSTATUS);
end;

procedure TProtocoleProto.AnyUDPClientStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Client Status: ' + AStatusText, 'Statut du client UDP: ' + AStatusText, COLORSTATUS);
end;

procedure TProtocoleProto.AnyUDPServerAfterBind(Sender: TObject);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server After Bind!', 'Après le "bind" sur le serveur UDP', COLORSTATUS);
end;

procedure TProtocoleProto.AnyUDPServerBeforeBind(AHandle: TIdSocketHandle);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Before Bind!', 'Avant le "bind" sur le serveur UDP', COLORSTATUS);
end;

procedure TProtocoleProto.AnyUDPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Status: ' + AStatusText, 'Statut du serveur UDP: ' + AStatusText, COLORSTATUS);
end;

procedure TProtocoleProto.AnyUDPServerException(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: string; const AExceptionClass: TClass);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Exception: ' + AMessage, 'Exception sur le serveur UDP: ' + AMessage, COLORSTATUS);
end;

{ TProtocoleProto.AnyUDPClientSendIdentification}
procedure TProtocoleProto.AnyUDPClientSendIdentification;
var
  TxBuffer: TIdBytes;
  iNbBytesToSend: integer;
  sBroadCastAddress: string;
begin
  SetLength(TxBuffer, 100);
  iNbBytesToSend := PreparePacket(PROTO_CMD_SERVRIS, nil, TxBuffer, length(TxBuffer));
  SetLength(TxBuffer, iNbBytesToSend);

  if FClientUDP.Active then
  begin
    FClientUDP.Active := False;
    FClientUDP.BroadcastEnabled := True;
  end;

  if not FClientUDP.Active then FClientUDP.Active := True;

  if FClientUDP.Active then
  begin
    sBroadCastAddress := Format('%d.%d.%d.255', [FMyIpAddress[0], FMyIpAddress[1], FMyIpAddress[2]]);
    if FWriteDebugFlag then WriteStatusLg('About to broadcast at ' + sBroadCastAddress + ' CALLIDUS-CONTROLLER address...', 'Le CALLIDUS-SERVER est sur le point son addresse sur ' + sBroadCastAddress, COLORDANGER);
    FClientUDP.SendBuffer(sBroadCastAddress, FClientUDP.Port, TxBuffer);
    WriteStatusLg('Information has been sent!', 'L''information a été envoyé!', COLORSUCCESS);
  end;
end;

{ TProtocoleProto.AnyUDPServerRead}
procedure TProtocoleProto.AnyUDPServerRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  sDisplayable: string;
  iChar, iNbBytesToSend: integer;
  IpTarget: array[0..3] of byte;
  TxBuffer: TIdBytes;
  slPayloadDataReceived: TStringList;
  Answer7: AnsiString;

  procedure ShowDebugInfo;
  var
    iIndex: integer;
  begin
    WriteStatus('REQ/ANS:' + Answer7, COLORSUCCESS);
    WriteStatus('Count:' + IntToStr(slPayloadDataReceived.Count), COLORSUCCESS);
    for iIndex := 0 to pred(slPayloadDataReceived.Count) do WriteStatus('Param' + IntToStr(iIndex) + ':' + slPayloadDataReceived.Strings[iIndex], COLORSUCCESS);
  end;

begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Received Something', 'Le serveur UDP a reçu de quoi', COLORSTATUS);

  if isValidPacketReceived(AData, Length(AData)) then
  begin
    slPayloadDataReceived := TStringList.Create;
    try
      FromReceivedStuffLoadPacketInfo(AData, Answer7, slPayloadDataReceived);

      if FWriteDebugFlag then ShowDebugInfo;

      case FCommandList.IndexOf(Answer7) of
        PROTO_CMD_WHOSERV:
          begin
            WriteStatusLg('UDP Server request valid!', 'Requête au serveur UDP valide!', COLORSUCCESS);
            for iChar := 0 to pred(4) do IpTarget[iChar] := AData[IDX_PROTO_PAYLOAD_DATA + iChar];
            SetLength(TxBuffer, 100);
            iNbBytesToSend := PreparePacket(PROTO_CMD_SERVRIS, nil, TxBuffer, length(TxBuffer));
            SetLength(TxBuffer, iNbBytesToSend);

            if FServerUDP.Active then
            begin
              if FWriteDebugFlag then
                WriteStatusLg('About to send back IP address of controller to ' + ABinding.PeerIp, 'Sur le point de retourner l''adresse du contrôleur à ' + ABinding.PeerIp, COLORDANGER);
              ABinding.SendTo(ABinding.PeerIP, ABinding.PeerPort, TxBuffer);
            end;
          end;

        PROTO_CMD_SERVRIS:
          begin
            WriteStatusLg('CALLIDUS-SERVER sent its identification!', 'Le CALLIDUS-SERVER a envoyé sont identification!', COLORSUCCESS);
            for iChar := 0 to pred(4) do FServerIpAddress[iChar] := AData[IDX_PROTO_PAYLOAD_DATA + iChar];
            FHostControllerAddress := Format('%d.%d.%d.%d', [FServerIpAddress[0], FServerIpAddress[1], FServerIpAddress[2], FServerIpAddress[3]]);
            WriteStatusLg('Controller has been detected at: ' + FHostControllerAddress, 'Le contrôleur a été détecté à: ' + FHostControllerAddress, COLORSUCCESS);

            if FClientUDP <> nil then
            begin
              WriteStatusLg('We will tell to server that we''re there!', 'Nous allons répondre au serveur que nous sommes là!', COLORSUCCESS);
              SendIamAliveMessage;
            end;
          end;

        PROTO_CMD_IMALIVE:
          begin
          end;

        PROTO_CMD_SNDINFO:
          begin
          end;
      end;

      if Assigned(OnServerPacketReceived) then
        OnServerPacketReceived(Self, ABinding, AData, Answer7, slPayloadDataReceived);

    finally
      FreeAndNil(slPayloadDataReceived);
    end;
  end
  else
  begin
    WriteStatusLg('ERROR: UDP server received an invalid request...', 'ERREUR: Le serveur UDP a reçu une requête invalide...', COLORERROR);
    sDisplayable := AnsiChar($0A);
    for iChar := 0 to pred(Length(AData)) do
      sDisplayable := sDisplayable + AnsiChar(AData[iChar]);
    WriteStatusLg(sDisplayable, sDisplayable, COLORERROR);
  end;
end;

procedure TProtocoleProto.LoadStringListWithIdentificationInfo(paramSl: TStringList);
begin
  paramSl.Add(CALLIDUS_INFO_COMPUTERNAME + '=' + Callidus_GetComputerName);
  paramSl.Add(CALLIDUS_INFO_DEVICETYPE + '=' + FDeviceName);
  paramSl.Add(CALLIDUS_INFO_COMPLEMENTNAME + '=' + FComplementDeviceName);
  paramSl.Add(CALLIDUS_INFO_VERSION + '=' + sCALLIDUS_SYSTEM_VERSION);
end;

{ TProtocoleProto.SendIamAliveMessage }
procedure TProtocoleProto.SendIamAliveMessage;
var
  PayloadDataRequest: TStringList;
begin
  try
    PayloadDataRequest := TStringList.Create;
    try
      LoadStringListWithIdentificationInfo(PayloadDataRequest);
      PitchUnMessagePROTONoHandshake('', PROTO_CMD_IMALIVE, PayloadDataRequest);
    finally
      FreeAndNil(PayloadDataRequest);
    end;
  except
  end;
end;

procedure TProtocoleProto.ShutDownService;
begin
  if WorkingClientUDP <> nil then
    WorkingClientUDP.Active := False;
  if WorkingServerUDP <> nil then
    WorkingServerUDP.Active := False;
end;

procedure Register;
begin
  RegisterComponents('Callidus', [TProtocoleProto]);
end;

end.

