object MainForm: TMainForm
  Left = 80
  Top = 71
  Width = 1036
  Height = 729
  Caption = 'CnPack IDE 专家包 Object Pascal / Delphi 代码格式化测试程序'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1028
    Height = 702
    ActivePage = tsSingleTest
    Align = alClient
    TabOrder = 0
    object tsSingleTest: TTabSheet
      Caption = '代码格式化测试'
      object Splitter1: TSplitter
        Left = 505
        Top = 29
        Width = 3
        Height = 646
        Cursor = crHSplit
      end
      object Panel1: TPanel
        Left = 0
        Top = 29
        Width = 505
        Height = 646
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel1'
        TabOrder = 1
        object Label1: TLabel
          Left = 0
          Top = 0
          Width = 505
          Height = 12
          Align = alTop
          Alignment = taCenter
          Caption = '无标题'
          Layout = tlCenter
        end
        object SrcMemo: TMemo
          Left = 0
          Top = 12
          Width = 505
          Height = 634
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          Lines.Strings = (
            
              '{***************************************************************' +
              '***************}'
            
              '{                       CnPack For Delphi/C++Builder            ' +
              '               }'
            
              '{                     中国人自己的开放源码第三方开发包          ' +
              '               }'
            
              '{                   (C)Copyright 2001-2015 CnPack 开发组        ' +
              '               }    '
            
              '{                   ------------------------------------        ' +
              '               }'
            
              '{***************************************************************' +
              '***************}'
            'unit CnCodeFormaterTest;'
            '{* |<PRE>'
            
              '================================================================' +
              '================'
            '* 软件名称：CnPack 代码格式化专家'
            '* 单元名称：格式化专家测试程序 CnCodeFormaterTest'
            '* 单元作者：CnPack开发组'
            
              '================================================================' +
              '================'
            '|</PRE>}'
            ''
            'interface// HERE is a comment'
            '{I CnPack.inc}'
            'uses'
            
              '  Classes, SysUtils{$IFDEF DEBUG},CnDebug{$ELSE},  NDebug{$ENDIF' +
              '};'
            'const'
            '[unsafe]'
            '  PathDelim  = {$IFDEF MSWINDOWS} '#39'\'#39'; {$ELSE} '#39'/'#39'; {$ENDIF}'
            'implementation'
            'procedure Test;'
            'begin'
            '  // Do nothing'
            'end;'
            'type [SecurityPermission(False), SecurityPermission('#39#39')]'
            'TWMTest=class'
            'private class threadvar'
            '    [Unsafe] FCurrentThread: TThread;'
            '  public type [unsafe]'
            '    TSystemTimes = record'
            '      IdleTime, UserTime, KernelTime, NiceTime: UInt64;'
            '    end;'
            'end;'
            'threadvar'
            '[unsafe]'
            '  SafeCallExceptionMsg: string;'
            '  SafeCallExceptionAddr: Pointer;'
            ''
            '[SecurityPermission(SecurityAction.Assert, UnmanagedCode=True)]'
            
              'function TGraphic.DefineProperties(Filer: TFiler;[Ref] const Buf' +
              'fer): TObject;'
            'begin'
            'while I<Count do begin end;'
            '  Result :=  TFiler<TList<String, TObject>>.Create;'
            'end;'
            'end.')
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
      object Panel2: TPanel
        Left = 508
        Top = 29
        Width = 512
        Height = 646
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel1'
        TabOrder = 2
        object Label2: TLabel
          Left = 0
          Top = 0
          Width = 512
          Height = 12
          Align = alTop
          Alignment = taCenter
          Caption = '格式化结果'
          Layout = tlCenter
        end
        object DesMemo: TMemo
          Left = 0
          Top = 12
          Width = 512
          Height = 634
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 1020
        Height = 29
        BorderWidth = 1
        ButtonHeight = 20
        ButtonWidth = 55
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        Flat = True
        ShowCaptions = True
        TabOrder = 0
        object btnLoadFile: TToolButton
          Left = 0
          Top = 0
          Caption = '打开文件'
          ImageIndex = 1
          OnClick = btnLoadFileClick
        end
        object ToolButton3: TToolButton
          Left = 55
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 1
          Style = tbsSeparator
        end
        object btnFormat: TToolButton
          Left = 63
          Top = 0
          Caption = '格式化！'
          ImageIndex = 0
          OnClick = btnFormatClick
        end
        object btnSep1: TToolButton
          Left = 118
          Top = 0
          Width = 8
          Caption = 'btnSep1'
          ImageIndex = 1
          Style = tbsSeparator
        end
        object lbl1: TLabel
          Left = 126
          Top = 0
          Width = 6
          Height = 20
        end
        object Label3: TLabel
          Left = 132
          Top = 0
          Width = 60
          Height = 20
          Alignment = taRightJustify
          Caption = '缩进空格数'
          Layout = tlCenter
        end
        object Edit1: TEdit
          Left = 192
          Top = 0
          Width = 25
          Height = 20
          TabOrder = 0
          Text = '2'
        end
        object UpDown1: TUpDown
          Left = 217
          Top = 0
          Width = 15
          Height = 20
          Associate = Edit1
          Min = 0
          Position = 2
          TabOrder = 1
          Visible = False
          Wrap = False
        end
        object btnSep2: TToolButton
          Left = 232
          Top = 0
          Width = 8
          Caption = 'btnSep2'
          ImageIndex = 2
          Style = tbsSeparator
        end
        object Label4: TLabel
          Left = 240
          Top = 0
          Width = 48
          Height = 20
          Alignment = taRightJustify
          AutoSize = False
          Caption = '关键字'
          Layout = tlCenter
        end
        object ComboBox1: TComboBox
          Left = 288
          Top = 0
          Width = 112
          Height = 20
          Style = csDropDownList
          ItemHeight = 12
          TabOrder = 2
          Items.Strings = (
            '小写'
            '大写'
            '首字母大写')
        end
        object btn1: TToolButton
          Left = 400
          Top = 0
          Width = 8
          Caption = 'btn1'
          ImageIndex = 3
          Style = tbsSeparator
        end
        object ToolButton1: TToolButton
          Left = 408
          Top = 0
          Caption = '保存结果'
          ImageIndex = 2
          OnClick = ToolButton1Click
        end
      end
    end
    object tsMultiTest: TTabSheet
      Caption = '批量测试'
      ImageIndex = 2
      object dirlst1: TDirectoryListBox
        Left = 0
        Top = 24
        Width = 181
        Height = 647
        Anchors = [akLeft, akTop, akBottom]
        FileList = fllst1
        ItemHeight = 16
        TabOrder = 3
      end
      object fllst1: TFileListBox
        Left = 184
        Top = 40
        Width = 177
        Height = 647
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 12
        Mask = '*.pas'
        MultiSelect = True
        TabOrder = 5
        OnDblClick = btnAddClick
      end
      object fltcbb1: TFilterComboBox
        Left = 184
        Top = 0
        Width = 177
        Height = 20
        FileList = fllst1
        Filter = 'Pascal Source File (*.pas)|*.pas'
        TabOrder = 1
        OnChange = fltcbb1Change
      end
      object drvcbb1: TDriveComboBox
        Left = 0
        Top = 0
        Width = 181
        Height = 18
        DirList = dirlst1
        TabOrder = 0
      end
      object lvTestFiles: TListView
        Left = 400
        Top = 0
        Width = 670
        Height = 672
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = '文件名'
            Width = 150
          end
          item
            Caption = '测试结果'
            Width = 150
          end>
        ColumnClick = False
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 2
        ViewStyle = vsReport
        OnDblClick = btnSingleTestClick
      end
      object btnAdd: TButton
        Left = 368
        Top = 24
        Width = 25
        Height = 25
        Caption = '>'
        TabOrder = 4
        OnClick = btnAddClick
      end
      object btnAddAll: TButton
        Left = 368
        Top = 56
        Width = 25
        Height = 25
        Caption = '>>'
        TabOrder = 6
        OnClick = btnAddAllClick
      end
      object btnRemove: TButton
        Left = 368
        Top = 88
        Width = 25
        Height = 25
        Caption = '-'
        TabOrder = 7
        OnClick = btnRemoveClick
      end
      object btnRemoveAll: TButton
        Left = 368
        Top = 120
        Width = 25
        Height = 25
        Caption = 'C'
        TabOrder = 8
        OnClick = btnRemoveAllClick
      end
      object btnGo: TButton
        Left = 368
        Top = 184
        Width = 25
        Height = 25
        Caption = 'GO'
        TabOrder = 9
        OnClick = btnGoClick
      end
      object btnSingleTest: TButton
        Left = 368
        Top = 216
        Width = 25
        Height = 25
        Caption = '?'
        TabOrder = 10
        OnClick = btnSingleTestClick
      end
    end
    object tsScanerTest: TTabSheet
      Caption = '词法分析器测试'
      ImageIndex = 1
      object Splitter2: TSplitter
        Left = 393
        Top = 29
        Width = 3
        Height = 646
        Cursor = crHSplit
      end
      object Panel4: TPanel
        Left = 0
        Top = 29
        Width = 393
        Height = 646
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel1'
        TabOrder = 1
        object Label5: TLabel
          Left = 0
          Top = 0
          Width = 36
          Height = 12
          Align = alTop
          Alignment = taCenter
          Caption = 'Source'
          Layout = tlCenter
        end
        object Memo1: TMemo
          Left = 0
          Top = 12
          Width = 393
          Height = 634
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          WantReturns = False
          WordWrap = False
        end
      end
      object Panel5: TPanel
        Left = 396
        Top = 29
        Width = 675
        Height = 646
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel1'
        TabOrder = 2
        object Label6: TLabel
          Left = 0
          Top = 0
          Width = 36
          Height = 12
          Align = alTop
          Alignment = taCenter
          Caption = 'Target'
          Layout = tlCenter
        end
        object Memo2: TMemo
          Left = 0
          Top = 12
          Width = 675
          Height = 634
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          WantReturns = False
          WordWrap = False
        end
      end
      object ToolBar2: TToolBar
        Left = 0
        Top = 0
        Width = 1071
        Height = 29
        BorderWidth = 1
        ButtonHeight = 20
        ButtonWidth = 85
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        Flat = True
        ShowCaptions = True
        TabOrder = 0
        object ToolButton4: TToolButton
          Left = 0
          Top = 0
          Caption = '打开文件'
          ImageIndex = 1
          OnClick = ToolButton4Click
        end
        object ToolButton5: TToolButton
          Left = 85
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 1
          Style = tbsSeparator
        end
        object ToolButton7: TToolButton
          Left = 93
          Top = 0
          Caption = '测试 Bookmark'
          ImageIndex = 1
          OnClick = ToolButton7Click
        end
      end
    end
  end
  object OpenDialog: TOpenDialog
    Top = 21
  end
  object SaveDialog1: TSaveDialog
    Left = 492
    Top = 23
  end
end
