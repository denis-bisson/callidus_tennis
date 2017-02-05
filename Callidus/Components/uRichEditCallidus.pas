unit uRichEditCallidus;

interface

uses
  // Delphi
  Types, Classes, Windows, Messages, StdCtrls, ComCtrls, Graphics, Menus, Forms,
  ClipBrd,

  // Third party

  // Callidus
  uColorCallidus;

type
  tRichEditCallidus = class(TRichEdit)
  private
    FAddTime: boolean;
    FWriteDebug: boolean;
    FFlagWriteOptionel: boolean;
    FTitleColor: TColor;
    FSubTitleColor: TColor;
    FTitleChar: Char;
    FSubTitleChar: Char;
    FTitleWidth: longint;
    FMissingPopupMenu: TPopupMenu;
    FLastTextColor: TColor;
    FLanguage: longint;
    procedure itemUndoClick(Sender: TObject);
    procedure itemCutClick(Sender: TObject);
    procedure itemCopyClick(Sender: TObject);
    procedure itemPasteClick(Sender: TObject);
    procedure itemDeleteClick(Sender: TObject);
    procedure itemSelectAllClick(Sender: TObject);

  public
    procedure WriteTitleString(A: string);
    procedure WriteSubTitleString(A: string);
    procedure WriteTitleStringLg(A, B: string);
    procedure WriteSubTitleStringLg(A, B: string);
    procedure WriteStatusStalled(A: string; C: dword);
    procedure WriteStatus(A: string; C: dword = clBlack);
    procedure WriteDisplayable(A, Remplacement: string; C: dword);
    procedure WriteDebug(A: string);
    procedure WriteStatusLg(A, B: string; C: dword);
    procedure WriteStatusLastColorLg(A, B: string);
    procedure AddLinesFromTextFile(NomFichierTextFile: string; C: dword);
    procedure WriteStatusOptionel(A: string; C: dword);
    procedure JumpOneLine;
    procedure WriteLigneALigneFields(A: AnsiString; CouleurToUse: longint);
    procedure ScrollALaFin;
    procedure ScrollToTop;
    function GeneralExtractFromRichEditCallidus(KeywordToSearch: AnsiString; LongueurToExtract: longint; var AnswerCode: AnsiString): boolean;
    procedure CopyAllWindowInClipBoard;
    procedure AddMissingPopupMenu;
    procedure WriteFinalResult(FinalString: string; ColorToUse: longint);

  published
    constructor Create(AOwner: TComponent); override;
    property AddTime: boolean read FAddTime write FAddTime default False;
    property DoWriteDebug: boolean read FWriteDebug write FWriteDebug default False;
    property TitleColor: TColor read FTitleColor write FTitleColor default clBlack;
    property SubTitleColor: TColor read FSubTitleColor write FSubTitleColor default clBlack;
    property LastTextColor: TColor read FLastTextColor write FLastTextColor default clBlack;
    property TitleChar: Char read FTitleChar write FTitleChar default '=';
    property SubTitleChar: Char read FSubTitleChar write FSubTitleChar default '-';
    property TitleWidth: longint read FTitleWidth write FTitleWidth default 78;
    property FlagWriteOptionel: boolean read FFlagWriteOptionel write FFlagWriteOptionel default True;
    property Language: longint read FLanguage write FLanguage default 0;
  end;

procedure Attempt_WriteStatusLg(StatusWindow: tRichEditCallidus; A, B: string; C: dword);
procedure Attempt_WriteStatus(StatusWindow: tRichEditCallidus; A: string; C: dword);
procedure Attempt_WriteTitleString(StatusWindow: tRichEditCallidus; A: string);
procedure Attempt_WriteTitleStringLg(StatusWindow: tRichEditCallidus; A, B: string);
procedure Attempt_JumpOneLine(StatusWindow: tRichEditCallidus);
procedure Attempt_WriteFinalResult(StatusWindow: tRichEditCallidus; FinalString: string; ColorToUse: longint);

procedure Register;

var
  Attempt_FlagConsoleApplication: boolean = False;

implementation

uses
  // Delphi
  SysUtils, StrUtils

  // Third party

  // Callidus
  ;

{ tRichEditCallidus}
{ tRichEditCallidus.Create}
constructor tRichEditCallidus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWriteDebug := False;
  FTitleColor := clBlue;
  FSubTitleColor := clMaroon;
  FLastTextColor := clBlack;
  FTitleChar := #61;
  FSubTitleChar := #45;
  FTitleWidth := 78;
  FFlagWriteOptionel := True;
