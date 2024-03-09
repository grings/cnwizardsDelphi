{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
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

unit CnInputIdeSymbolList;
{* |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��������� IDE �����б��ඨ�嵥Ԫ
* ��Ԫ���ߣ�Johnson Zhong zhongs@tom.com http://www.longator.com
*           �ܾ��� zjy@cnpack.org
* ��    ע��IDE ��ʶ���б���
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�������ʽ
* �޸ļ�¼��2022.04.02
*               ����֧�� LSP ���첽���Ż�ȡ
*           2005.06.03
*               �� CnInputHelper �з������
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
  Windows, SysUtils, Classes, Controls, ToolsApi, Math, Dialogs, Contnrs, TypInfo,
  Forms, CnHashMap, CnCommon, CnWizConsts, CnWizCompilerConst, CnWizUtils, CnWizMethodHook,
  CnPasCodeParser, CnInputSymbolList, CnEditControlWrapper, CnWizNotifier;

{$IFDEF DELPHI}
  {$DEFINE SUPPORT_IDESYMBOLLIST}
{$ENDIF}

{$IFDEF SUPPORT_IDESYMBOLLIST}
{$IFDEF COMPILER7_UP}
  {$DEFINE SUPPORT_IOTACodeInsightManager}  // D7 ������֧�� IOTACodeInsightManager
{$ENDIF}

{$IFNDEF COMPILER8_UP}
  {$DEFINE SUPPORT_KibitzCompile}           // D567 ֧�� KibitzCompile
{$ENDIF}

{$IFDEF SUPPORT_IOTACodeInsightManager}
  {$IFDEF SUPPORT_KibitzCompile}
    {$DEFINE SUPPORT_MULTI_IDESymbolList}   // D7 ����֧��
  {$ENDIF}
{$ENDIF}

{$ENDIF SUPPORT_IDESYMBOLLIST}

{$IFDEF IDE_WIDECONTROL}
  {$IFNDEF UNICODE_STRING}
    {$DEFINE UTF8_SYMBOL}  // D2005/2006/2007 �� Symbol �� Utf8
  {$ENDIF}
{$ENDIF}

{$IFDEF BDS4_UP}
  // BDS 2006 ��ִ�� IOTACodeInsightServices.SetQueryContext(nil, nil)
  // ���ٵ����Զ���ɻᵼ�� IDE �쳣
  {$DEFINE IDE_SetQueryContext_Bug}
{$ENDIF}

{$IFDEF DELPHI2007_UP}
  {$DEFINE SYMBOL_LOCKHOOK}
{$ENDIF}

{$IFDEF IDE_SUPPORT_LSP}
  {$UNDEF SYMBOL_LOCKHOOK}
{$ENDIF}

type

//==============================================================================
// �� IDE �л�õı�ʶ���б�
//==============================================================================

{ TIDESymbolList }

  TIDESymbolList = class(TSymbolList)
  private
  {$IFDEF IDE_SUPPORT_LSP}
     FKeepUnique: Boolean; // Name �Ƿ���ظ�
     FHashList: TCnStrToStrHashMap;
     FAsyncResultGot: Boolean;
     FAsyncManagerObj: TObject;
     FAsyncIsPascal: Boolean;
     procedure AsyncCodeCompletionCallBack(Sender: TObject; AId: Integer;
       AError: Boolean; const AMessage: string);
  {$ENDIF}
  {$IFDEF SUPPORT_IOTACodeInsightManager}
    function Reload_CodeInsightManager(Editor: IOTAEditBuffer;
      const InputText: string; PosInfo: TCodePosInfo): Boolean;
  {$ENDIF SUPPORT_IOTACodeInsightManager}
  {$IFDEF SUPPORT_KibitzCompile}
    procedure OnFileNotify(NotifyCode: TOTAFileNotification; const FileName: string);
    procedure OnIdleExecute(Sender: TObject);
    function Reload_KibitzCompile(Editor: IOTAEditBuffer;
      const InputText: string; PosInfo: TCodePosInfo): Boolean;
  {$ENDIF SUPPORT_KibitzCompile}
  public
    constructor Create; override;
    destructor Destroy; override;

    class function GetListName: string; override;
    function Reload(Editor: IOTAEditBuffer; const InputText: string; PosInfo:
      TCodePosInfo): Boolean; override;

    // ������������ LSP ģʽ�»������ش�����ע�� Add(Item: TSymbolItem) δ��
    function Add(const AName: string; AKind: TSymbolKind; AScope: Integer; const
      ADescription: string = ''; const AText: string = ''; AAutoIndent: Boolean = 
      True; AMatchFirstOnly: Boolean = False; AAlwaysDisp: Boolean = False;
      ADescIsUtf8: Boolean = False): Integer; overload; override;
    procedure Clear; override;
  end;

const
{$IFDEF SUPPORT_MULTI_IDESymbolList}
  SupportMultiIDESymbolList = True;
{$ELSE}
  SupportMultiIDESymbolList = False;
{$ENDIF}

{$IFDEF SUPPORT_KibitzCompile}
  SupportKibitzCompile = True;
{$ELSE}
  SupportKibitzCompile = False;
{$ENDIF}

{$IFDEF DELPHI5}
  SupportKibitzCompileThread = True;
{$ELSE}
  SupportKibitzCompileThread = False;
{$ENDIF}

var
  UseCodeInsightMgr: Boolean = False;
  {* �� D7 ���Ƿ�ʹ�ü����ԽϺõķ�ʽȡ�÷����б�������}
  UseKibitzCompileThread: Boolean = False;
  {* �Ƿ�ʹ�ú�̨�߳�Ԥ�������� }

function KibitzCompileThreadRunning: Boolean;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizEditFiler, mPasLex;

const
  csCIMgrNames = ';pascal;';

{$IFDEF IDE_SUPPORT_LSP}
const
  HashSize = 4096;
  SDelphiLspGetCount = '@Lspcodcmplt@TLSPKibitzManager@GetCount$qqrv';
  SDelphiLspGetCodeCompEntry = '@Lspcodcmplt@TLSPKibitzManager@GetCodeCompEntry$qqri';

  SBcbLspGetCount = '@Cppcodcmplt2@TCppKibitzManager2@GetCount$qqrv';
  SBcbLspGetCodeCompEntry = '@Cppcodcmplt2@TCppKibitzManager2@GetCodeCompEntry$qqri';

type
  TDelphiLSPKibitzManagerGetCount = function (ASelf: TObject): Integer;
  TBcbLSPKibitzManagerGetCount = function (ASelf: TObject): Integer;

  TDelphiLSPKibitzManagerGetCodeCompEntry = function (ASelf: TObject; Index: Integer): Pointer;
  TBcbLSPKibitzManagerGetCodeCompEntry = function (ASelf: TObject; Index: Integer): Pointer;

  TCnDelphiLspCodeCompEntry = packed record
  {* �����������LSPKibitzManager ÿһ����һ���ṹ��һ���ṹ�� 12 �����ֽ�����}
    SymbolName: PChar;            // ����
    SymbolFlag: LongWord;
    SymbolType: PChar;            // �����ַ������� method ��
    SymbolTypeFlag: LongWord;
    SymbolParam: PChar;           // �����ַ�������ǰ���ò��ŵ�
    SymbolDummy6: LongWord;
    SymbolDummy7: LongWord;
    SymbolDummy8: LongWord;
    SymbolDummy9: LongWord;
    SymbolDummy10: LongWord;
    SymbolDummy11: LongWord;
    SymbolDummy12: PChar;
  end;
  PCnDelphiLspCodeCompEntry = ^TCnDelphiLspCodeCompEntry;

  TCnBcbLspCodeCompEntry = packed record
  {* �����������CppKibitzManager2 ÿһ����һ���ṹ��һ���ṹ�� 7 �����ֽ�����}
    SymbolName: PAnsiChar;        // ����
    SymbolLength: LongWord;       // ���Ƴ���
    SymbolTypeFlag: LongWord;
    SymbolParam: PAnsiChar;       // �����ַ���
    SymbolParamLength: LongWord;  // �����ַ�������
    SymbolDummy6: PAnsiChar;
  end;
  PCnBcbLspCodeCompEntry = ^TCnBcbLspCodeCompEntry;

var
  FDelphiLspHandle: THandle = 0;
  FBcbLspHandle: THandle = 0;

  DelphiLspGetCount: TDelphiLSPKibitzManagerGetCount = nil;
  DelphiLspGetCodeCompEntry: TDelphiLSPKibitzManagerGetCodeCompEntry = nil;

  BcbLspGetCount: TBcbLSPKibitzManagerGetCount = nil;
  BcbLspGetCodeCompEntry: TBcbLSPKibitzManagerGetCodeCompEntry = nil;
{$ENDIF}

//==============================================================================
// �� IDE �л�õı�ʶ���б�
//==============================================================================

{ TIDESymbolList }

{$IFDEF SUPPORT_IOTACodeInsightManager}

const
  ComtypesLockName = '@Comtypes@Lock$qqsv';
  ComtypesUnLockName = '@Comtypes@UnLock$qqsv';

function MyMessageDlgPosHelp(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer;
  const HelpFileName: string): Integer;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('MyMessageDlgPosHelp called');
{$ENDIF Debug}
  Result := mrOk;
end;

{$IFDEF SYMBOL_LOCKHOOK}
type
  TComtypesLockProc = procedure; stdcall;

var
  DphIdeModule1: HMODULE;
  LockHook: TCnMethodHook;
  UnLockHook: TCnMethodHook;
  ComtypesLock: TComtypesLockProc;
  ComtypesUnLock: TComtypesLockProc;

procedure MyComtypesUnLock; stdcall;
begin
end;

procedure MyComtypesLock; stdcall;
begin
end;
{$ENDIF SYMBOL_LOCKHOOK}

{$IFDEF IDE_SUPPORT_LSP}

function SymbolClassTextToKind(const ClassText: string): TSymbolKind;
begin
  Result := skUnknown;
  if Length(ClassText) >= 3 then
  begin
    case Ord(ClassText[1]) of
      107: // k eyword
        Result := skKeyword;
      114, 115: // r eference / s truct
        Result := skType;
      118: // v ariable
        Result := skVariable;
      102: // f unction / fi le / fi eld
        begin
          if ClassText[2] = 'u' then
            Result := skFunction
          else if ClassText[3] = 'l' then
            Result := skUnit
          else
            Result := skVariable; // Field
        end;
      109: // m ethod
        Result := skFunction;
      112: // p roperty
        Result := skProperty;
      105: // i nterface
        Result := skInterface;
      99:  // c lass / const ant / const ructor
        begin
          if ClassText[2] = 'l' then
            Result := skClass
          else if Length(ClassText) >= 6 then
          begin
            if ClassText[6] = 'a' then
              Result := skConstant
            else
              Result := skConstructor;
          end;
        end;
      101: // e vent / e num / e numM
        begin
          if ClassText[2] = 'v' then
            Result := skEvent
          else
            Result := skConstant;
        end;
    end;
  end;
end;

procedure TIDESymbolList.AsyncCodeCompletionCallBack(Sender: TObject; AId: Integer;
  AError: Boolean; const AMessage: string);
var
  I, C, Idx: Integer;
  SName, SDesc, S3: string;
  PasEntry: PCnDelphiLspCodeCompEntry;
  CppEntry: PCnBcbLspCodeCompEntry;

  function ExtractStr(CppPtr: PAnsiChar; Len: Integer): string;
  const
    MAX_LEN = 128;
  var
    S: AnsiString;
  begin
    // �� CppStr ɨ�� " �ţ���ǰ����ó�������Ϊ string
    Result := '';
    if (CppPtr = nil) or (Len <= 0) then
      Exit;

    if Len > MAX_LEN then
      Len := MAX_LEN;

    SetLength(S, Len);
    Move(CppPtr^, S[1], Len);
    Result := string(S);
  end;

  function CppTypeToKind(V: Integer; const SName: string): TSymbolKind;
  begin
    case V of
      1: Result := skKeyword;
      2,3: Result := skFunction; // method & global function
      4:
        begin
          if SName[1] = '~' then
            Result := skDestructor
          else
            Result := skConstructor
        end;
      5: Result := skVariable;
      6: Result := skConstant;
      7: Result := skType;
      8: Result := skConstant;
      9: Result := skUnit;
      10: Result := skProperty;
      13,20: Result := skConstant; // enum
      22: Result := skType;
    else
      Result := skUnknown;
    end;
  end;

begin
  try
    if not Assigned(FAsyncManagerObj) then
      Exit;

    if FAsyncIsPascal then
    begin
      if Assigned(DelphiLspGetCount) and Assigned(DelphiLspGetCodeCompEntry) then
      begin
        // Delphi �� FAsyncManagerObj �ƺ��Ǹ� TLSPKibitzManager ʵ��������������ø�����Ԫ��
        C := DelphiLspGetCount(FAsyncManagerObj);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Callback DelphiLspGetCount %s Returns Count %d',
          [FAsyncManagerObj.ClassName, C]);
{$ENDIF}

        if C <= 0 then
          Exit;

        for I := 0 to C - 1 do
        begin
          PasEntry := DelphiLspGetCodeCompEntry(FAsyncManagerObj, I);
          if (PasEntry <> nil) and (PasEntry^.SymbolName <> nil) then
          begin
            Idx := Add(PasEntry^.SymbolName, SymbolClassTextToKind(PasEntry^.SymbolType),
              Round(MaxInt / C * I), PasEntry^.SymbolParam, '', True, False, False, False);

            // ����Դ�ļ����������÷���������÷�Χ
            if Idx >= 0 then
            begin
              Items[Idx].ForPascal := True;
              Items[Idx].ForCpp := False;
            end;
          end;
        end;
      end;
    end
    else
    begin
      // BCB �£�FAsyncManagerObj ��һ�� TCppKibitzManager2 ʵ����������ʽ��ȫ��ͬ
      if Assigned(BcbLspGetCount) and Assigned(BcbLspGetCodeCompEntry) then
      begin
        C := BcbLspGetCount(FAsyncManagerObj);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Callback BcbLspGetCount %s Returns Count %d',
          [FAsyncManagerObj.ClassName, C]);
{$ENDIF}

        if C <= 0 then
          Exit;

        for I := 0 to C - 1 do
        begin
          CppEntry := BcbLspGetCodeCompEntry(FAsyncManagerObj, I);
          if (CppEntry <> nil) and (CppEntry^.SymbolName <> nil) then
          begin;
            SName := ExtractStr(CppEntry^.SymbolName, CppEntry^.SymbolLength);
            if SName = '' then
              Continue;

            SDesc := ExtractStr(CppEntry^.SymbolParam, CppEntry^.SymbolParamLength);
            Idx := Add(SName, CppTypeToKind(CppEntry^.SymbolTypeFlag, SName),
              Round(MaxInt / C * I), SDesc, '', True, False, False, False);

            // ����Դ�ļ����������÷���������÷�Χ
            if Idx >= 0 then
            begin
              Items[Idx].ForPascal := False;
              Items[Idx].ForCpp := True;
            end;
          end;
        end;
      end;
    end;
  finally
    FAsyncResultGot := True; // ���ŷţ��Ƚϱ���
  end;
