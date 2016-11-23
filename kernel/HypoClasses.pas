unit HypoClasses;
{******************************************************************************}
{*  Hypo Classes Unit                                                         *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit & rat 2011                                       *}
{******************************************************************************}
interface

{$I '../std.inc'}

uses
    Windows, SysUtils, Classes, Variants, DateUtils,
    Utils, Strings, Versions, VarRecs,
    EClasses, Kernel, ProtoClasses, CryptoClasses, MetaClasses,
    HashTable,
    SQLite3, SQLite3DLL, SQLiteTable3;

type
{$M+}
    THypoObject = class;
    THypoObjects = class;
{$M-}

{ �������� ����-������� }
{$I 'THypoObject.int.inc'}
{$I 'THypoObjects.int.inc'}

resourcestring
    CLS_THYPOOBJECT_NAME              = '����-������';
    PRP_THYPOOBJECT_TIME_STAMP_CREATE = '���� � ����� ��������';
    PRP_THYPOOBJECT_TIME_STAMP_MODIFY = '���� � ����� ���������� ��������������';
    PRP_THYPOOBJECT_TIME_STAMP_PUBLIC = '���� � ����� ����������';
    PRP_THYPOOBJECT_TIME_STAMP_VECTOR = '�������� ��������� �����';
    PRP_THYPOOBJECT_VERSION           = '������';
    PRP_THYPOOBJECT_KEY_HASH          = '���-����';
    PRP_THYPOOBJECT_DATA_HASH         = '��� ������';

const
    _hypo_time_stamp_create = _id + 1;
    _hypo_time_stamp_modify = _id + 2;
    _hypo_time_stamp_public = _id + 3;
    _hypo_time_stamp_vector = _id + 4;
    _hypo_version           = _id + 5;
    _hypo_key_hash          = _id + 6;
    _hypo_data_hash         = _id + 7;

{ ������ ����-������� }
{$I 'THypoObject.err.inc'}
{$I 'THypoObjects.err.inc'}

implementation

{ ���������� ����-������� }
{$I 'THypoObject.imp.inc'}
{$I 'THypoObjects.imp.inc'}


end.