end;

{ tRichEditCallidus.AddLinesFromTextFile}
procedure tRichEditCallidus.AddLinesFromTextFile(NomFichierTextFile: string; C: dword);
var
  FichierTexte: textfile;
  LigneLue: string;
begin
  FLastTextColor := C;
  if FileExists(NomFichierTextFile) then
  begin
    AssignFile(FichierTexte, NomFichierTextFile);
    filemode := 0;
    Reset(FichierTexte);
    try
      while not eof(FichierTexte) do
      begin
        ReadLn(FichierTexte, LigneLue);
        WriteStatus(LigneLue, C);
      end;
    finally
      CloseFile(FichierTexte);
    end;
  end
  else
  begin
    WriteStatus('ERROR: cannot finde this file: ' + NomFichierTextFile, clRed);
  end;
end;

procedure tRichEditCallidus.JumpOneLine;
begin
  WriteStatus('', FLastTextColor);
end;

{ tRichEditCallidus.WriteStatusOptionel}
procedure tRichEditCallidus.WriteStatusOptionel(A: string; C: dword);
begin
  if FFlagWriteOptionel then
  begin
    WriteStatus(A, C);
  end;
end;

{ tRichEditCallidus.WriteTitleString}
procedure tRichEditCallidus.WriteTitleString(A: string);
var
  Index, ManqueAGagnerDroit: longint;
  B: string;
begin
  A := uppercase(A);
  if Lines.Count > 0 then
    WriteStatus('', clBlack);

  B := '';
  for Index := 1 to FTitleWidth do
    B := B + FTitleChar;

  A := FTitleChar + FTitleChar + FTitleChar + FTitleChar + FTitleChar + A;
  ManqueAGagnerDroit := FTitleWidth - length(A);
  for Index := 1 to ManqueAGagnerDroit do
    A := A + FTitleChar;
  WriteStatus(B, FTitleColor);
  WriteStatus(A, FTitleColor);
  WriteStatus(B, FTitleColor);
end;

{ tRichEditCallidus.WriteSubTitleString}
procedure tRichEditCallidus.WriteSubTitleString(A: string);
var
  Index: longint;
  B: string;
begin
  B := '';
  for Index := 1 to 10 do
    B := B + FSubTitleChar;

  for Index := 1 to length(A) do
    if A[Index] <> ' ' then
      B := B + A[Index]
    else
      B := B + FSubTitleChar;

  while length(B) < FTitleWidth do
    B := B + FSubTitleChar;

  WriteStatus(B, FSubTitleColor);
end;

{ tRichEditCallidus.WriteTitleStringLg}
procedure tRichEditCallidus.WriteTitleStringLg(A, B: string);
begin
  case Language of
    1:
      WriteTitleString(B);
  else
    WriteTitleString(A);
  end;
end;

{ tRichEditCallidus.WriteSubTitleStringLg}
procedure tRichEditCallidus.WriteSubTitleStringLg(A, B: string);
begin
  case Language of
    1:
      WriteSubTitleString(B);
  else
    WriteSubTitleString(A);
  end;
end;

{ tRichEditCallidus.WriteStatusLg}
procedure tRichEditCallidus.WriteStatusLg(A, B: string; C: dword);
begin
  case Language of
    1:
      WriteStatus(B, C);
  else
    WriteStatus(A, C);
  end;
end;

{ tRichEditCallidus.WriteStatusLastColorLg}
procedure tRichEditCallidus.WriteStatusLastColorLg(A, B: string);
begin
  case Language of
    1:
      WriteStatus(B, FLastTextColor);
  else
    WriteStatus(A, FLastTextColor);
  end;
end;

{ tRichEditCallidus.WriteDebug}
procedure tRichEditCallidus.WriteDebug(A: string);
begin
  if FWriteDebug then
    WriteStatus(A, COLORDEBUG);
end;

{ GetSomethingDisplayable}
function GetSomethingDisplayable(A: AnsiString): AnsiString;
var
  Unique: AnsiChar;
  t: longint;
begin
  if length(A) > 0 then
  begin
    result := '';
    for t := 1 to length(A) do
    begin
      Unique := A[t];
      if (ord(Unique) >= 32) and (ord(Unique) < 128) then
      begin
        result := result + Unique;
      end
      else
      begin
        result := result + '<0x' + AnsiString(Format('%2.2X', [ord(Unique)])) + '>';
      end;
    end;
  end
  else
  begin
    result := '';
  end;
end;

