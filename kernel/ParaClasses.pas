unit ParaClasses;
{******************************************************************************}
{*  Para Classes Unit                                                         *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2011                                             *}
{******************************************************************************}
interface

{$I '../std.inc'}

uses
    Windows, SysUtils, Classes, Variants, DateUtils,
    Utils, Strings, Versions, VarRecs,
    EClasses, Kernel, ProtoClasses, CryptoClasses, MetaClasses, 
    SQLite3, SQLite3DLL, SQLiteTable3;

type
{$M+}
    TParaObject = class;
    TParaObjects = class;
{$M-}

{ �������� ����-������� }
{$I 'TParaObject.int.inc'}
{$I 'TParaObjects.int.inc'}

resourcestring
    CLS_TPARAOBJECT_NAME        = '����-������';
    PRP_TPARAOBJECT_ID_EXTERNAL = '����-�������������';

const
    _id_external = _id + 1;

{ ������ ����-������� }
{$I 'TParaObject.err.inc'}
{$I 'TParaObjects.err.inc'}

implementation

{ ���������� ����-������� }
{$I 'TParaObject.imp.inc'}
{$I 'TParaObjects.imp.inc'}


end.