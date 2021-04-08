{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnListCompFrm;
{ |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����������б�����
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXPPro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�������ʽ
* �޸ļ�¼��2018.03.24 V1.1
*               ��������ع�
*           2008.03.17 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, Contnrs,
  {$IFDEF COMPILER6_UP}
  StrUtils, DesignIntf, DesignEditors,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics, ImgList, ActnList, Menus,
  CnPasCodeParser, CnWizIdeUtils, CnWizUtils, CnIni,
  CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizMultiLang, CnWizManager,
  CnProjectViewBaseFrm, CnProjectViewUnitsFrm, CnLangMgr, CnStrings;

type

//==============================================================================
// ���������б�����
//==============================================================================

{ TCnListCompForm }

  TCnListCompForm = class(TCnProjectViewBaseForm)
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure actHookIDEExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  protected
    function DoSelectOpenedItem: string; override;
    procedure OpenSelect; override;
    function GetSelectedFileName: string; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateComboBox; override;
    procedure UpdateStatusBar; override;
    procedure DoLanguageChanged(Sender: TObject); override;

    function SortItemCompare(ASortIndex: Integer; const AMatchStr: string;
      const S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer; override;

    function CanMatchDataByIndex(const AMatchStr: string; AMatchMode: TCnMatchMode;
      DataListIndex: Integer; var StartOffset: Integer; MatchedIndexes: TList): Boolean; override;
  public
    { Public declarations }
  end;

function CnListComponent(Ini: TCustomIniFile): Boolean;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csListComp = 'ListComp';

type
  TCnCompInfo = class(TCnBaseElementInfo)
  private
    FCompClass: string;
    // FCompName: string;
    FCaptionText: string;
    FComponent: TComponent;
    FIsControl: Boolean;
    FIsMenuItem: Boolean;
  public
    // property CompName: string read FCompName write FCompName;
    property CompClass: string read FCompClass write FCompClass;
    property CaptionText: string read FCaptionText write FCaptionText;
    property IsControl: Boolean read FIsControl write FIsControl;
    property IsMenuItem: Boolean read FIsMenuItem write FIsMenuItem;
    property Component: TComponent read FComponent write FComponent;
  end;

  TCnControlHack = class(TControl);

var
  FDestList: IDesignerSelections;
  FSourceList: IDesignerSelections;

function CnListComponent(Ini: TCustomIniFile): Boolean;
var
  FormDesigner: IDesigner;
begin
  Result := False;
  FormDesigner := CnOtaGetFormDesigner;
  if FormDesigner = nil then Exit;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('Root Class: %s', [FormDesigner.GetRootClassName]);
{$ENDIF}

  FSourceList := CreateSelectionList;
  FDestList := CreateSelectionList;
  FormDesigner.GetSelections(FSourceList);

  with TCnListCompForm.Create(nil) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      LoadSettings(Ini, csListComp);

      Result := ShowModal = mrOk;
      SaveSettings(Ini, csListComp);
      if Result then
        FormDesigner.SetSelections(FDestList);
    finally
      FSourceList := nil; // ȷ���ͷŽӿ�
      FDestList := nil;
      Free;
    end;
  end;
end;

//==============================================================================
// ���������б�����
//==============================================================================

{ TCnListCompForm }

procedure TCnListCompForm.CreateList;
var
  I: Integer;
  DesignContainer: TComponent;

  function CompListIndexOf(AComponent: TComponent): Integer;
  var
    I: Integer;
    Info: TCnCompInfo;
  begin
    Result := -1;
    for I := 0 to DataList.Count - 1 do
    begin
      Info := TCnCompInfo(DataList.Objects[I]);
      if Info <> nil then
      begin
        if Info.Component = AComponent then
        begin
          Result := I;
          Exit;
        end;  
      end;  
    end;  
  end;

  // ����һ����Ŀ
  procedure AddItem(AComponent: TComponent; IncludeChildren: Boolean = False);
  var
    I: Integer;
    Info: TCnCompInfo;
  begin
    if CompListIndexOf(AComponent) < 0 then
    begin
      Info := TCnCompInfo.Create;
      Info.Text := AComponent.Name;
      Info.CompClass := AComponent.ClassName;
      Info.Component := AComponent;
      Info.IsControl := AComponent is TControl;
      Info.IsMenuItem := AComponent is TMenuItem;

      if Info.IsControl then
        Info.CaptionText := TCnControlHack(AComponent).Text
      else if Info.IsMenuItem then
        Info.CaptionText := TMenuItem(AComponent).Caption;

      DataList.AddObject(AComponent.Name, Info);

      // �ݹ������ӿؼ�
      if IncludeChildren and (AComponent is TWinControl) then
        for I := 0 to TWinControl(AComponent).ControlCount - 1 do
          AddItem(TWinControl(AComponent).Controls[i], True);
    end;
  end;

begin
  // ��� ComponentSelector
  if CnWizardMgr.WizardByClassName('TCnComponentSelector') = nil then
    btnHookIDE.Visible := False
  else
    actHookIDE.ImageIndex := CnWizardMgr.ImageIndexByClassName('TCnComponentSelector');

  DesignContainer := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
  if DesignContainer <> nil then
  begin
    AddItem(DesignContainer, False);
    for I := 0 to DesignContainer.ComponentCount - 1 do
      AddItem(DesignContainer.Components[I], True);
  end;
end;

function TCnListCompForm.GetHelpTopic: string;
begin
  Result := 'CnAlignSizeConfig';
end;

procedure TCnListCompForm.OpenSelect;
var
  I: Integer;
begin
  if lvList.SelCount > 0 then
  begin
    for I := 0 to lvList.Items.Count - 1 do
    begin
      if lvList.Items[I].Selected and (lvList.Items[I].Data <> nil) then
      begin
        {$IFDEF COMPILER6_UP}
          FDestList.Add(TCnCompInfo(lvList.Items[i].Data).Component);
        {$ELSE}
          FDestList.Add(MakeIPersistent(TCnCompInfo(lvList.Items[i].Data).Component));
        {$ENDIF}
      end;
    end;

    ModalResult := mrOK;
  end;
end;

procedure TCnListCompForm.UpdateStatusBar;
begin
  StatusBar.Panels[1].Text := Format(SCnListComponentCount, [DisplayList.Count]);
end;

procedure TCnListCompForm.lvListData(Sender: TObject;
  Item: TListItem);
var
  Info: TCnCompInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnCompInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
    if Info.IsControl then
      Item.ImageIndex := 67
    else if Info.IsMenuItem then
      Item.ImageIndex := 93
    else
      Item.ImageIndex := 90; // �ݲ��ܾ�ȷ�������ͼ��

    Item.SubItems.Add(Info.CompClass);
    Item.SubItems.Add(Info.CaptionText);
    RemoveListViewSubImages(Item);
    Item.Data := Info;
  end;
end;

procedure TCnListCompForm.UpdateComboBox;
begin
// Do nothing for Combo Hidden.
end;

function TCnListCompForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
end;

function TCnListCompForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(lvList.ItemFocused.Caption);
end;

procedure TCnListCompForm.DoLanguageChanged(Sender: TObject);
begin
  try
    ToolBar.ShowCaptions := True;
    ToolBar.ShowCaptions := False;
  except
    ;
  end;
end;

procedure TCnListCompForm.actHookIDEExecute(Sender: TObject);
begin
  if CnWizardMgr.WizardByClassName('TCnComponentSelector') <> nil then
  begin
    ModalResult := mrNone;
    Hide;
    CnWizardMgr.WizardByClassName('TCnComponentSelector').Execute;
    Close;
  end;
end;

procedure TCnListCompForm.FormShow(Sender: TObject);
begin
  inherited;
  actHookIDE.Checked := False;
end;

function TCnListCompForm.CanMatchDataByIndex(const AMatchStr: string;
  AMatchMode: TCnMatchMode; DataListIndex: Integer; var StartOffset: Integer;
  MatchedIndexes: TList): Boolean;
var
  Info: TCnCompInfo;
  UpperMatch: string;
begin
  Result := False;
  if AMatchStr = '' then
  begin
    Result := True;
    Exit;
  end;

  Info := TCnCompInfo(DataList.Objects[DataListIndex]);
  if Info = nil then
    Exit;

  if AMatchMode in [mmStart, mmAnywhere] then
    UpperMatch := UpperCase(AMatchStr);

  case AMatchMode of // ����ʱ���ж�����ƥ�䣬�����ִ�Сд
    mmStart:
      begin
        Result := (Pos(UpperMatch, UpperCase(DataList[DataListIndex])) = 1)
          or (Pos(UpperMatch, UpperCase(Info.CompClass)) = 1)
          or (Pos(UpperMatch, UpperCase(Info.CompClass)) = 1);
      end;
    mmAnywhere:
      begin
        Result := (Pos(UpperMatch, UpperCase(DataList[DataListIndex])) > 0)
          or (Pos(UpperMatch, UpperCase(Info.CompClass)) > 0)
          or (Pos(UpperMatch, UpperCase(Info.CaptionText)) > 0);
      end;
    mmFuzzy:
      begin
        Result := FuzzyMatchStr(AMatchStr, DataList[DataListIndex], MatchedIndexes)
          or FuzzyMatchStr(AMatchStr, Info.CompClass)
          or FuzzyMatchStr(AMatchStr, Info.CaptionText);
      end;
  end;
end;

function TCnListCompForm.SortItemCompare(ASortIndex: Integer;
  const AMatchStr, S1, S2: string; Obj1, Obj2: TObject; SortDown: Boolean): Integer;
var
  Info1, Info2: TCnCompInfo;
begin
  Info1 := TCnCompInfo(Obj1);
  Info2 := TCnCompInfo(Obj2);

  case ASortIndex of // ��Ϊ����ʱ���ж�����ƥ�䣬�������ʱҲҪ���ǵ���ȫƥ����ǰ
    0:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.Text, Info2.Text, SortDown);
      end;
    1:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.CompClass, Info2.CompClass, SortDown);
      end;
    2:
      begin
        Result := CompareTextWithPos(AMatchStr, Info1.CaptionText, Info2.CaptionText, SortDown);
      end;
  else
    Result := 0;
  end;
end;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}
end.