{ tRichEditCallidus.WriteStatus}
procedure tRichEditCallidus.WriteStatus(A: string; C: dword = clBlack);
var
  Prefix: string;
  Hour, Min, Sec, MSec: word;
begin
  if FAddTime then
  begin
    DecodeTime(Now, Hour, Min, Sec, MSec);
    Prefix := Format('%2.2d:%2.2d:%2.2d:%3.3d - ', [Hour, Min, Sec, MSec]);
  end
  else
  begin
    Prefix := '';
  end;
  FLastTextColor := C;
  SelAttributes.Color := C;
  if parent <> nil then
  begin
    try
      Lines.Add(Prefix + A);
    except
      Lines.Add(GetSomethingDisplayable(AnsiString(Prefix + A)));
    end;
  end;
  Application.ProcessMessages;
end;

{ tRichEditCallidus.WriteDisplayable}
procedure tRichEditCallidus.WriteDisplayable(A, Remplacement: string; C: dword);
var
  i: Integer;
  OutText: string;
begin
  OutText := '';
  for i := 1 to length(A) do
  begin
    if (ord(A[i]) >= $20) then
      OutText := OutText + A[i]
    else
      OutText := OutText + Remplacement;
  end;

  WriteStatus(OutText, C);
end;

{ tRichEditCallidus.WriteStatusStalled}
procedure tRichEditCallidus.WriteStatusStalled(A: string; C: dword);
var
  Prefix: string;
  Hour, Min, Sec, MSec: word;
begin
  if FAddTime then
  begin
    DecodeTime(Now, Hour, Min, Sec, MSec);
    Prefix := Format('%2.2d:%2.2d:%2.2d:%3.3d - ', [Hour, Min, Sec, MSec]);
  end
  else
  begin
    Prefix := '';
  end;

  if Lines.Count > 0 then
  begin
    Lines.Delete(Lines.Count - 1);
  end;

  FLastTextColor := C;
  SelAttributes.Color := C;
  Lines.Add(Prefix + A);
end;

{ tRichEditCallidus.ScrollALaFin}
procedure tRichEditCallidus.ScrollALaFin;
begin
  Perform(EM_SCROLLCARET, 0, 0);
  Application.ProcessMessages;
end;

{ tRichEditCallidus.ScrollToTop}
procedure tRichEditCallidus.ScrollToTop;
begin
  SelStart := 0;
  Perform(EM_SCROLLCARET, 0, 0);
  Application.ProcessMessages;
end;

{ tRichEditCallidus.WriteLigneALigneFields}
procedure tRichEditCallidus.WriteLigneALigneFields(A: AnsiString; CouleurToUse: longint);
const
  STATE_CUMULATE = 1;
  STATE_WAITNEWPARAM = 2;
var
  InnerIndex, NbDeSpaceToAdd, PosDuEgal, StateMachine, LonguestParam, Index, CurrentLength: longint;
  CurrentWord: AnsiString;
begin
  // On cherche le nombre d'espace à mettre
  LonguestParam := 0;
  Index := 1;
  CurrentLength := 0;
  StateMachine := STATE_CUMULATE;
  while Index <= length(A) do
  begin
    case StateMachine of
      STATE_CUMULATE:
        begin
          case A[Index] of
            AnsiChar($0D), AnsiChar($0A):
              begin
                StateMachine := STATE_WAITNEWPARAM;
              end;

            AnsiChar('='):
              begin
                if CurrentLength > LonguestParam then
                  LonguestParam := CurrentLength;
                CurrentLength := 0;
                StateMachine := STATE_WAITNEWPARAM;
              end;

            AnsiChar(' '):
              begin
              end;

          else
            begin
              inc(CurrentLength);
            end;
          end;
        end;

      STATE_WAITNEWPARAM:
        begin
          case A[Index] of
            AnsiChar($0A):
              begin
                StateMachine := STATE_CUMULATE;
                CurrentLength := 0;
              end;
          end;
        end;
    end;

    inc(Index);
  end;

  if CurrentLength > LonguestParam then
    LonguestParam := CurrentLength;

  // On fait la job!
  CurrentWord := '';
  Index := 1;
  while Index <= length(A) do
  begin
    case A[Index] of
      AnsiChar($0D):
        begin
        end;

      AnsiChar($0A):
        begin
          PosDuEgal := pos('=', CurrentWord);
          NbDeSpaceToAdd := (LonguestParam - PosDuEgal) + 2;
          for InnerIndex := 1 to NbDeSpaceToAdd do
            CurrentWord := ' ' + CurrentWord;
          WriteStatus(CurrentWord, CouleurToUse);
          CurrentWord := '';
        end;

    else
      begin
        CurrentWord := CurrentWord + A[Index];
      end;
    end;

    inc(Index);
  end;

  if CurrentWord <> '' then
  begin
    PosDuEgal := pos('=', CurrentWord);
    NbDeSpaceToAdd := (LonguestParam - PosDuEgal) + 2;
    for InnerIndex := 1 to NbDeSpaceToAdd do
      CurrentWord := ' ' + CurrentWord;
    WriteStatus(CurrentWord, CouleurToUse);
    CurrentWord := '';
  end;
