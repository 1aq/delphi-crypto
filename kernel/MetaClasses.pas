unit MetaClasses;
{******************************************************************************}
{*  Meta Classes Unit                                                        *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2011                                             *}
{******************************************************************************}
interface

{$I '../std.inc'}

uses
    Windows, SysUtils, Classes, Variants, DateUtils,
    Utils, Strings, Versions, VarRecs,
    EClasses, Kernel, ProtoClasses, CryptoClasses,
    SQLite3, SQLite3DLL, SQLiteTable3;

type
{$M+}
    TMetaProperty = class;
    TMetaObject = class;
{$M-}

{ �������� ����-�������� }
{$I 'TMetaProperty.int.inc'}
{ �������� ����-������� }
{$I 'TMetaObject.int.inc'}
{$I 'TMetaObjects.int.inc'}

resourcestring
    CLS_TMETAOBJECT_NAME = '����-������';
    PRP_TMETAOBJECT_ID   = '�������������';

const
    _id = 3;

{ ������ ����-�������� }
{$I 'TMetaProperty.err.inc'}
{ ������ ����-������� }
{$I 'TMetaObject.err.inc'}
{$I 'TMetaObjects.err.inc'}

implementation

{ ���������� ����-�������� }
{$I 'TMetaProperty.imp.inc'}
{ ���������� ����-������� }
{$I 'TMetaObject.imp.inc'}
{$I 'TMetaObjects.imp.inc'}


end.
