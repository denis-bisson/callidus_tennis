unit uLabeledEditCallidus;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, ExtCtrls, Messages;

type

  { TBoundLabel }
  TBoundCheckbox = class(TCustomCheckbox)
  private
    function GetTop: Integer;
    function GetLeft: Integer;
    function GetWidth: Integer;
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  protected
    procedure AdjustBounds; dynamic;
    procedure BMSETCHECK(var Message: TMessage); message BM_SETCHECK;
    procedure CMEnabledchanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Height: Integer read GetHeight write SetHeight;
    property Left: Integer read GetLeft;
    property Top: Integer read GetTop;
    property Width: Integer read GetWidth write SetWidth;
    property Checked;
    property OnClick;
  end;

  tCustomLabeledEditCallidus = class(TLabeledEdit)
  private
    { Déclarations privées }
    FCheckbox: TBoundCheckbox;
    FCheckboxSpacing: longint;

    FBluberiBoardKeyWord: string;
    FBluberiHint: string;
    FCallidusFilterType: longint;
    procedure SetCheckboxPosition;
    procedure SetCheckboxSpacing(const Value: Integer);
  protected
    { Déclarations protégées }
    procedure SetParent(AParent: TWinControl); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CMVisiblechanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMBidimodechanged(var Message: TMessage); message CM_BIDIMODECHANGED;
  public
    { Déclarations publiques }
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    procedure SetupInternalCheckbox;
    procedure SetupEnabledOrNot(State: boolean);
    property Checkbox: TBoundCheckbox read FCheckbox;
    property CheckboxSpacing: longint read FCheckboxSpacing write SetCheckboxSpacing default 3;
    property BluberiBoardKeyWord: string read FBluberiBoardKeyWord write FBluberiBoardKeyWord;
    property BluberiHint: string read FBluberiHint write FBluberiHint;
    property CallidusFilterType: integer read FCallidusFilterType write FCallidusFilterType;
  published
    { Déclarations publiées }
  end;

  tLabeledEditCallidus = class(tCustomLabeledEditCallidus)
  published
    property Alignment;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EditLabel;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property LabelPosition;
    property LabelSpacing;
    property MaxLength;
    property OEMConvert;
    property NumbersOnly;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Touch;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;

    property Checkbox;
    property CheckboxSpacing;
    property BluberiBoardKeyWord;
    property BluberiHint;
    property CallidusFilterType;
  end;

procedure Register;

implementation

uses
  System.Types, Windows;

{ tCustomLabeledEditCallidus}
{ tCustomLabeledEditCallidus.SetCheckboxPosition}
procedure tCustomLabeledEditCallidus.SetCheckboxPosition;
var
  P: TPoint;
begin
  if FCheckbox = nil then
    Exit;
  P := Point(Left - FCheckbox.Width - FCheckboxSpacing, Top + ((Height - FCheckbox.Height) div 2));
  FCheckbox.SetBounds(P.x, P.y, FCheckbox.Width, FCheckbox.Height);
end;

{ tCustomLabeledEditCallidus.SetCheckboxSpacing}
procedure tCustomLabeledEditCallidus.SetCheckboxSpacing(const Value: Integer);
begin
  FCheckboxSpacing := Value;
  SetCheckboxPosition;
end;

{ tCustomLabeledEditCallidus.SetParent}
procedure tCustomLabeledEditCallidus.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if FCheckbox = nil then
    exit;
  FCheckbox.Parent := AParent;
  FCheckbox.Visible := True;
end;

{ tCustomLabeledEditCallidus.Notification}
procedure tCustomLabeledEditCallidus.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FCheckbox) and (Operation = opRemove) then
    FCheckbox := nil;
end;

{ tCustomLabeledEditCallidus.CMVisiblechanged}
procedure tCustomLabeledEditCallidus.CMVisiblechanged(var Message: TMessage);
begin
  inherited;
  if FCheckbox <> nil then
    FCheckbox.Visible := Visible;
end;

{ tCustomLabeledEditCallidus.CMBidimodechanged}
procedure tCustomLabeledEditCallidus.CMBidimodechanged(var Message: TMessage);
begin
  inherited;
  if FCheckbox <> nil then
    FCheckbox.BiDiMode := BiDiMode;
end;

{ tCustomLabeledEditCallidus.Create}
constructor tCustomLabeledEditCallidus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCheckboxSpacing := 0;
  SetupInternalCheckbox;
end;

{ tCustomLabeledEditCallidus.SetBounds}
procedure tCustomLabeledEditCallidus.SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  SetCheckboxPosition;
end;

{ tCustomLabeledEditCallidus.SetupInternalCheckbox}
procedure tCustomLabeledEditCallidus.SetupInternalCheckbox;
begin
  if Assigned(FCheckbox) then
    exit;
  FCheckbox := TBoundCheckbox.Create(Self);
  FCheckbox.FreeNotification(Self);
  FCheckbox.Caption := '';
  FCheckbox.Width := 15;
end;

{ tCustomLabeledEditCallidus.SetupEnabledOrNot}
procedure tCustomLabeledEditCallidus.SetupEnabledOrNot(State: boolean);
begin
  Enabled := State;
end;

{ TBoundCheckbox }
{ TBoundCheckbox.Create}
constructor TBoundCheckbox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name := 'SubCheckbox'; { do not localize }
  SetSubComponent(True);
  if Assigned(AOwner) then
    Caption := AOwner.Name;
end;

{ TBoundCheckbox.AdjustBounds}
procedure TBoundCheckbox.AdjustBounds;
begin
  //  inherited AdjustBounds;
  if Owner is tLabeledEditCallidus then
    with Owner as tLabeledEditCallidus do
      SetCheckboxPosition;
end;

{ TBoundCheckbox.BMSETCHECK}
procedure TBoundCheckbox.BMSETCHECK(var Message: TMessage);
begin
  inherited;
  if Owner is tLabeledEditCallidus then
    with Owner as tLabeledEditCallidus do
    begin
      SetupEnabledOrNot(Checked);
    end;
end;

{ TBoundCheckbox.CMEnabledchanged}
procedure TBoundCheckbox.CMEnabledchanged(var Message: TMessage);
begin
  inherited;
  if Owner is tLabeledEditCallidus then
    with Owner as tLabeledEditCallidus do
    begin
      SetupEnabledOrNot(Self.Enabled and Self.Checked);
    end;
end;

{ TBoundCheckbox.GetHeight}
function TBoundCheckbox.GetHeight: Integer;
begin
  Result := inherited Height;
end;

{ TBoundCheckbox.GetLeft}
function TBoundCheckbox.GetLeft: Integer;
begin
  Result := inherited Left;
end;

{ TBoundCheckbox.GetTop}
function TBoundCheckbox.GetTop: Integer;
begin
  Result := inherited Top;
end;

{ TBoundCheckbox.GetWidth}
function TBoundCheckbox.GetWidth: Integer;
begin
  Result := inherited Width;
end;

{ TBoundCheckbox.SetHeight}
procedure TBoundCheckbox.SetHeight(const Value: Integer);
begin
  SetBounds(Left, Top, Width, Value);
end;

{ TBoundCheckbox.SetWidth}
procedure TBoundCheckbox.SetWidth(const Value: Integer);
begin
  SetBounds(Left, Top, Value, Height);
end;

{ Register}
procedure Register;
begin
  RegisterComponents('Callidus', [tLabeledEditCallidus]);
end;

end.