end;

{ tRichEditCallidus.GeneralExtractFromRichEditCallidus}
function tRichEditCallidus.GeneralExtractFromRichEditCallidus(KeywordToSearch: AnsiString; LongueurToExtract: longint; var AnswerCode: AnsiString): boolean;
var
  PosTrigger, IndexLigne: longint;
  FlagStop: boolean;
begin
  result := False;
  AnswerCode := '';
  PosTrigger := 0;

  IndexLigne := 0;
  FlagStop := False;
  while (IndexLigne < Lines.Count) and (FlagStop = False) do
  begin
    PosTrigger := pos(KeywordToSearch, Lines.Strings[IndexLigne]);
    if PosTrigger <> 0 then
      FlagStop := True
    else
      inc(IndexLigne);
  end;

  if FlagStop then
  begin
    AnswerCode := AnsiString(copy(Lines.Strings[IndexLigne], PosTrigger + length(KeywordToSearch), LongueurToExtract));
    result := True;
  end;
end;

{ tRichEditCallidus.CopyAllWindowInClipBoard}
procedure tRichEditCallidus.CopyAllWindowInClipBoard;
begin
  SelStart := 0;
  SelLength := GetTextLen;

  CopyToClipboard;
  if ClipBoard.AsText = 'Mylène' then
    Application.MainForm.Caption := 'Crime! T''avais "Mylène" dans le clipboard!';
  SelLength := 0;
end;

{ tRichEditCallidus.itemUndoClick}
procedure tRichEditCallidus.itemUndoClick(Sender: TObject);
begin
  Undo;
end;

{ tRichEditCallidus.itemCutClick}
procedure tRichEditCallidus.itemCutClick(Sender: TObject);
begin
  CutToClipboard;
end;

{ tRichEditCallidus.itemCopyClick}
procedure tRichEditCallidus.itemCopyClick(Sender: TObject);
begin
  CopyToClipboard;
end;

{ tRichEditCallidus.itemPasteClick}
procedure tRichEditCallidus.itemPasteClick(Sender: TObject);
begin
  PasteFromClipboard;
end;

{ tRichEditCallidus.itemDeleteClick}
procedure tRichEditCallidus.itemDeleteClick(Sender: TObject);
begin
  ClearSelection;
end;

{ tRichEditCallidus.itemSelectAllClick}
procedure tRichEditCallidus.itemSelectAllClick(Sender: TObject);
begin
  SelectAll;
end;

{ tRichEditCallidus.AddMissingPopupMenu}
procedure tRichEditCallidus.AddMissingPopupMenu;

  procedure BatisMenu(ThisMenu: TPopupMenu; FlagOnSajouteAExistant: boolean);
  var
    MyNewSubMenu: TMenuItem;
  begin
    if FlagOnSajouteAExistant then
    begin
      MyNewSubMenu := TMenuItem.Create(Self);
      MyNewSubMenu.Caption := '-';
      ThisMenu.Items.Add(MyNewSubMenu);
    end;

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := 'Undo';
    MyNewSubMenu.OnClick := itemUndoClick;
    MyNewSubMenu.ShortCut := $405A; //CTRL + Z;
    ThisMenu.Items.Add(MyNewSubMenu);

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := '-';
    ThisMenu.Items.Add(MyNewSubMenu);

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := 'Cut';
    MyNewSubMenu.OnClick := itemCutClick;
    MyNewSubMenu.ShortCut := $4058; //CTRL + X;
    ThisMenu.Items.Add(MyNewSubMenu);

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := 'Copy';
    MyNewSubMenu.OnClick := itemCopyClick;
    MyNewSubMenu.ShortCut := $4043; //CTRL + C;
    ThisMenu.Items.Add(MyNewSubMenu);

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := 'Paste';
    MyNewSubMenu.OnClick := itemPasteClick;
    MyNewSubMenu.ShortCut := $4056; //CTRL + V;
    ThisMenu.Items.Add(MyNewSubMenu);

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := 'Delete';
    MyNewSubMenu.OnClick := itemDeleteClick;
    ThisMenu.Items.Add(MyNewSubMenu);

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := '-';
    ThisMenu.Items.Add(MyNewSubMenu);

    MyNewSubMenu := TMenuItem.Create(Self);
    MyNewSubMenu.Caption := 'Select all';
    MyNewSubMenu.OnClick := itemSelectAllClick;
    MyNewSubMenu.ShortCut := $4041; //CTRL + A;
    ThisMenu.Items.Add(MyNewSubMenu);
  end;

