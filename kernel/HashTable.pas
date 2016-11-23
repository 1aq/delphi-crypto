unit HashTable;
{******************************************************************************}
{*  Hash Table Unit                                                           *}
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
    THashItem = class;
    THashList = class;
{$M-}

{ �������� ���-������� }
{$I 'THashItem.int.inc'}
{$I 'THashList.int.inc'}

resourcestring
    CLS_THASHITEM_NAME              = '������� ���-�������';
    PRP_THASHITEM_KEY_HASH          = '���-����';
    PRP_THASHITEM_DATA_HASH         = '��� ������';
    PRP_THASHITEM_TIME_STAMP_VECTOR = '��������� �����';

const
    _key_hash          = 3;
    _data_hash         = 4;
    _time_stamp_vector = 5;

{ ������ ���-������� }
{$I 'THashItem.err.inc'}
{$I 'THashList.err.inc'}

implementation

uses
    Engine;

{ ���������� ���-������� }
{$I 'THashItem.imp.inc'}
{$I 'THashList.imp.inc'}


end.