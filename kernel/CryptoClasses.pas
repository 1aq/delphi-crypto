unit CryptoClasses;
{******************************************************************************}
{*  Crypto Classes Unit                                                       *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2011                                             *}
{******************************************************************************}
interface

{$I '../std.inc'}

uses
    Windows, SysUtils, Classes, Variants, DateUtils,
    Utils, Strings, Versions, VarRecs,
    EClasses, Kernel, ProtoClasses;

type
{$M+}
    TCryptoProperty = class;
    TCryptoObject = class;
    TCryptoObjects = class;
{$M-}

{ �������� ������-�������� }
{$I 'TCryptoProperty.int.inc'}
{ �������� ������-������� }
{$I 'TCryptoObject.int.inc'}
{$I 'TCryptoObjects.int.inc'}

resourcestring
    CLS_TCRYPTOOBJECT_NAME = '������-������';

{ ������ ������-�������� }
{$I 'TCryptoProperty.err.inc'}
{ ������ ������-������� }
{$I 'TCryptoObject.err.inc'}
{$I 'TCryptoObjects.err.inc'}

implementation

uses
    Crypto, CryptoSystem;

{ ���������� ������-�������� }
{$I 'TCryptoProperty.imp.inc'}
{ ���������� ������-������� }
{$I 'TCryptoObject.imp.inc'}
{$I 'TCryptoObjects.imp.inc'}


end.
