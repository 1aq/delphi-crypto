unit ProtoClasses;
{******************************************************************************}
{*  Proto Classes Unit                                                        *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2011                                             *}
{******************************************************************************}
interface

{$I '../std.inc'}

uses
    Windows, SysUtils, Classes, Variants, DateUtils,
    Utils, Strings, Versions, VarRecs,
    EClasses, Kernel;

type
{$M+}
    TProtoProperty = class;
    TProtoProperties = class;
    TProtoObject = class;
    TProtoObjects = class;
{$M-}

    CProtoObjects = class of TProtoObjects;

{ �������� �����-�������� }
{$I 'TProtoProperty.int.inc'}
{$I 'TProtoProperties.int.inc'}
{ �������� �����-������� }
{$I 'TProtoObject.int.inc'}
{$I 'TProtoObjects.int.inc'}

resourcestring
    CLS_TPROTOOBJECT_NAME          = '�����-������';
    PRP_TPROTOOBJECT_OBJECT_NAME   = '������������ �������';
    PRP_TPROTOOBJECT_CLASS_NAME    = '������������ ������';
    PRP_TPROTOOBJECT_CLASS_VERSION = '������ ������';

const
    _object_name   = 0;
    _class_name    = 1;
    _class_version = 2;

{ ������ �����-�������� }
{$I 'TProtoProperty.err.inc'}
{$I 'TProtoProperties.err.inc'}
{ ������ �����-������� }
{$I 'TProtoObject.err.inc'}
{$I 'TProtoObjects.err.inc'}

implementation

{ ���������� �����-�������� }
{$I 'TProtoProperty.imp.inc'}
{$I 'TProtoProperties.imp.inc'}
{ ���������� �����-������� }
{$I 'TProtoObject.imp.inc'}
{$I 'TProtoObjects.imp.inc'}


end.
