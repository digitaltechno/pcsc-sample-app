object MainForm: TMainForm
  Left = 331
  Top = 85
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  Caption = 'PC/SC Sample Application V1.0'
  ClientHeight = 545
  ClientWidth = 634
  Color = clBtnFace
  Constraints.MaxWidth = 650
  Constraints.MinHeight = 200
  Constraints.MinWidth = 650
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 113
    Width = 634
    Height = 8
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    MinSize = 100
    ResizeStyle = rsUpdate
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 634
    Height = 113
    Align = alTop
    BevelOuter = bvNone
    Constraints.MinHeight = 70
    ParentBackground = False
    TabOrder = 0
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 634
      Height = 21
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 3
        Width = 76
        Height = 13
        Caption = 'Card Readers'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object ReaderListBox: TListBox
      Left = 0
      Top = 21
      Width = 634
      Height = 92
      Style = lbOwnerDrawFixed
      Align = alClient
      BevelKind = bkFlat
      BorderStyle = bsNone
      ItemHeight = 30
      TabOrder = 1
      OnClick = ReaderListBoxClick
      OnDrawItem = ReaderListBoxDrawItem
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 121
    Width = 634
    Height = 424
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object RichEdit: TRichEdit
      Left = 0
      Top = 209
      Width = 634
      Height = 196
      Align = alClient
      BevelKind = bkFlat
      BorderStyle = bsNone
      Constraints.MinHeight = 50
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 634
      Height = 209
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object Label2: TLabel
        Left = 8
        Top = 186
        Width = 79
        Height = 13
        Caption = 'Log Messages'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label3: TLabel
        Left = 32
        Top = 127
        Width = 51
        Height = 13
        Caption = 'Command:'
      end
      object Bevel1: TBevel
        Left = 8
        Top = 183
        Width = 625
        Height = 2
      end
      object Label4: TLabel
        Left = 15
        Top = 43
        Width = 64
        Height = 13
        Caption = 'Block Number'
      end
      object Label5: TLabel
        Left = 16
        Top = 152
        Width = 71
        Height = 13
        Caption = 'Data To Write:'
      end
      object Label6: TLabel
        Left = 32
        Top = 69
        Width = 48
        Height = 13
        Caption = 'Auth Key:'
      end
      object ConnectSharedButton: TButton
        Left = 88
        Top = 8
        Width = 129
        Height = 25
        Caption = 'Connect card shared'
        Enabled = False
        TabOrder = 0
        OnClick = ConnectSharedButtonClick
      end
      object ConnectExclusiveButton: TButton
        Left = 224
        Top = 8
        Width = 129
        Height = 25
        Caption = 'Connect card exclusive'
        Enabled = False
        TabOrder = 1
        OnClick = ConnectExclusiveButtonClick
      end
      object DisconnectButton: TButton
        Left = 360
        Top = 8
        Width = 129
        Height = 25
        Caption = 'Disconnect card'
        Enabled = False
        TabOrder = 2
        OnClick = DisconnectButtonClick
      end
      object CommandComboBox: TComboBox
        Left = 88
        Top = 124
        Width = 401
        Height = 21
        ItemHeight = 13
        MaxLength = 260
        TabOrder = 3
        OnChange = CommandComboBoxChange
        OnEnter = CommandComboBoxEnter
        OnKeyDown = CommandComboBoxKeyDown
        OnKeyPress = CommandComboBoxKeyPress
        Items.Strings = (
          'FF CA 00 00 00'
          'FF 00 68 00 01 41')
      end
      object TransmitButton: TButton
        Left = 496
        Top = 122
        Width = 129
        Height = 25
        Caption = 'Transmit command'
        TabOrder = 4
        OnClick = TransmitButtonClick
      end
      object btnRead: TButton
        Left = 173
        Top = 93
        Width = 75
        Height = 25
        Caption = 'Read'
        TabOrder = 5
        OnClick = btnReadClick
      end
      object btnAuth: TButton
        Left = 89
        Top = 93
        Width = 75
        Height = 25
        Caption = 'Auth'
        TabOrder = 6
        OnClick = btnAuthClick
      end
      object auth_block: TEdit
        Left = 88
        Top = 40
        Width = 97
        Height = 21
        TabOrder = 7
        Text = '5'
      end
      object btnUID: TButton
        Left = 255
        Top = 93
        Width = 75
        Height = 25
        Caption = 'UID'
        TabOrder = 8
        OnClick = btnUIDClick
      end
      object btnWrite: TButton
        Left = 496
        Top = 148
        Width = 129
        Height = 25
        Caption = 'Write'
        TabOrder = 9
        OnClick = btnWriteClick
      end
      object edWrite: TEdit
        Left = 88
        Top = 151
        Width = 401
        Height = 21
        TabOrder = 10
      end
      object auth_key: TEdit
        Left = 88
        Top = 64
        Width = 97
        Height = 21
        CharCase = ecUpperCase
        MaxLength = 12
        TabOrder = 11
        Text = 'FFFFFFFFFFFF'
      end
      object RadioGroup1: TRadioGroup
        Tag = 96
        Left = 192
        Top = 35
        Width = 137
        Height = 49
        Caption = 'Auth Mode'
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          'Key A'
          'Key B')
        TabOrder = 12
        OnClick = RadioGroup1Click
      end
      object Button2: TButton
        Left = 528
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Button2'
        TabOrder = 13
        OnClick = Button2Click
      end
      object Button1: TButton
        Left = 336
        Top = 65
        Width = 77
        Height = 25
        Caption = 'Test'
        TabOrder = 14
        OnClick = Button1Click
      end
      object MarqueeButton: TButton
        Left = 413
        Top = 65
        Width = 76
        Height = 25
        Caption = 'Marquee'
        TabOrder = 15
        OnClick = MarqueeButtonClick
      end
      object ConnectDirectButton: TButton
        Left = 336
        Top = 40
        Width = 153
        Height = 25
        Caption = 'Connect direct to reader '
        Enabled = False
        TabOrder = 16
        OnClick = ConnectDirectButtonClick
      end
      object Button3: TButton
        Left = 336
        Top = 90
        Width = 153
        Height = 25
        Caption = 'Transfer Event Sample'
        TabOrder = 17
        OnClick = Button3Click
      end
    end
    object StatusBar1: TStatusBar
      Left = 0
      Top = 405
      Width = 634
      Height = 19
      Panels = <>
      SimplePanel = True
      SimpleText = '(C) 2008 SCM Microsystems Inc.'
    end
  end
  object XPManifest1: TXPManifest
    Left = 392
    Top = 65528
  end
end
