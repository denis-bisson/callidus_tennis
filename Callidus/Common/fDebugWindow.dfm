object frmDebugWindow: TfrmDebugWindow
  Left = 0
  Top = 0
  Caption = 'frmDebugWindow'
  ClientHeight = 192
  ClientWidth = 384
  Color = clBtnFace
  Constraints.MinHeight = 250
  Constraints.MinWidth = 400
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MyStatusBar: TStatusBar
    Left = 0
    Top = 173
    Width = 384
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 130
      end
      item
        Width = 50
      end>
  end
  object StatusWindow: TRichEditGlobal6
    Left = 0
    Top = 0
    Width = 384
    Height = 173
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    HideSelection = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
    Zoom = 100
    AddTime = True
    TitleColor = clBlue
    SubTitleColor = clMaroon
  end
  object MainMenu1: TMainMenu
    Left = 160
    Top = 72
    object miActions: TMenuItem
      Caption = 'Actions...'
      object Closedebugwindow1: TMenuItem
        Action = actCloseDebugWindow
      end
    end
  end
  object ActionManagerDebugWindow: TActionManager
    Left = 220
    Top = 70
    StyleName = 'Platform Default'
    object actCloseDebugWindow: TAction
      Caption = 'Close Debug Window'
      ShortCut = 123
      OnExecute = actCloseDebugWindowExecute
    end
  end
end