end;

{$ENDIF}

// Invoke delphi code completion, load symbol list
function TIDESymbolList.Reload_CodeInsightManager(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
var
  CodeInsightServices: IOTACodeInsightServices;
  CodeInsightManager: IOTACodeInsightManager;
  EditView: IOTAEditView;
  Element, LineFlag: Integer;
  Index: Integer;

  function SymbolFlagsToKind(Flags: TOTAViewerSymbolFlags; const Description: string):
    TSymbolKind;
  begin
    Result := TSymbolKind(Flags);
    if (Flags = vsfType) then
    begin
      if Copy(Description, 1, 8) = ' : class' then
        Result := skClass;
      if Copy(Description, 1, 12) = ' : interface' then
        Result := skInterface;
    end;
  end;

  function MyInvokeCodeCompletion(Manager: IOTACodeInsightManager): Boolean;
  var
    Hook: TCnMethodHook;
    Filter: string;
  begin
    try
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Before InvokeCodeCompletion');
    {$ENDIF}
      // IDE ���޷����� CodeInsight ʱ�ᵯ��һ������򣨲����쳣��
      // �˴���ʱ�滻����ʾ�����ĺ��� MessageDlgPosHelp��ʹ֮����ʾ����
      // ��������ɺ��ٻָ���
      Hook := TCnMethodHook.Create(GetBplMethodAddress(@MessageDlgPosHelp),
        @MyMessageDlgPosHelp);
      try
        Filter := '';
        Result := Manager.InvokeCodeCompletion(itManual, Filter);
      finally
        Hook.Free;
      end;
    {$IFDEF DEBUG}
      CnDebugger.LogBoolean(Result, 'After InvokeCodeCompletion');
    {$ENDIF}
    except
      Result := False;
    end;
  end;

  procedure AddToSymbolList(Manager: IOTACodeInsightManager);
  var
    DisplayParams: Boolean;
    I, Idx: Integer;
    SymbolList: IOTACodeInsightSymbolList;
    Desc: string;
    Kind: TSymbolKind;
    Allow: Boolean;
    ValidChars: TSysCharSet;
    Name: string;
 {$IFDEF IDE_SUPPORT_LSP}
    Filter: string;
    Tick: Cardinal;
    AsyncManager: IOTAAsyncCodeInsightManager;
 {$ENDIF}
  begin
{$IFDEF IDE_SUPPORT_LSP}
    if Supports(Manager, IOTAAsyncCodeInsightManager, AsyncManager) then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Is an IOTAAsyncCodeInsightManager.');
    {$ENDIF}
      if not Assigned(AsyncManager) or not AsyncManager.AsyncEnabled then   // δ����
        Exit;

      if not Manager.HandlesFile(Editor.FileName) then       // ���ܴ�����ǰ�ļ�
        Exit;

      CodeInsightServices.SetQueryContext(EditView, Manager);
      try
        Allow := True;
        AsyncManager.AsyncAllowCodeInsight(Allow, #0);
        if not Allow then
          Exit;

        ValidChars := Manager.EditorTokenValidChars(False);
        Filter := '';
        FAsyncResultGot := False;
        FAsyncManagerObj := AsyncManager as TObject;
        FAsyncIsPascal := PosInfo.IsPascal;
    {$IFDEF DEBUG}
        CnDebugger.LogFmt('To Async Invoke %s.', [FAsyncManagerObj.ClassName]);
    {$ENDIF}
        FKeepUnique := True;
        AsyncManager.AsyncInvokeCodeCompletion(itAuto, Filter, EditView.CursorPos.Line,
          EditView.CursorPos.Col - 1, AsyncCodeCompletionCallBack);

        Tick := GetTickCount;
        while not FAsyncResultGot and (GetTickCount - Tick < 1000) do // ���첽�ȴ�
          Application.ProcessMessages;

{$IFDEF DEBUG}
        if not FAsyncResultGot then
          CnDebugger.LogMsg('Async Result Time out. Fail to Get Symbol List.');
{$ENDIF}
      finally
        CodeInsightServices.SetQueryContext(nil, nil);
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('End Async AddToSymbolList');
      {$ENDIF}
      end;
      Exit;
    end;
{$ENDIF}

    // ��ͨ�� CodeInsight
    if not Assigned(Manager) or not Manager.Enabled then   // δ����
      Exit;

    if not Manager.HandlesFile(Editor.FileName) then       // ���ܴ�����ǰ�ļ�
      Exit;

  {$IFDEF SYMBOL_LOCKHOOK}
    if DphIdeModule1 = 0 then
      DphIdeModule1 := LoadLibrary(DphIdeLibName);
    ComtypesLock := TComtypesLockProc(GetProcAddress(DphIdeModule1, ComtypesLockName));
    ComtypesUnLock := TComtypesLockProc(GetProcAddress(DphIdeModule1, ComtypesUnLockName));
    ComtypesLock;
    LockHook := TCnMethodHook.Create(@ComtypesLock, @MyComtypesLock);
    UnLockHook := TCnMethodHook.Create(@ComtypesUnLock, @MyComtypesUnLock);
  {$ENDIF SYMBOL_LOCKHOOK}

    CodeInsightServices.SetQueryContext(EditView, Manager);
    try
      // Allow: otherwise you will get an AV in 'InvokeCodeCompletion'
      Allow := True;
      Manager.AllowCodeInsight(Allow, #0);
      if not Allow then
        Exit;

{$IFDEF IDE_SUPPORT_LSP}
      FKeepUnique := False; // ����ȥ��
{$ENDIF}

      // Not used, but the IDE calls it in this order, and the calling order might be important.
      ValidChars := Manager.EditorTokenValidChars(False);

      if not MyInvokeCodeCompletion(Manager) then
        Exit;

      try
        SymbolList := nil;
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('Before Manager.GetSymbolList');
      {$ENDIF}
        Manager.GetSymbolList(SymbolList);
        if Assigned(SymbolList) then
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogInteger(SymbolList.Count, 'IDE SymbolList.Count');
        {$ENDIF}

          try
            for I := 0 to SymbolList.Count - 1 do
            begin
              // follow code maybe raise exception, but disabled.
            {$IFDEF UTF8_SYMBOL}
              Name := string(FastUtf8ToAnsi(AnsiString(SymbolList.SymbolText[I])));
            {$ELSE}
              Name := SymbolList.SymbolText[I];
            {$ENDIF}
              Desc := SymbolList.SymbolTypeText[I];
              Kind := SymbolFlagsToKind(SymbolList.SymbolFlags[I], Desc);
              // Description is Utf-8 format under BDS.
              Idx := Add(Name, Kind, Round(MaxInt / SymbolList.Count * I), Desc, '', True,
                False, False, {$IFDEF UTF8_SYMBOL}True{$ELSE}False{$ENDIF});

              // ����Դ�ļ����������÷���������÷�Χ
              Items[Idx].ForPascal := PosInfo.IsPascal;
              Items[Idx].ForCpp := not PosInfo.IsPascal;
            end;
          except
          {$IFDEF DEBUG}
            on E: Exception do
            begin
              CnDebugger.LogMsg('Exception: ' + E.ClassName + ' ' + E.Message);
            end;
          {$ENDIF}
          end;
        end;
      finally
        DisplayParams := False;
        Manager.Done(False, DisplayParams);
      end;
    finally
    {$IFDEF SYMBOL_LOCKHOOK}
      LockHook.Free;
      UnLockHook.Free;
      ComtypesUnLock;
    {$ENDIF SYMBOL_LOCKHOOK}

      CodeInsightServices.SetQueryContext(nil, nil);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('End AddToSymbolList');
    {$ENDIF}
    end;
  end;

begin
  Result := False;
  if PosInfo.PosKind in csNonCodePosKinds then
    Exit;

  EditView := Editor.TopView;
  if not Assigned(EditView) then
    Exit;

  // debug or comment will exit
  EditControlWrapper.GetAttributeAtPos(CnOtaGetCurrentEditControl,
    EditView.CursorPos, False, Element, LineFlag);
  if (LineFlag = lfCurrentEIP) or (Element = atComment) then
    Exit;

  Clear;
  CodeInsightServices := (BorlandIDEServices as IOTACodeInsightServices);
  if CodeInsightServices <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('IDE SymbolList Reload: CodeInsightManager Count '
      + IntToStr(CodeInsightServices.CodeInsightManagerCount));
{$ENDIF}

  {$IFDEF IDE_SetQueryContext_Bug}
    for Index := 0 to CodeInsightServices.CodeInsightManagerCount - 1 do
    begin
      CodeInsightManager := CodeInsightServices.CodeInsightManager[Index];
      if CodeInsightManager = nil then
        Continue;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('IDE SymbolList Reload: Add From CodeInsightManager: %d. Enabled: %d - %s - %s',
        [Index, Integer(CodeInsightManager.Enabled), CodeInsightManager.GetIDString, CodeInsightManager.Name]);
{$ENDIF}
      AddToSymbolList(CodeInsightManager);
    end;

    for Index := 0 to CodeInsightServices.CodeInsightManagerCount - 1 do
    begin
      CodeInsightManager := CodeInsightServices.CodeInsightManager[Index];
      // BDS2006/2007 �� SetQueryContext(nil, nil) �ᵼ�� IDE �쳣
      if CodeInsightManager.Enabled and CodeInsightManager.HandlesFile(Editor.FileName)
        and (Pos(UpperCase(CodeInsightManager.Name), UpperCase(csCIMgrNames)) > 0) then
      begin
        CodeInsightServices.SetQueryContext(nil, CodeInsightManager);
        Break;
      end;
    end;
  {$ELSE}
    CodeInsightServices.GetCurrentCodeInsightManager(CodeInsightManager);
    if (CodeInsightManager = nil) then
    begin
      for Index := 0 to CodeInsightServices.CodeInsightManagerCount - 1 do
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('IDE SymbolList Reload: Current is NIL. Add From CodeInsightManager: Index ' + IntToStr(Index));
{$ENDIF}
        CodeInsightManager := CodeInsightServices.CodeInsightManager[Index];
        AddToSymbolList(CodeInsightManager);
      end;
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('IDE SymbolList Reload: Add From Current CodeInsightManager.');
{$ENDIF}
      AddToSymbolList(CodeInsightManager);
    end;
  {$ENDIF}
  end;

  Result := Count > 0;
end;

{$ENDIF SUPPORT_IOTACodeInsightManager}

{$IFDEF SUPPORT_KibitzCompile}

{******************************************************************************}
{ Code Note:                                                                   }
{    The code below is derived from GExperts 1.2                               }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

type
  TSymbols = packed array[0..(MaxInt div SizeOf(Integer))-1] of Integer;
  PSymbols = ^TSymbols;
  TUnknowns = packed array [0..(MaxInt div SizeOf(Byte))-1] of Byte;
  PUnknowns = ^TUnknowns;
  // ����������� TKibitzResult ��¼�� RTTI ��Ϣ
  TKibitzResult = packed record
  {$IFDEF COMPILER7_UP}
    KibitzDataArray: array [0..82] of Integer;
  {$ELSE}
    KibitzDataArray: array [0..81] of Integer;
  {$ENDIF}
  {$IFDEF COMPILER6_UP}
    KibitzDataStr: string; // RTTI ��ʾ�����λ����һ�� string ����
  {$ENDIF}
    KibitzReserveArray: array[0..255] of Integer; // �ٶ���һ�������鱸��
  end;

const
  // dphideXX.bpl
  // DoKibitzCompile(FileName: AnsiString; XPos, YPos: Integer; var KibitzResult: TKibitzResult);
{$IFDEF COMPILER7_UP}
  DoKibitzCompileName = '@Pascodcmplt@DoKibitzCompile$qqrx17System@AnsiStringiir22Comtypes@TKibitzResult';
{$ELSE}
  DoKibitzCompileName = '@Codcmplt@DoKibitzCompile$qqrx17System@AnsiStringiir22Comtypes@TKibitzResult';
{$ENDIF COMPILER7_UP}
  // dccXX.dll
  // KibitzGetValidSymbols(var KibitzResult: TKibitzResult; Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;
  KibitzGetValidSymbolsName = 'KibitzGetValidSymbols';
  // corideXX.bpl
  // Comdebug.CompGetSymbolText(Symbol: PSymbols; var S: string; Unknown: Word); stdcall;
  CompGetSymbolTextName = '@Comdebug@CompGetSymbolText$qqsp16Comtypes@TSymbolr17System@AnsiStringus';

type
  TDoKibitzCompileProc = procedure(FileName: AnsiString; XPos, YPos: Integer;
    var KibitzResult: TKibitzResult); register;

  TKibitzGetValidSymbolsProc = function(var KibitzResult: TKibitzResult;
    Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;

  TCompGetSymbolTextProc = procedure(Symbol: Integer {Comtypes::TSymbol*};
    var S: string; Unknown: Word); stdcall;

  TKibitzThread = class(TThread)
  private
    FFileName: AnsiString;
    FX, FY: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const FileName: AnsiString; X, Y: Integer);
    destructor Destroy; override;
  end;

var
  DoKibitzCompile: TDoKibitzCompileProc;
  KibitzGetValidSymbols: TKibitzGetValidSymbolsProc;
  CompGetSymbolText: TCompGetSymbolTextProc;
  KibitzEnabled: Boolean;

  KibitzThread: TKibitzThread;
  HookCS: TRTLCriticalSection;
  KibitzFinished: Boolean = False;
  Hook1: TCnMethodHook;
  Hook2: TCnMethodHook;

  CorIdeModule: HModule;
  DphIdeModule: HModule;
  dccModule: HModule;

function KibitzInitialize: Boolean;
begin
  Result := False;
  try
    DphIdeModule := LoadLibrary(DphIdeLibName);
    CnWizAssert(DphIdeModule <> 0, 'Load DphIdeModule');

    DoKibitzCompile := GetProcAddress(DphIdeModule, DoKibitzCompileName);
    CnWizAssert(Assigned(DoKibitzCompile), 'Load DoKibitzCompile from DphIdeModule');

    dccModule := LoadLibrary(dccLibName);
    CnWizAssert(dccModule <> 0, 'Load dccModule');

    KibitzGetValidSymbols := GetProcAddress(dccModule, KibitzGetValidSymbolsName);
    CnWizAssert(Assigned(KibitzGetValidSymbols), 'Load KibitzGetValidSymbols from dccModule');

    CorIdeModule := LoadLibrary(CorIdeLibName);
    CnWizAssert(CorIdeModule <> 0, 'Load CorIdeModule');

    CompGetSymbolText := GetProcAddress(CorIdeModule, CompGetSymbolTextName);
    CnWizAssert(Assigned(CompGetSymbolText), 'Load CompGetSymbolText');

    Result := True;
  {$IFDEF Debug}
    CnDebugger.LogMsg('KibitzInitialize succ');
  {$ENDIF}
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

procedure KibitzFinalize;
begin
  if CorIdeModule <> 0 then
  begin
    FreeLibrary(CorIdeModule);
    CorIdeModule := 0;
  end;

  if dccModule <> 0 then
  begin
    FreeLibrary(dccModule);
    dccModule := 0;
  end;

  if DphIdeModule <> 0 then
  begin
    FreeLibrary(DphIdeModule);
    DphIdeModule := 0;
  end;
end;

procedure FakeDoKibitzCompile(FileName: AnsiString; XPos, YPos: Integer;
  var KibitzResult: TKibitzResult); register;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('FakeDoKibitzCompile');
{$ENDIF}
  FillChar(KibitzResult.KibitzDataArray, SizeOf(KibitzResult.KibitzDataArray), 0);
end;

function FakeKibitzGetValidSymbols(var KibitzResult: TKibitzResult;
  Symbols: PSymbols; Unknowns: PUnknowns; SymbolCount: Integer): Integer; stdcall;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('FakeKibitzGetValidSymbols');
{$ENDIF}
  Result := 0;
end;

{ TKibitzThread }

constructor TKibitzThread.Create(const FileName: AnsiString; X, Y: Integer);
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('TKibitzThread.Create');
{$ENDIF}
  inherited Create(False);
  FFileName := FileName;
  FX := X;
  FY := Y;
  FreeOnTerminate := True;
end;

destructor TKibitzThread.Destroy;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('TKibitzThread.Destroy');
{$ENDIF}
  KibitzThread := nil;
  inherited;
end;

procedure TKibitzThread.Execute;
var
  KibitzResult: TKibitzResult;
begin
{$IFDEF Debug}
  CnDebugger.LogMsg('TKibitzThread.Execute');
{$ENDIF}
  try
    FillChar(KibitzResult, SizeOf(KibitzResult), 0);
    DoKibitzCompile(FFileName, FX, FY, KibitzResult);
  finally
    EnterCriticalSection(HookCS);
    try
      KibitzFinished := True;
      // ������ɺ�ָ��� Hook �ĺ���
      FreeAndNil(Hook1);
      FreeAndNil(Hook2);
    finally
      LeaveCriticalSection(HookCS);
    end;
  end;
end;

function ParseProjectBegin(var FileName: AnsiString; var X, Y: Integer): Boolean;
var
  Stream: TMemoryStream;
  Lex: TCnGeneralPasLex; // Ansi/Ansi/Utf16
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ParseProjectBegin');
{$ENDIF}

  Result := False;
  FileName := CnOtaGetCurrentProjectFileName;
  Stream := nil;
  Lex := nil;

  try
    Stream := TMemoryStream.Create;
    EditFilerSaveFileToStream(FileName, Stream, True); // Ansi/Ansi/Utf16������ Lex

    Lex := TCnGeneralPasLex.Create;
    Lex.Origin := PChar(Stream.Memory);

    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID = tkBegin then
      begin
        Lex.Next;
        X := 0;
{$IFDEF UNICODE}
        Y := Lex.LineNumber; // Wide �� Lex ���кű����ʹ� 1 ��ʼ
{$ELSE}
        Y := Lex.LineNumber + 1;
{$ENDIF}
        Result := True;
        Break;
      end;
      Lex.Next;
    end;
  finally
    Lex.Free;
    Stream.Free;
  end;
end;

procedure InvokeKibitzCompileInThread;
var
  Save: TCursor;
  FileName: AnsiString;
  X, Y: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('CreateKibitzThread');
{$ENDIF}
  if not SupportKibitzCompileThread or not UseKibitzCompileThread or KibitzCompileThreadRunning then
    Exit;

  if ParseProjectBegin(FileName, X, Y) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('FileName: %s X: %d Y: %d', [FileName, X, Y]);
  {$ENDIF}

    Save := Screen.Cursor;
    KibitzFinished := False;
    KibitzThread := TKibitzThread.Create(FileName, X, Y);
    Sleep(50);  // �ȴ��߳�����һ����� Hook Kibitz ����
    Screen.Cursor := Save; // �ָ�ԭ���Ĺ��

    EnterCriticalSection(HookCS);
    try
      // ȷ���̻߳�û�н���ǰ Hook
      if not KibitzFinished then
      begin
        Hook1 := TCnMethodHook.Create(@DoKibitzCompile, @FakeDoKibitzCompile);
        Hook2 := TCnMethodHook.Create(@KibitzGetValidSymbols, @FakeKibitzGetValidSymbols);
      end;
    finally
      LeaveCriticalSection(HookCS);
    end;
  end;
end;

procedure TIDESymbolList.OnIdleExecute(Sender: TObject);
var
  Tick: Cardinal;
begin
  if not SupportKibitzCompileThread or not UseKibitzCompileThread then
    Exit;

  // �����л�ʱ�ȴ��߳̽���
  Tick := GetTickCount;
  while KibitzCompileThreadRunning do
  begin
    if GetTickCount - Tick > 500 then
      Break;
    Sleep(100);
  end;
  InvokeKibitzCompileInThread;
end;

procedure TIDESymbolList.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
  if not SupportKibitzCompileThread or not UseKibitzCompileThread then
    Exit;

  if (NotifyCode = ofnFileOpened) and IsDpr(FileName) then
  begin
  {$IFDEF Debug}
    CnDebugger.LogFmt('TIDESymbolList.OnFileNotify: %s', [FileName]);
  {$ENDIF}
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnIdleExecute);
  end;
end;

function TIDESymbolList.Reload_KibitzCompile(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
const
  csMaxSymbolCount = 32768;
var
  KibitzResult: TKibitzResult;
  SymbolCount: Integer;
  Unknowns: PUnknowns;
  Symbols: PSymbols;
  CharPos: TOTACharPos;
  Text: string;
  I, Offset: Integer;

  procedure AddItem(const AText: string; Index: Integer);
  var
    Idx, Len: Integer;
    AName, ADesc: string;
    AKind: TSymbolKind;
  begin
    if Length(AText) > 6 then
    begin
      // �жϱ�ʶ�������ͣ����ж����������
      case AText[1] of
        'v':
          AKind := skVariable;       // 'var '
        'p':
          begin
            if AText[4] = 'c' then   // 'proc '
              AKind := skProcedure
            else                     // 'prop '
              AKind := skProperty;
          end;
        'f':
          AKind := skFunction;       // 'func '
        't':
          begin                      // 'type '
            if Pos(' = class', AText) > 0 then
              AKind := skClass
            else if Pos(' = interface', AText) > 0 then
              AKind := skInterface
            else
              AKind := skType;
          end;
        'c':
          AKind := skConstant;       // 'const '
        'r':
          AKind := skConstant;       // 'rstrg '
        '?':
          AKind := skKeyword;        // '??? '
      else
        begin
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('Unknown decl: ' + AText);
        {$ENDIF}
          AKind := skUnknown;
        end;
      end;

      // ȡ��ʶ������
      Idx := 1;
      while AText[Idx] <> ' ' do     // ������������
        Inc(Idx);
      while AText[Idx] = ' ' do      // �����ո�
        Inc(Idx);
      Len := 0;
      while AText[Idx + Len] in ['a'..'z', 'A'..'Z', '0'..'9', '_'] do
        Inc(Len);
      AName := Copy(AText, Idx, Len);

      // ȡ������Ϣ
      while AText[Idx + Len] = ' ' do
        Inc(Len);
      ADesc := Copy(AText, Idx + Len, MaxInt);

      // ����ı���
      if (AKind = skVariable) and (CompareStr(ADesc, ': erroneous type') = 0) then
        Exit;

      // ��������
      Add(AName, AKind, Round(MaxInt / SymbolCount * Index), ADesc);
    end;
  end;

begin
  Result := False;
  if not KibitzEnabled or (PosInfo.PosKind in csNonCodePosKinds)
    or KibitzCompileThreadRunning then
    Exit;

  Clear;
  try
    FillChar(KibitzResult, SizeOf(KibitzResult), 0);
    CharPos := CnOtaGetCurrCharPos(nil);
    if PosInfo.PosKind in [pkClass, pkInterface, pkField] then
      Offset := -Length(InputText)
    else
      Offset := 0;

    // ִ�з�����Ϣ����
    DoKibitzCompile(Editor.FileName, CharPos.CharIndex + Offset, CharPos.Line,
      KibitzResult);

    // ���´����� GExperts ��ʹ�ã���;δ����ʹ�ú�ᵼ��ĳЩö��ֵ���������˴�����
    //if Byte(KibitzResult.KibitzDataArray[0]) in [$0B, $08, $09] then
    //  Exit;

    Symbols := nil;
    Unknowns := nil;
    try
      // ������ʱ�ڴ�
      GetMem(Symbols, csMaxSymbolCount * SizeOf(Integer));
      GetMem(Unknowns, csMaxSymbolCount * SizeOf(Byte));

      // ȡ����Ч�ķ��ű�������
      SymbolCount := KibitzGetValidSymbols(KibitzResult, Symbols, Unknowns,
        csMaxSymbolCount);

      // ���ӷ�����
      List.Capacity := SymbolCount;
      for I := 0 to SymbolCount - 1 do
      begin
        CompGetSymbolText(Symbols^[I], Text, 1);
        AddItem(Text, I);
      end;

      Result := Count > 0;
{$IFDEF DEBUG}
      CnDebugger.LogMsg(Format('TIDESymbolList.Reload, Count: %d', [Count]));
{$ENDIF}
    finally
      if Unknowns <> nil then
        FreeMem(Unknowns);
      if Symbols <> nil then
        FreeMem(Symbols);
    end;
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

{$ENDIF SUPPORT_KibitzCompile}

function KibitzCompileThreadRunning: Boolean;
begin
{$IFDEF SUPPORT_KibitzCompile}
  Result := KibitzThread <> nil;
{$ELSE}
  Result := False;
{$ENDIF SUPPORT_KibitzCompile}
end;

constructor TIDESymbolList.Create;
begin
  inherited;
{$IFDEF IDE_SUPPORT_LSP}
  FHashList := TCnStrToStrHashMap.Create(HashSize);
{$ENDIF}

{$IFDEF SUPPORT_KibitzCompile}
  KibitzEnabled := KibitzInitialize;
  InitializeCriticalSection(HookCS);
  InvokeKibitzCompileInThread;
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);
{$ENDIF SUPPORT_KibitzCompile}
end;

destructor TIDESymbolList.Destroy;
begin
{$IFDEF SUPPORT_KibitzCompile}
  CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);
  KibitzFinalize;
{$ENDIF SUPPORT_KibitzCompile}

{$IFDEF IDE_SUPPORT_LSP}
  FHashList.Free;
{$ENDIF}
  inherited;
end;

class function TIDESymbolList.GetListName: string;
begin
  Result := SCnInputHelperIDESymbolList;
end;

function TIDESymbolList.Reload(Editor: IOTAEditBuffer;
  const InputText: string; PosInfo: TCodePosInfo): Boolean;
begin
{$IFDEF SUPPORT_IDESYMBOLLIST}

{$IFDEF SUPPORT_MULTI_IDESymbolList}
  if UseCodeInsightMgr then
    Result := Reload_CodeInsightManager(Editor, InputText, PosInfo)
  else
    Result := Reload_KibitzCompile(Editor, InputText, PosInfo);
{$ELSE}

{$IFDEF SUPPORT_IOTACodeInsightManager}
  Result := Reload_CodeInsightManager(Editor, InputText, PosInfo);
{$ENDIF SUPPORT_IOTACodeInsightManager}

{$IFDEF SUPPORT_KibitzCompile}
  Result := Reload_KibitzCompile(Editor, InputText, PosInfo);
{$ENDIF SUPPORT_KibitzCompile}

{$ENDIF SUPPORT_MULTI_IDESymbolList}

{$ELSE}
  Result := False;
{$ENDIF SUPPORT_IDESYMBOLLIST}
end;

function TIDESymbolList.Add(const AName: string; AKind: TSymbolKind;
  AScope: Integer; const ADescription, AText: string; AAutoIndent,
  AMatchFirstOnly, AAlwaysDisp, ADescIsUtf8: Boolean): Integer;
{$IFDEF IDE_SUPPORT_LSP}
var
  Res: string;
{$ENDIF}
begin
{$IFDEF IDE_SUPPORT_LSP}
  Result := -1;
  if FKeepUnique and FHashList.Find(AName + ADescription, Res) then
  begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('IDE SymbolList Found Duplicated: %s. Do NOT Add.',
//      [AName]);
{$ENDIF}
    Exit;
  end;
  FHashList.Add(AName + ADescription, AName);
{$ENDIF}

  Result := inherited Add(AName, AKind, AScope, ADescription, AText, AAutoIndent,
    AMatchFirstOnly, AAlwaysDisp, ADescIsUtf8);
end;

procedure TIDESymbolList.Clear;
begin
{$IFDEF IDE_SUPPORT_LSP}
  FHashList.Free;
  FHashList := TCnStrToStrHashMap.Create(HashSize);
{$ENDIF}
  inherited;
end;

initialization
{$IFDEF SUPPORT_IDESYMBOLLIST}
{$IFNDEF BCB5}  // ֧�� BCB5/6 �� IDE �����б�����ϴ󣬷�����һ����Ԫ��
{$IFNDEF BCB6}
  RegisterSymbolList(TIDESymbolList);

  {$IFDEF IDE_SUPPORT_LSP}
  FDelphiLspHandle := GetModuleHandle(IdeLspLibName);
  if FDelphiLspHandle <> 0 then
  begin
    DelphiLspGetCount := TDelphiLSPKibitzManagerGetCount(GetProcAddress(FDelphiLspHandle, SDelphiLspGetCount));
    DelphiLspGetCodeCompEntry := TDelphiLSPKibitzManagerGetCodeCompEntry(GetProcAddress(FDelphiLspHandle, SDelphiLspGetCodeCompEntry));
  end;

  FBcbLspHandle := GetModuleHandle(IdeBcbLspLibName);
  if FBcbLspHandle <> 0 then
  begin
    BcbLspGetCount := TBcbLSPKibitzManagerGetCount(GetProcAddress(FBcbLspHandle, SBcbLspGetCount));
    BcbLspGetCodeCompEntry := TBcbLSPKibitzManagerGetCodeCompEntry(GetProcAddress(FBcbLspHandle, SBcbLspGetCodeCompEntry));
  end;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.