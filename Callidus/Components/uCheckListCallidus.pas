unit uCheckListCallidus;

interface

uses
  ComCtrls, Types, Classes, Windows, Messages, Forms, CheckLst, Controls;

type
  tCheckListCallidus = class(TCheckListBox)
  private
    FCheckWhenMove: boolean;
    FLastAction: boolean;
    FLastItem: longint;
    FJaiVuMouseDown: boolean;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ResetContent; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetNumberOfSelection: longint;
  published
    property CheckWhenMove: boolean read FCheckWhenMove write FCheckWhenMove default False;
    property LastItemTouched: longint read FLastITem write FLastITem default -1;
  end;

procedure Register;

implementation

uses
  SysUtils;

{ tCheckListCallidus.MouseDown}
procedure tCheckListCallidus.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SearchPoint: TPoint;
  MaybeItem: longint;

begin
  inherited;

  if FCheckWhenMove then
  begin
    if (Button = mbLeft) and (X > 14) then
    begin
      FJaiVuMouseDown := True;

      SearchPoint.x := X;
      SearchPoint.y := y;
      MaybeItem := ItemAtPos(SearchPoint, True);

      if MaybeItem <> -1 then
      begin
        Checked[MaybeItem] := not Checked[MaybeItem];
        FLastAction := Checked[MaybeItem];
        FLastItem := MaybeItem;
      end;
    end;
  end;
end;

{ tCheckListCallidus.MouseMove}
procedure tCheckListCallidus.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  SearchPoint: TPoint;
  MaybeItem: longint;
begin
  inherited;

  if FCheckWhenMove and FJaiVuMouseDown then
  begin
    if (ssLeft in Shift) and (X > 14) then
    begin
      SearchPoint.x := X;
      SearchPoint.y := y;

      MaybeItem := ItemAtPos(SearchPoint, True);
      if (MaybeItem <> -1) then
      begin
        Checked[MaybeItem] := FLastAction;
      end;
    end;
  end;
end;

{ tCheckListCallidus.ResetContent}
procedure tCheckListCallidus.ResetContent;
begin
  inherited;
  FJaiVuMouseDown := False;
end;

{ tCheckListCallidus.Create}
constructor tCheckListCallidus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLastAction := False;
  FLastItem := -1;
  FJaiVuMouseDown := False;
end;

{ tCheckListCallidus.GetNumberOfSelection}
function tCheckListCallidus.GetNumberOfSelection: longint;
var
  IndexLocal: longint;
begin
  result := 0;
  for IndexLocal := 0 to (count - 1) do
    if Checked[IndexLocal] then
      inc(result);
end;

{ Register}
procedure Register;
begin
  RegisterComponents('Callidus', [tCheckListCallidus]);
end;

end.

