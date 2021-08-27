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

unit CnTestUsesInitTreeWizard;
{ |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestUsesInitTreeWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�������ʽ
* �޸ļ�¼��2021.08.20 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils,
  CnPasCodeParser, CnWizEditFiler, CnTree, CnCommon;

type

//==============================================================================
// CnTestUsesInitTreeWizard �˵�ר��
//==============================================================================

{ TCnTestUsesInitTreeWizard }

  TCnTestUsesInitTreeWizard = class(TCnMenuWizard)
  private
    FTree: TCnTree;
    FFileNames, FLibPaths: TStringList;
    FDcuPath: string;
    procedure SearchAUnit(const AFullDcuName, AFullSourceName: string; ProcessedFiles: TStrings;
      UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
    {* �ݹ���ã����������� AUnitName ��ӦԴ��� Uses �б������뵽���е� UnitLeaf ���ӽڵ���}
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug, CnDCU32;

const
  csDcuExt = '.dcu';

type
  TCnUsesLeaf = class(TCnLeaf)
  private
    FIsImpl: Boolean;
    FDcuName: string;
    FSearchType: TCnModuleSearchType;
  public
    property DcuName: string read FDcuName write FDcuName;
    property SearchType: TCnModuleSearchType read FSearchType write FSearchType;
    property IsImpl: Boolean read FIsImpl write FIsImpl;
  end;

function GetProjectDcuPath(AProject: IOTAProject): string;
begin
  if (AProject <> nil) and (AProject.ProjectOptions <> nil) then
  begin
    Result := ReplaceToActualPath(AProject.ProjectOptions.Values['UnitOutputDir'], AProject);
    if Result <> '' then
      Result := MakePath(LinkPath(_CnExtractFilePath(AProject.FileName), Result));
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetProjectDcuPath: ' + Result);
  {$ENDIF}
  end
  else
    Result := '';
end;

function GetDcuName(const ADcuPath, ASourceFileName: string): string;
begin
  if ADcuPath = '' then
    Result := _CnChangeFileExt(ASourceFileName, csDcuExt)
  else
    Result := _CnChangeFileExt(ADcuPath + _CnExtractFileName(ASourceFileName), csDcuExt);
end;

//==============================================================================
// CnTestUsesInitTreeWizard �˵�ר��
//==============================================================================

{ TCnTestUsesInitTreeWizard }

procedure TCnTestUsesInitTreeWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestUsesInitTreeWizard.Create;
begin
  inherited;
  FFileNames := TStringList.Create;
  FLibPaths := TStringList.Create;
  FTree := TCnTree.Create(TCnUsesLeaf);
end;

destructor TCnTestUsesInitTreeWizard.Destroy;
begin
  FTree.Free;
  FLibPaths.Free;
  FFileNames.Free;
  inherited;
end;

procedure TCnTestUsesInitTreeWizard.Execute;
var
  Proj: IOTAProject;
  I: Integer;
  ProjDcu, S: string;
begin
  Proj := CnOtaGetCurrentProject;
  if (Proj = nil) or not IsDelphiProject(Proj) then
    Exit;

  FTree.Clear;
  FFileNames.Clear;
  FDcuPath := GetProjectDcuPath(Proj);
  GetLibraryPath(FLibPaths, False);

  CnDebugger.Active := False;
  FTree.Root.Text := CnOtaGetProjectSourceFileName(Proj);
  ProjDcu := GetDcuName(FDcuPath, FTree.Root.Text);

  SearchAUnit(ProjDcu, FTree.Root.Text, FFileNames, FTree.Root, FTree, Proj);
  CnDebugger.Active := True;

  // ��ӡ��������
  for I := 0 to FTree.Count - 1 do
  begin
    S := StringOfChar('-', FTree.Items[I].Level) + FTree.Items[I].Text;

    case (FTree.Items[I] as TCnUsesLeaf).SearchType of
      mstProject: S := S + ' | (In Project)';
      mstProjectSearch: S := S + ' | (In Project Search Path)';
      mstSystemSearch: S := S + ' | (In System Path)';
    end;

    if (FTree.Items[I] as TCnUsesLeaf).IsImpl then
      S := S + ' | impl';

    CnDebugger.LogMsg(S);
  end;
end;

function TCnTestUsesInitTreeWizard.GetCaption: string;
begin
  Result := 'Test Uses Init Tree';
end;

function TCnTestUsesInitTreeWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestUsesInitTreeWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestUsesInitTreeWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestUsesInitTreeWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestUsesInitTreeWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Uses Init Tree Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '';
end;

procedure TCnTestUsesInitTreeWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesInitTreeWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesInitTreeWizard.SearchAUnit(const AFullDcuName, AFullSourceName: string;
  ProcessedFiles: TStrings; UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
var
  St: TCnModuleSearchType;
  ASourceFileName, ADcuFileName: string;
  UsesList: TStringList;
  I, J: Integer;
  Leaf: TCnLeaf;
  Info: TCnUnitUsesInfo;
begin
  // ���� DCU ��Դ��õ� intf �� impl �������б����������� UnitLeaf ��ֱ���ӽڵ�
  // �ݹ���ø÷���������ÿ�������б��е����õ�Ԫ��
  if  not FileExists(AFullDcuName) and not FileExists(AFullSourceName) then
    Exit;

  UsesList := TStringList.Create;
  try
    if FileExists(AFullDcuName) then // �� DCU �ͽ��� DCU
    begin
      Info := TCnUnitUsesInfo.Create(AFullDcuName);
      try
        for I := 0 to Info.IntfUsesCount - 1 do
          UsesList.Add(Info.IntfUses[I]);
        for I := 0 to Info.ImplUsesCount - 1 do
          UsesList.AddObject(Info.ImplUses[I], TObject(True));
      finally
        Info.Free;
      end;
    end
    else // �������Դ��
    begin
      ParseUnitUsesFromFileName(AFullSourceName, UsesList);
    end;

    // UsesList ���õ�������������·�������ҵ�Դ�ļ�������� dcu
    for I := 0 to UsesList.Count - 1 do
    begin
      // �ҵ�Դ�ļ�
      ASourceFileName := GetFileNameSearchTypeFromModuleName(UsesList[I], St, AProject);
      if (ASourceFileName = '') or (ProcessedFiles.IndexOf(ASourceFileName) >= 0) then
        Continue;

      // ���ұ����� dcu�������ڹ������Ŀ¼�Ҳ������ϵͳ�� LibraryPath ��
      ADcuFileName := GetDcuName(FDcuPath, ASourceFileName);
      if not FileExists(ADcuFileName) then
      begin
        // ��ϵͳ�Ķ�� LibraryPath ����
        for J := 0 to FLibPaths.Count - 1 do
        begin
          if FileExists(MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt) then
          begin
            ADcuFileName := MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt;
            Break;
          end;
        end;
      end;

      if not FileExists(ADcuFileName) then
        Continue;

      // ASourceFileName ������δ���������½�һ�� Leaf���ҵ�ǰ Leaf ����
      Leaf := Tree.AddChild(UnitLeaf);
      Leaf.Text := ASourceFileName;
      (Leaf as TCnUsesLeaf).DcuName := ADcuFileName;
      (Leaf as TCnUsesLeaf).SearchType := St;
      (Leaf as TCnUsesLeaf).IsImpl := UsesList.Objects[I] <> nil;

      ProcessedFiles.Add(ASourceFileName);

      SearchAUnit(ADcuFileName, ASourceFileName, ProcessedFiles, Leaf, Tree, AProject);
    end;
  finally
    UsesList.Free;
  end;
end;

initialization
  RegisterCnWizard(TCnTestUsesInitTreeWizard); // ע��˲���ר��

end.