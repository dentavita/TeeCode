object CodeRunner: TCodeRunner
  Left = 229
  Top = 179
  Width = 774
  Height = 488
  Caption = 'Code Runner'
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  WindowState = wsMaximized
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 185
    Top = 41
    Height = 387
  end
  object Splitter2: TSplitter
    Left = 570
    Top = 41
    Height = 387
    Align = alRight
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 758
    Height = 41
    Align = alTop
    TabOrder = 0
    object ComboBox1: TComboBox
      Left = 344
      Top = 8
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'Object Pascal'
      OnChange = ComboBox1Change
      Items.Strings = (
        'Object Pascal'
        'C++'
        'C#'
        'Java')
    end
    object BRun: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Run'
      TabOrder = 1
      OnClick = BRunClick
    end
    object BStop: TButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Stop'
      Enabled = False
      TabOrder = 2
      OnClick = BStopClick
    end
    object BStep: TButton
      Left = 185
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Step'
      TabOrder = 3
      OnClick = BStepClick
    end
    object Button1: TButton
      Left = 504
      Top = 6
      Width = 57
      Height = 25
      Caption = '&Font...'
      TabOrder = 4
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 185
    Height = 387
    Align = alLeft
    TabOrder = 1
    object CodeTree: TTreeView
      Left = 1
      Top = 1
      Width = 183
      Height = 344
      Align = alClient
      DragMode = dmAutomatic
      HideSelection = False
      HotTrack = True
      Indent = 19
      PopupMenu = PopupTree
      ReadOnly = True
      TabOrder = 0
      OnChange = CodeTreeChange
      OnCustomDrawItem = CodeTreeCustomDrawItem
      OnDragDrop = CodeTreeDragDrop
      OnDragOver = CodeTreeDragOver
    end
    object Panel5: TPanel
      Left = 1
      Top = 345
      Width = 183
      Height = 41
      Align = alBottom
      TabOrder = 1
      object Label1: TLabel
        Left = 7
        Top = 9
        Width = 30
        Height = 13
        Caption = 'Value:'
      end
      object EditValue: TEdit
        Left = 43
        Top = 6
        Width = 121
        Height = 21
        Enabled = False
        TabOrder = 0
        OnChange = EditValueChange
      end
    end
  end
  object Panel3: TPanel
    Left = 573
    Top = 41
    Width = 185
    Height = 387
    Align = alRight
    TabOrder = 2
    object Splitter3: TSplitter
      Left = 1
      Top = 194
      Width = 183
      Height = 3
      Cursor = crVSplit
      Align = alTop
    end
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 183
      Height = 193
      ActivePage = TabSheet1
      Align = alTop
      HotTrack = True
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Watches'
        object Watches: TListBox
          Left = 0
          Top = 0
          Width = 175
          Height = 165
          Align = alClient
          ItemHeight = 13
          PopupMenu = PopupWatches
          TabOrder = 0
          OnClick = WatchesClick
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Breakpoints'
        ImageIndex = 1
        object Breakpoints: TListBox
          Left = 0
          Top = 0
          Width = 175
          Height = 165
          Align = alClient
          ItemHeight = 13
          PopupMenu = PopupBreakpoints
          TabOrder = 0
          OnClick = BreakpointsClick
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'Stack'
        ImageIndex = 2
        object ListBox1: TListBox
          Left = 0
          Top = 0
          Width = 175
          Height = 165
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
    object PageControl2: TPageControl
      Left = 1
      Top = 197
      Width = 183
      Height = 189
      ActivePage = TabSheet5
      Align = alClient
      TabOrder = 1
      object TabSheet4: TTabSheet
        Caption = 'Log'
        object RunLog: TListBox
          Left = 0
          Top = 0
          Width = 175
          Height = 116
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
        end
      end
      object TabSheet5: TTabSheet
        Caption = 'Palette'
        ImageIndex = 1
        object Palette: TListBox
          Left = 0
          Top = 0
          Width = 175
          Height = 161
          Align = alClient
          DragMode = dmAutomatic
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 428
    Width = 758
    Height = 21
    Align = alBottom
    TabOrder = 3
    object LabelClass: TLabel
      Left = 8
      Top = 2
      Width = 25
      Height = 13
      Caption = 'Class'
    end
  end
  object CodeViewer: TCodeViewer
    Left = 188
    Top = 41
    Width = 382
    Height = 387
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 4
    OnKeyUp = CodeViewerKeyUp
    OnClick = CodeViewerClick
  end
  object PopupWatches: TPopupMenu
    OnPopup = PopupWatchesPopup
    Left = 624
    Top = 168
    object Rename1: TMenuItem
      Caption = '&Rename...'
      OnClick = Rename1Click
    end
    object Value1: TMenuItem
      Caption = '&Value...'
      OnClick = Value1Click
    end
  end
  object PopupTree: TPopupMenu
    OnPopup = PopupTreePopup
    Left = 72
    Top = 200
    object Reverse1: TMenuItem
      Caption = '&Reverse'
      Visible = False
      OnClick = Reverse1Click
    end
    object Breakpoint1: TMenuItem
      Caption = '&Breakpoint'
      OnClick = Breakpoint1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Delete2: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
    end
  end
  object PopupBreakpoints: TPopupMenu
    OnPopup = PopupBreakpointsPopup
    Left = 668
    Top = 112
    object Enabled1: TMenuItem
      Caption = '&Enabled'
      OnClick = Enabled1Click
    end
    object Delete1: TMenuItem
      Caption = '&Delete'
      OnClick = Delete1Click
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 392
    Top = 224
  end
end
