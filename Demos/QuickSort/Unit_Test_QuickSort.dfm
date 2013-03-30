object Form64: TForm64
  Left = 212
  Top = 173
  Width = 311
  Height = 321
  Caption = 'QuickSortForm'
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 66
    Height = 13
    Caption = 'Items to sort:'
  end
  object Button1: TButton
    Left = 112
    Top = 48
    Width = 75
    Height = 25
    Caption = '&Run'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 8
    Top = 32
    Width = 75
    Height = 232
    ItemHeight = 13
    TabOrder = 1
  end
  object Button2: TButton
    Left = 112
    Top = 88
    Width = 75
    Height = 25
    Caption = '&Debug...'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 112
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Randomize'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Runner1: TRunner
    Code = QuickSortCode.QuickSort
    Left = 136
    Top = 136
  end
end
