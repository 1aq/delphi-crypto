unit CryptoSystem;
{******************************************************************************}
{*  Crypto System Unit                                                        *}
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
    TCrypto = class;
{$M-}

{ �������� ������-������� }
{$I 'TCrypto.int.inc'}

resourcestring
    CLS_TCRYPTO_NAME           = '������-�������';
    PRP_TCRYPTO_ALG_ASYMMETRIC = '������������� ����';
    PRP_TCRYPTO_ALG_SYMMETRIC  = '������������ ����';
    PRP_TCRYPTO_MODE_SYMMETRIC = '����� ������������� �����';
    PRP_TCRYPTO_ALG_HASH       = '������� �����������';
    PRP_TCRYPTO_GEN_RANDOM     = '��������� ������-��������� �����';

const
    _alg_asymmetric = 4;
    _alg_symmetric  = 5;
    _mode_symmetric = 6;
    _alg_hash       = 7;
    _gen_random     = 8;

{ ������ ������-������� }
{$I 'TCrypto.err.inc'}

implementation

uses
    Crypto;

{ ���������� ������-������� }
{$I 'TCrypto.imp.inc'}


end.