begin
  if PopupMenu = nil then
  begin
    if FMissingPopupMenu = nil then
    begin
      FMissingPopupMenu := TPopupMenu.Create(Self);

      BatisMenu(FMissingPopupMenu, False);
      PopupMenu := FMissingPopupMenu;
    end;
  end
  else
  begin
    BatisMenu(PopupMenu, True);
  end;
end;

{ tRichEditCallidus.WriteFinalResult}
procedure tRichEditCallidus.WriteFinalResult(FinalString: string; ColorToUse: longint);
var
  StarLine, MessageToWrite: string;
  Hour, Min, Sec, MSec: word;
begin
  StarLine := '';
  while length(StarLine) < length(FinalString) do
    StarLine := StarLine + '*';

  DecodeTime(Now, Hour, Min, Sec, MSec);

  SelAttributes.Color := ColorToUse;
  MessageToWrite := Format('%2.2d:%2.2d:%2.2d:%3.3d - ', [Hour, Min, Sec, MSec]) + ' : ' + StarLine;
  Lines.Add(MessageToWrite);
  SelAttributes.Color := ColorToUse;
  MessageToWrite := Format('%2.2d:%2.2d:%2.2d:%3.3d - ', [Hour, Min, Sec, MSec]) + ' : ' + FinalString;
  Lines.Add(MessageToWrite);
  SelAttributes.Color := ColorToUse;
  MessageToWrite := Format('%2.2d:%2.2d:%2.2d:%3.3d - ', [Hour, Min, Sec, MSec]) + ' : ' + StarLine;
  Lines.Add(MessageToWrite);

  SelStart := GetTextLen;
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
  Application.ProcessMessages;
end;

{ Attempt_WriteFinalResult}
procedure Attempt_WriteFinalResult(StatusWindow: tRichEditCallidus; FinalString: string; ColorToUse: longint);
begin
  if StatusWindow <> nil then
    StatusWindow.WriteFinalResult(FinalString, ColorToUse)
  else if Attempt_FlagConsoleApplication then
    WriteLn(FinalString);
end;

{ Attempt_WriteStatusLg}
procedure Attempt_WriteStatusLg(StatusWindow: tRichEditCallidus; A, B: string; C: dword);
begin
  if StatusWindow <> nil then
    StatusWindow.WriteStatusLg(A, B, C)
  else if Attempt_FlagConsoleApplication then
    WriteLn(A);
end;

{ Attempt_WriteStatus}
procedure Attempt_WriteStatus(StatusWindow: tRichEditCallidus; A: string; C: dword);
begin
  if StatusWindow <> nil then
    StatusWindow.WriteStatus(A, C)
  else if Attempt_FlagConsoleApplication then
    WriteLn(A);
end;

{ Attempt_WriteTitleString}
procedure Attempt_WriteTitleString(StatusWindow: tRichEditCallidus; A: string);
begin
  if StatusWindow <> nil then
    StatusWindow.WriteTitleString(A)
  else if Attempt_FlagConsoleApplication then
    WriteLn(A);
end;

{ Attempt_WriteTitleStringLg}
procedure Attempt_WriteTitleStringLg(StatusWindow: tRichEditCallidus; A, B: string);
begin
  if StatusWindow <> nil then
    StatusWindow.WriteTitleStringLg(A, B)
  else if Attempt_FlagConsoleApplication then
    WriteLn(A);
end;

{ Attempt_JumpOneLine}
procedure Attempt_JumpOneLine(StatusWindow: tRichEditCallidus);
begin
  if StatusWindow <> nil then
    StatusWindow.JumpOneLine
  else if Attempt_FlagConsoleApplication then
    WriteLn;
end;

{ Register}
procedure Register;
begin
  RegisterComponents('Callidus', [tRichEditCallidus]);
end;

end.

