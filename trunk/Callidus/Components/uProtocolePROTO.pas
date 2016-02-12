unit uProtocolePROTO;

interface

uses
  // Delphi
  Classes, Types, System.Win.ScktComp, Vcl.StdCtrls, Vcl.Forms, Vcl.Graphics,

  // Component
  IdUDPClient, IdUDPServer, IdGlobal, IdSocketHandle, IdBaseComponent,
  IdComponent, IdUDPBase,

  // Global6
  MyEnhancedRichedit;

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

  IP_ADDRESS_NULL: string = '0.0.0.0';

  RXBUFFERSIZE = 30000;

type
  TServerSocketValidPacketReceivedEvent = procedure(Sender: TObject; Socket: TCustomWinSocket; Answer7: AnsiString; PayloadData: TStringList) of object;

  TProtocole_PROTO = class(TComponent)
  private
    FWriteDebugFlag: boolean;
    FMessageWindow: TRichEditGlobal6;
    FClientSocket: TClientSocket;
    FServerSocket: TServerSocket;
    FClientUDP: TIdUDPClient;
    FServerUDP: TIdUDPServer;
    FSequenceNumber: byte;
    FLastSequenceNumber: byte;
    FCommandList: TStringList;
    FRxClientBuffer: TIdBytes;
    FRxServerBuffer: TIdBytes;
    FRxClientBufferIndex: integer;
    FRxServerBufferIndex: integer;
    FOnServerSocketValidPacketReceived: TServerSocketValidPacketReceivedEvent;
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
    function PitchUnMessageAndGetResponsePROTO(CommandIndex: integer; PayloadDataIn: TStringList; var Answer7: AnsiString; PayloadDataReceived: TStringList): integer;
    function ServerSocketReplyAnswer(Socket: TCustomWinSocket; AnswerIndex: integer; PayloadDataOut: TStringList): boolean;
    procedure AnyClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: integer);
    procedure AnyClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyClientSocketWrite(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyServerSocketAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyServerSocketClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: integer);
    procedure AnyServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyServerSocketClientWrite(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyServerSocketGetSocket(Sender: TObject; Socket: NativeInt; var ClientSocket: TServerClientWinSocket);
    procedure AnyServerSocketGetThread(Sender: TObject; ClientSocket: TServerClientWinSocket; var SocketThread: TServerClientThread);
    procedure AnyServerSocketListen(Sender: TObject; Socket: TCustomWinSocket);
    procedure AnyServerSocketThreadEnd(Sender: TObject; Thread: TServerClientThread);
    procedure AnyServerSocketThreadStart(Sender: TObject; Thread: TServerClientThread);
    procedure AnyUDPClientConnected(Sender: TObject);
    procedure AnyUDPClientDisconnected(Sender: TObject);
    procedure AnyUDPClientStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure AnyUDPServerAfterBind(Sender: TObject);
    procedure AnyUDPServerBeforeBind(AHandle: TIdSocketHandle);
    procedure AnyUDPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure AnyUDPServerException(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: string; const AExceptionClass: TClass);
    procedure AnyUDPServerRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure WriteStatusLg(MsgInEnglish, MsgInFrench: string; ColorToUse: TColor);
    function GetControllerAddress(var ControllerAddress: string): boolean;
    function SendIamAliveMessage: boolean;
    procedure LoadStringListWithIdentificationInfo(paramSl: TStringList);
    procedure ShutDownService;
  published
    property WorkingClientUDP: TIdUDPClient read FClientUDP write FClientUDP;
    property WorkingServerUDP: TIdUDPServer read FServerUDP write FServerUDP;
    property WorkingClientSocket: TClientSocket read FClientSocket write FClientSocket;
    property WorkingServerSocket: TServerSocket read FServerSocket write FServerSocket;
    property MessageWindow: TRichEditGlobal6 read FMessageWindow write FMessageWindow;
    property WriteDebug: boolean read FWriteDebugFlag write FWriteDebugFlag;
    property FriendlyNameForLog: string read FFriendlyNameForLog write FFriendlyNameForLog;
    property DeviceName: string read FDeviceName write FDeviceName;
    property ComplementDeviceName: string read FComplementDeviceName write FComplementDeviceName;
    property OnServerSocketValidPacketReceived: TServerSocketValidPacketReceivedEvent read FOnServerSocketValidPacketReceived write FOnServerSocketValidPacketReceived;
  end;

procedure Register;

implementation

uses
  // Delphi
  System.SysUtils, Windows, StrUtils,

  // Third party

  // My Stuff
  uCommonStuff;

{$R uProtocolePROTO.dcr}

constructor TProtocole_PROTO.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFriendlyNameForLog := 'Unknown';
end;

{ TProtocole_PROTO.init }

function TProtocole_PROTO.Init: boolean;
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
    FCommandList.Sorted := FALSE;
    FCommandList.Add('NULLLLL'); // 0
    FCommandList.Add('WHOSERV'); // 1
    FCommandList.Add('SERVRIS'); // 2
    FCommandList.Add('IMALIVE'); // 3
    FCommandList.Add('SMPLACK'); // 4
    FCommandList.Add('ATICKET'); // 5
    FCommandList.Add('SPLTEST'); // 6
    FCommandList.Add('AREUYTR'); // 7
    FCommandList.Add('SNDINFO'); // 8
    FCommandList.Add('DISCRTC'); // 9

    if FClientSocket <> nil then
    begin
      FClientSocket.OnConnect := AnyClientSocketConnect;
      FClientSocket.OnConnecting := AnyClientSocketConnecting;
      FClientSocket.OnDisconnect := AnyClientSocketDisconnect;
      FClientSocket.OnError := AnyClientSocketError;
      FClientSocket.OnLookup := AnyClientSocketLookup;
      FClientSocket.OnRead := AnyClientSocketRead;
      FClientSocket.OnWrite := AnyClientSocketWrite;
    end;

    if FServerSocket <> nil then
    begin
      FServerSocket.OnAccept := AnyServerSocketAccept;
      FServerSocket.OnClientConnect := AnyServerSocketClientConnect;
      FServerSocket.OnClientDisconnect := AnyServerSocketClientDisconnect;
      FServerSocket.OnClientError := AnyServerSocketClientError;
      FServerSocket.OnClientRead := AnyServerSocketClientRead;
      FServerSocket.OnClientWrite := AnyServerSocketClientWrite;
      FServerSocket.OnGetSocket := AnyServerSocketGetSocket;
      FServerSocket.OnGetThread := AnyServerSocketGetThread;
      FServerSocket.OnListen := AnyServerSocketListen;
      FServerSocket.OnThreadEnd := AnyServerSocketThreadEnd;
      FServerSocket.OnThreadStart := AnyServerSocketThreadStart;
    end;

    if FClientUDP <> nil then
    begin
      FClientUDP.OnConnected := AnyUDPClientConnected;
      FClientUDP.OnDisconnected := AnyUDPClientDisconnected;
      FClientUDP.OnStatus := AnyUDPClientStatus;
    end;

    if FServerUDP <> nil then
    begin
      FServerUDP.OnBeforeBind := AnyUDPServerBeforeBind;
      FServerUDP.OnAfterBind := AnyUDPServerAfterBind;
      FServerUDP.OnUDPRead := AnyUDPServerRead;
      FServerUDP.OnUDPException := AnyUDPServerException;
      FServerUDP.OnStatus := AnyUDPServerStatus;
    end;

    result := TRUE;
  except
    result := FALSE;
  end;
end;

function TProtocole_PROTO.GetControllerAddress(var ControllerAddress: string): boolean;
var
  TxBuffer, RxBuffer: TIdBytes;
  iChar, iNbBytesToSend, iNbBytesReceived: integer;
  slPayloadDataReceived: TStringList;
  sAnswer: AnsiString;
  FreezeTime: DWord;
begin
  result := FALSE;
  ControllerAddress := '0.0.0.0';

  SetLength(TxBuffer, 100);
  iNbBytesToSend := PreparePacket(PROTO_CMD_WHOSERV, nil, TxBuffer, length(TxBuffer));
  SetLength(TxBuffer, iNbBytesToSend);

  if FClientUDP.Active then
  begin
    FClientUDP.Active := FALSE;
    FClientUDP.BroadcastEnabled := TRUE;
    FClientUDP.Port := PORT_FOR_IDENTIFICATION;
  end;

  if not FClientUDP.Active then
    FClientUDP.Active := True;

  if FClientUDP.Active then
  begin
    if FWriteDebugFlag then WriteStatusLg('About to broadcast our request for controller address...', 'Sur le point de diffuser notre requête de recherche du contrôleur...', COLORDANGER);
    FClientUDP.SendBuffer(Format('%d.%d.%d.255', [FMyIpAddress[0], FMyIpAddress[1], FMyIpAddress[2]]), PORT_FOR_IDENTIFICATION, TxBuffer);
    WriteStatusLg('Request to identify controller sent!', 'La requête pour identifier le contrôleur a été envoyée!', COLORSUCCESS);
    //On va attendre ici 2 secondes au pire pire pire
    FreezeTime := GetTickCount;
    while (FreezeTime + 1980 < FreezeTime) do
    begin
      sleep(10);
      if FreezeTime + 1980 < FreezeTime then Application.ProcessMessages;
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
              ControllerAddress := Format('%d.%d.%d.%d', [FServerIpAddress[0], FServerIpAddress[1], FServerIpAddress[2], FServerIpAddress[3]]);

              WriteStatusLg('Controller has been detected at: ' + ControllerAddress, 'Le contrôleur a été détecté à: ' + ControllerAddress, COLORSUCCESS);
              result := TRUE;
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

function TProtocole_PROTO.ServerSocketReplyAnswer(Socket: TCustomWinSocket; AnswerIndex: integer; PayloadDataOut: TStringList): boolean;
var
  TxBuffer: TIdBytes;
  NbBytestoSend: integer;
begin
  try
    SetLength(TxBuffer, 2000);
    NbBytestoSend := PreparePacket(AnswerIndex, PayloadDataOut, TxBuffer, length(TxBuffer));
    Socket.SendBuf(TxBuffer[0], NbBytestoSend);
    result := TRUE;
  except
    result := FALSE;
  end;
end;

function TProtocole_PROTO.PitchUnMessageAndGetResponsePROTO(CommandIndex: integer; PayloadDataIn: TStringList; var Answer7: AnsiString; PayloadDataReceived: TStringList): integer;
var
  FreezeStartMoment: dword;
  TxBuffer: TIdBytes;
  bKeepGoing: boolean;
  NbBytestoSend, iExpectedAnswerPacketLength, iChar: integer;
  sAnswerReceived: AnsiString;
  ComputedCRC16, ExpectedCRC16: word;
begin
  result := -1;
  if PayloadDataReceived <> nil then PayloadDataReceived.Clear;

  if FClientSocket <> nil then
  begin

    iExpectedAnswerPacketLength := -1;
    Answer7 := '';
    FreezeStartMoment := GetTickcount; // To avoid warning that "FreezeStartMoment" is used without being initialized

    try
      SetLength(TxBuffer, 2000);

      bKeepGoing := TRUE;

      // 1. We close socket if it was already opened (but it should not happen).
      if FClientSocket.Active then
      begin
        WriteStatusLg('Socket is now connected, we''ll close it...', 'Nous avons présentement une connexion, nous allons la fermer...', COLORDANGER);
        FClientSocket.Close;
        Application.ProcessMessages;
        WriteStatusLg('Connexion is now supposed to be closed', 'La connexion est supposée être fermée maintenant.', COLORSUCCESS);
      end;
      if FClientSocket.Active then
      begin
        bKeepGoing := FALSE;
        WriteStatusLg('ERROR: We should not be connected now...', 'ERREUR: Nous ne devrions pas être connecté présentement!', COLORERROR);
      end;

      // 2. We attempt to connect on the socket-server.
      if bKeepGoing then
      begin
        WriteStatusLg('About to try to connect to server...', 'Sur le point d''essayer de se connecter sur le serveur...', COLORDANGER);
        FClientSocket.Open;
        FreezeStartMoment := GetTickcount;
        while (not FClientSocket.Active) and ((FreezeStartMoment + TIMEOUT_FOR_CONNEXION) > GetTickcount) do
        begin
          sleep(1);
          if (FreezeStartMoment + TIMEOUT_FOR_CONNEXION) > GetTickcount then
            Application.ProcessMessages;
        end;
        if FClientSocket.Active then
        begin
          WriteStatusLg('SUCCESS! We were able to connect!', 'SUCCÈS! On a été capable de se connecter!', COLORSUCCESS);
        end
        else
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: Unable to connect to server...', 'ERREUR: Incapable de se connecter sur le serveur...', COLORERROR);
        end;
      end;

      // 3. We now attempt to send our message.
      if bKeepGoing then
      begin
        WriteStatusLg('Will now send our message...', 'On va maintenant envoyer notre message...', COLORDANGER);
        FRxClientBufferIndex := 0;
        NbBytestoSend := PreparePacket(CommandIndex, PayloadDataIn, TxBuffer, length(TxBuffer));
        if NbBytestoSend > 0 then
        begin
          FClientSocket.Socket.SendBuf(TxBuffer[0], NbBytestoSend);
          WriteStatusLg('Message sent!', 'Message envoyé!', COLORSUCCESS);
        end
        else
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: Problem preparing the packet to send...', 'ERREUR: Problème à préparer le packet à envoyer...', COLORERROR);
        end;
      end;

      // 4. We now wait a response
      if bKeepGoing then
      begin
        WriteStatusLg('Now waiting an answer...', 'On attent maintenant la réponse...', COLORDANGER);
        FreezeStartMoment := GetTickcount;
        while (FRxClientBufferIndex < 3) and ((FreezeStartMoment + TIMEOUT_FOR_SIMPLE_MESSAGE) > GetTickcount) do
        begin
          sleep(1);
          if (FreezeStartMoment + TIMEOUT_FOR_SIMPLE_MESSAGE) > GetTickcount then
            Application.ProcessMessages;
        end;
        if FRxClientBufferIndex < 3 then
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: Timeout while waiting an answer from server...', 'ERREUR: Temps d''attente maximal dépassé à attrendre une réponse...', COLORERROR);
        end;
      end;

      // 5. On valide que la réponse a une longueur qui a de l'allure
      if bKeepGoing then
      begin
        iExpectedAnswerPacketLength := (FRxClientBuffer[IDX_PROTO_LENGTH + 0] shl 16) or (FRxClientBuffer[IDX_PROTO_LENGTH + 1] shl 8) or (FRxClientBuffer[IDX_PROTO_LENGTH + 2]);
        if (iExpectedAnswerPacketLength < (IDX_PROTO_PAYLOAD_DATA + 2)) or (iExpectedAnswerPacketLength > RXBUFFERSIZE) then
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: Detect length for answer is invalid...', 'ERREUR: La longueur de la réponse n''a pas d''allure...', COLORERROR);
        end;
      end;

      // 6. On attend tous nos bytes
      if bKeepGoing then
      begin
        while (FRxClientBufferIndex < iExpectedAnswerPacketLength) and ((FreezeStartMoment + TIMEOUT_FOR_SIMPLE_MESSAGE) > GetTickcount) do
        begin
          sleep(1);
          if (FreezeStartMoment + TIMEOUT_FOR_SIMPLE_MESSAGE) > GetTickcount then
            Application.ProcessMessages;
        end;
        if FRxClientBufferIndex < iExpectedAnswerPacketLength then
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: Timeout while waiting whole answer from server...', 'ERREUR: Temps d''attente maximal dépassé à attrendre une réponse complète...', COLORERROR);
        end;
      end;

      // 7. On valide que la réponse est entre des crochets
      if bKeepGoing then
      begin
        if (FRxClientBuffer[IDX_PROTO_LEFT_BRACKET] <> ord('[')) or (FRxClientBuffer[IDX_PROTO_CLOSE_BRACKET] <> ord(']')) then
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: Answer is not between delimiters like expected...', 'ERREUR: La réponse n''est pas entre crochet comme attendu...', COLORERROR);
        end;
      end;

      // 8. On valide que la réponse est composée uniquement de lettre
      if bKeepGoing then
      begin
        sAnswerReceived := '';
        iChar := 0;
        while (iChar < 7) and (bKeepGoing) do
        begin
          sAnswerReceived := sAnswerReceived + AnsiChar(FRxClientBuffer[IDX_PROTO_COMMAND + iChar]);
          if (FRxClientBuffer[IDX_PROTO_COMMAND + iChar] < ord('A')) or (FRxClientBuffer[IDX_PROTO_COMMAND + iChar] > ord('Z')) then
          begin
            bKeepGoing := FALSE;
            WriteStatusLg('ERROR: Answer is not composed with letters as expected...', 'ERREUR: La réponse n''est pas composé de lettres comme attendu...', COLORERROR);
          end;
          inc(iChar);
        end;
      end;

      // 8. On valide que la réponse est composée uniquement de lettre
      if bKeepGoing then
      begin
        FLastSequenceNumber := FRxClientBuffer[IDX_PROTO_SEQ];
        ComputedCRC16 := MyCrc16(addr(FRxClientBuffer[0]), (iExpectedAnswerPacketLength - 2), $0000);
        ExpectedCRC16 := ((FRxClientBuffer[iExpectedAnswerPacketLength - 2] shl 8) or FRxClientBuffer[iExpectedAnswerPacketLength - 1]);
        if (ComputedCRC16 <> ExpectedCRC16) then
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: CRC16 computed is not the one expected...', 'ERREUR: Le CRC16 calculé n''est pas celui attendu...', COLORERROR);
          WriteStatusLg(Format('CRC16 computed: 0x%4.4X', [ComputedCRC16]), Format('CRC16 calculé: 0x%4.4X', [ComputedCRC16]), COLORERROR);
          WriteStatusLg(Format('CRC16 expected: 0x%4.4X', [ExpectedCRC16]), Format('CRC16 attendu: 0x%4.4X', [ExpectedCRC16]), COLORERROR);
        end;
      end;

      //9. On se met inactif si tout le packet a été envoyé.
      if bKeepGoing then
      begin
        if FClientSocket.Active then
        begin
          WriteStatusLg('Socket is now connected, we''ll close it...', 'Nous avons présentement une connexion, nous allons la fermer...', COLORDANGER);
          FClientSocket.Close;
          Application.ProcessMessages;
          WriteStatusLg('Connexion is now supposed to be closed', 'La connexion est supposée être fermée maintenant.', COLORSUCCESS);
        end;
        if FClientSocket.Active then
        begin
          bKeepGoing := FALSE;
          WriteStatusLg('ERROR: We should not be connected now...', 'ERREUR: Nous ne devrions pas être connecté présentement!', COLORERROR);
        end;
      end;

      // 10. Si tout s'est bien passé, on retourne succès.
      if bKeepGoing then
      begin
        WriteStatusLg('Success! Command was sent and we got a response!', 'Succès! Notre commande a été envoyé et nous avons eu notre réponse!', COLORSUCCESS);
        FromReceivedStuffLoadPacketInfo(FRxClientBuffer, Answer7, PayloadDataReceived);
        result := iExpectedAnswerPacketLength;
      end;

    except
      WriteStatusLg('ERROR: Exception happened in "PROTO_SendAMessageToServer" ...', 'ERREUR: Une erreur est arrivée pendant "PROTO_SendAMessageToServer"...', COLORERROR);
      result := -1;
    end;
  end
  else
  begin
    WriteStatusLg('ERROR: "FClientSocket" not defined in "PROTO_SendAMessageToServer" ...', 'ERREUR: "FClientSocket" indéfini dans "PROTO_SendAMessageToServer"...', COLORERROR);
    result := -1;
  end;
end;

function TProtocole_PROTO.PreparePacket(CommandAnswerIndex: integer; PayloadData: TStringList; paramTxBuffer: TIdBytes; MaximumPossibleSize: integer): integer;
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

procedure TProtocole_PROTO.AnyClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Client Socket Connect', 'Client Socket Connecté!', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Client Socket Connecting', 'Client Socket en train de se connecté', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Client Socket Disconnect', 'Client Socket déconnecté', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: integer);
begin
  if FWriteDebugFlag then
    WriteStatusLg(Format('Client Socket Error (Error code:%d)', [ErrorCode]), Format('Erreur de Client Socket (Code d''erreur:%d)', [ErrorCode]), COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Client Socket Lookup', 'Client Socket Lookup', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
  iNbBytesLus: integer;
begin
  if FWriteDebugFlag then
    WriteStatusLg('Client Socket Read', 'Client Socket Lecture', COLORSTATUS);
  iNbBytesLus := Socket.ReceiveBuf(FRxClientBuffer[FRxClientBufferIndex], (RXBUFFERSIZE - FRxClientBufferIndex));
  FRxClientBufferIndex := FRxClientBufferIndex + iNbBytesLus;
end;

procedure TProtocole_PROTO.AnyClientSocketWrite(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Client Socket Write', 'Écriture du Client Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketAccept(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Accept', 'Acception du Server Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Connect', 'Connexion au Server Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Client Disconnect', 'Déconnexion du Server Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: integer);
begin
  if FWriteDebugFlag then
    WriteStatusLg(Format('Server Socket Client Error, Error Code: %d', [ErrorCode]), Format('Erreur sur le Server Socket, code d''erreur: %d', [ErrorCode]), COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  iNbByteReceived, iMessage: integer;
  sAnswer: AnsiString;
  slPayloadDataReceived: TStringList;
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Client Read', 'Lecteur de données reçus sur le Serveur Socket', COLORSTATUS);
  iNbByteReceived := Socket.ReceiveBuf(FRxServerBuffer[FRxServerBufferIndex], (length(FRxServerBuffer) - FRxServerBufferIndex));
  FRxServerBufferIndex := FRxServerBufferIndex + iNbByteReceived;
  if FWriteDebugFlag then
    WriteStatusLg(Format('Number of byte received: %d', [iNbByteReceived]), Format('Nombre d''octets reçus: %d', [iNbByteReceived]), COLORSTATUS);

  if isValidPacketReceived(FRxServerBuffer, FRxServerBufferIndex) then
  begin
    FRxServerBufferIndex := 0;
    try
      slPayloadDataReceived := TStringList.Create;
      FromReceivedStuffLoadPacketInfo(FRxServerBuffer, sAnswer, slPayloadDataReceived);
      if FWriteDebugFlag then
      begin
        WriteStatusLg('We received this: ' + sAnswer, 'Nous avons reçu ceci: ' + sAnswer, COLORDANGER);
        WriteStatusLg('Number of string in payload data: ' + IntToStr(slPayloadDataReceived.Count), 'Nombre de chaînes dans la réponse: ' + IntToStr(slPayloadDataReceived.Count), COLORDANGER);
        if slPayloadDataReceived.Count > 0 then
        begin
          for iMessage := 0 to pred(slPayloadDataReceived.Count) do
            WriteStatusLg(Format('  Line %2d: %s', [iMessage, slPayloadDataReceived.Strings[iMessage]]), Format('  Chaîne %2d: %s', [iMessage, slPayloadDataReceived.Strings[iMessage]]), COLORDANGER);
        end;
      end;

      if Assigned(OnServerSocketValidPacketReceived) then
      begin
        OnServerSocketValidPacketReceived(self, Socket, sAnswer, slPayloadDataReceived);
      end;
    finally
      FreeAndNil(slPayloadDataReceived);
    end;
  end;
end;

procedure TProtocole_PROTO.AnyServerSocketClientWrite(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Client Write', 'Écriture au Serveur Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketGetSocket(Sender: TObject; Socket: NativeInt; var ClientSocket: TServerClientWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Get Socket', 'Obtention d''un Socket sur le Serveur Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketGetThread(Sender: TObject; ClientSocket: TServerClientWinSocket; var SocketThread: TServerClientThread);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Get Thread', 'Obtention d''un thread sur le Server Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketListen(Sender: TObject; Socket: TCustomWinSocket);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Listen', 'En écoute sur le Serveur Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketThreadEnd(Sender: TObject; Thread: TServerClientThread);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Thread End', 'Fin d''un thread sur le Server Socket', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyServerSocketThreadStart(Sender: TObject; Thread: TServerClientThread);
begin
  if FWriteDebugFlag then
    WriteStatusLg('Server Socket Thread Start', 'Début d''un thread sur le Server Socket', COLORSTATUS);
end;

function TProtocole_PROTO.isValidPacketReceived(paramBuffer: TIdBytes; paramBufferIndex: integer): boolean;
var
  bKeepGoing: boolean;
  iExpectedAnswerPacketLength, iChar: integer;
  sAnswerReceived: AnsiString;
  ComputedCRC16, ExpectedCRC16: word;
begin
  result := FALSE;
  bKeepGoing := TRUE;
  iExpectedAnswerPacketLength := 0;

  try
    // 1. Enough byte to begin to check something?
    if bKeepGoing then
    begin
      if paramBufferIndex < 3 then
        bKeepGoing := FALSE;
    end;

    // 2. Packet length is valid?
    if bKeepGoing then
    begin
      iExpectedAnswerPacketLength := (paramBuffer[IDX_PROTO_LENGTH + 0] shl 16) or (paramBuffer[IDX_PROTO_LENGTH + 1] shl 8) or (paramBuffer[IDX_PROTO_LENGTH + 2]);
      if (iExpectedAnswerPacketLength < (IDX_PROTO_PAYLOAD_DATA + 2)) or (iExpectedAnswerPacketLength > RXBUFFERSIZE) then
        bKeepGoing := FALSE;
    end;

    // 3. All the bytes received?
    if bKeepGoing then
    begin
      if paramBufferIndex < iExpectedAnswerPacketLength then
        bKeepGoing := FALSE;
    end;

    // 4. Answer between brackets?
    if bKeepGoing then
    begin
      if (paramBuffer[IDX_PROTO_LEFT_BRACKET] <> ord('[')) or (paramBuffer[IDX_PROTO_CLOSE_BRACKET] <> ord(']')) then
        bKeepGoing := FALSE;
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
          bKeepGoing := FALSE
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
        bKeepGoing := FALSE;
    end;

    // 7. If everything is good, we have an answer sir!
    if bKeepGoing then
      result := TRUE;
  except
    result := FALSE;
  end;
end;

procedure TProtocole_PROTO.FromReceivedStuffLoadPacketInfo(paramBuffer: TIdBytes; var Answer7: AnsiString; var PayloadDataReceived: TStringList);
var
  iChar, iExpectedAnswerPacketLength, iPromeneur, iPayloadLength: integer;
  sBuildingString: string;
begin
  Answer7 := '';
  if PayloadDataReceived <> nil then PayloadDataReceived.Clear;

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

procedure TProtocole_PROTO.WriteStatusLg(MsgInEnglish, MsgInFrench: string; ColorToUse: TColor);
begin
  if FMessageWindow <> nil then
  begin
    if FWriteDebugFlag or (ColorToUse = ColorError) then
    begin
      FMessageWindow.WriteStatusLg(FFriendlyNameForLog + ':' + MsgInEnglish, FFriendlyNameForLog + ':' + MsgInFrench, ColorToUse);
    end;
  end;
end;

function TProtocole_PROTO.MyCrc16(Pointer: PByte; NbBytes: integer; InitialCRC: word): word;
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

procedure TProtocole_PROTO.AnyUDPClientConnected(Sender: TObject);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Client Connected', 'Client UDP connecté', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyUDPClientDisconnected(Sender: TObject);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Client Disconnected', 'Client UDP déconnecté', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyUDPClientStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Client Status: ' + AStatusText, 'Statut du client UDP: ' + AStatusText, COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyUDPServerAfterBind(Sender: TObject);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server After Bind!', 'Après le "bind" sur le serveur UDP', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyUDPServerBeforeBind(AHandle: TIdSocketHandle);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Before Bind!', 'Avant le "bind" sur le serveur UDP', COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyUDPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Status: ' + AStatusText, 'Statut du serveur UDP: ' + AStatusText, COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyUDPServerException(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: string; const AExceptionClass: TClass);
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Exception: ' + AMessage, 'Exception sur le serveur UDP: ' + AMessage, COLORSTATUS);
end;

procedure TProtocole_PROTO.AnyUDPServerRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  sDisplayable: string;
  iChar, iNbBytesToSend: integer;
  IpTarget: array[0..3] of byte;
  TxBuffer: TIdBytes;
  slPayloadDataReceived: TStringList;
  sAnswer: AnsiString;
begin
  if FWriteDebugFlag then
    WriteStatusLg('UDP Server Received Something', 'Le serveur UDP a reçu de quoi', COLORSTATUS);

  if isValidPacketReceived(AData, Length(AData)) then
  begin
    slPayloadDataReceived := TStringList.Create;
    try
      FromReceivedStuffLoadPacketInfo(AData, sAnswer, slPayloadDataReceived);

      case FCommandList.IndexOf(sAnswer) of
        PROTO_CMD_WHOSERV:
          begin
            WriteStatusLg('UDP Server request valid!', 'Requête au serveur UDP valide!', COLORSUCCESS);
            for iChar := 0 to pred(4) do
              IpTarget[iChar] := AData[IDX_PROTO_PAYLOAD_DATA + iChar];
            SetLength(TxBuffer, 100);
            iNbBytesToSend := PreparePacket(PROTO_CMD_SERVRIS, nil, TxBuffer, length(TxBuffer));
            SetLength(TxBuffer, iNbBytesToSend);

            if FServerUDP.Active then
            begin
              if FWriteDebugFlag then WriteStatusLg('About to send back IP address of controller to ' + ABinding.PeerIp, 'Sur le point de retourner l''adresse du contrôleur à ' + ABinding.PeerIp, COLORDANGER);

              //              ABinding.Send(ABinding.PeerIP, ABinding.PeerPort, s[1], Length(s));
              ABinding.SendTo(ABinding.PeerIP, ABinding.PeerPort, TxBuffer);
              //              ABinding.Connect;
              //              ABinding.Send(TxBuffer);
                            //              FServerUDP.DefaultPort := PORT_FOR_IDENTIFICATION;
                            //              WriteStatusLg('Controller has provided its IP address to ' + ABinding.PeerIp, 'Le contrôleur s''est identifié pour le device à ' + ABinding.IP, COLORSUCCESS);
                                          //FServerUDP.SendBuffer(ABinding.PeerIp, PORT_FOR_IDENTIFICATION, TxBuffer);
            end;
          end;
      end;
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

procedure TProtocole_PROTO.LoadStringListWithIdentificationInfo(paramSl: TStringList);
begin
  paramSl.Add(CALLIDUS_INFO_COMPUTERNAME + '=' + Callidus_GetComputerName);
  paramSl.Add(CALLIDUS_INFO_DEVICETYPE + '=' + FDeviceName);
  paramSl.Add(CALLIDUS_INFO_COMPLEMENTNAME + '=' + FComplementDeviceName);
  paramSl.Add(CALLIDUS_INFO_VERSION + '=' + sCALLIDUS_SYSTEM_VERSION);
end;

function TProtocole_PROTO.SendIamAliveMessage: boolean;
var
  PayloadDataRequest: TStringList;
  Answer: AnsiString;
begin
  try
    PayloadDataRequest := TStringList.Create;
    try
      LoadStringListWithIdentificationInfo(PayloadDataRequest);
      result := (PitchUnMessageAndGetResponsePROTO(PROTO_CMD_IMALIVE, PayloadDataRequest, Answer, nil) > 0);
    finally
      FreeAndNil(PayloadDataRequest);
    end;
  except
    result := FALSE;
  end;
end;

procedure TProtocole_PROTO.ShutDownService;
begin
  if WorkingClientUDP <> nil then WorkingClientUDP.Active := FALSE;
  if WorkingServerUDP <> nil then WorkingServerUDP.Active := FALSE;
  if WorkingClientSocket <> nil then WorkingClientSocket.Active := FALSE;
  if WorkingServerSocket <> nil then WorkingServerSocket.Active := FALSE;
end;

procedure Register;
begin
  RegisterComponents('Callidus', [TProtocole_PROTO]);
end;

end.

