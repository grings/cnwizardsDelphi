{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnFavoriteWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：收藏夹专家单元
* 单元作者：张伟（Alan） BeyondStudio@163.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2003.07.15 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, ToolsAPI,
  IniFiles, CnBaseWizard, CnConsts, CnWizUtils, CnWizConsts, CnAddToFavoriteFrm,
  CnManageFavoriteFrm, CnWizIdeUtils;

type

//==============================================================================
// 收藏夹专家
//==============================================================================

{ TCnFavoriteWizard }

  TCnFavoriteWizard = class(TCnSubMenuWizard)
  private
    IDAddToFavorite: Integer;
    IDManageFavorite: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure Loaded; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

{$IFDEF Debug}
uses
  uDbg;
{$ENDIF Debug}

{ TCnFavoriteWizard }

procedure TCnFavoriteWizard.Config;
begin
  ShowShortCutDialog('CnFavoriteWizard');
end;

constructor TCnFavoriteWizard.Create;
begin
  inherited;

  IDAddToFavorite := AddSubAction(SCnFavWizAddToFavorite,
    SCnFavWizAddToFavoriteMenuCaption, 0,
    SCnFavWizAddToFavoriteMenuHint, SCnFavWizAddToFavorite);

  IDManageFavorite := AddSubAction(SCnFavWizManageFavorite,
    SCnFavWizManageFavoriteMenuCaption, 0,
    SCnFavWizManageFavoriteMenuHint, SCnFavWizManageFavorite);

  AddSepMenu;
end;

function TCnFavoriteWizard.GetCaption: string;
begin
  Result := SCnFavWizCaption;
end;

function TCnFavoriteWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnFavoriteWizard.GetHint: string;
begin
  Result := SCnFavWizHint;
end;

function TCnFavoriteWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnFavoriteWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnFavWizName;
  Author := SCnPack_Alan;
  Email := SCnPack_AlanEmail;
  Comment := SCnFavWizComment;
end;

procedure TCnFavoriteWizard.Loaded;
begin
  inherited;

end;

procedure TCnFavoriteWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnFavoriteWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnFavoriteWizard.SubActionExecute(Index: Integer);
begin
  if not Active then Exit;

  if Index = IDAddToFavorite then
    ShowAddToFavoriteForm
  else
  if Index = IDManageFavorite then
    ShowManageFavoriteForm;
end;

procedure TCnFavoriteWizard.SubActionUpdate(Index: Integer);
var
  AEnabled: Boolean;
begin
  AEnabled := (CnOtaGetCurrentFormEditor <> nil) or (CnOtaGetCurrentSourceEditor <> nil);

  SubActions[IDAddToFavorite].Visible := Active;
  SubActions[IDAddToFavorite].Enabled := AEnabled;
end;

initialization
  RegisterCnWizard(TCnFavoriteWizard); // 注册专家

end.
