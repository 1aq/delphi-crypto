unit Engine;
{******************************************************************************}
{*  Engine Unit                                                               *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2011                                             *}
{******************************************************************************}
////////////////////////////////////////////////////////////////////////////////
// TMetaObject --+------------------- THypoObject --------------------- TPic  //
//      |        |                         |                                  //
//      |     TCrypto       +--------------+----------------+                 //
//      |                   |                               |                 //
//      |               TMessage                       TCategorie             //
//      |                                                                     //
//      +------------------------------ TKeyWord                              //
//      |                                                                     //
// TParaObject -----+---------------+---------------+----------------+        //
//      |           |               |               |                |        //
//      |      TMessageType  TMessageStatus  TCategorieType  TCategorieStatus //
//      |                                                                     //
// THyperObject                                                               //
//      |                                                                     //
//    TUser                                                                   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
interface

{$I '../std.inc'}

uses
    Windows, SysUtils, Classes, Variants, Consts, Forms, ComCtrls,
    Graphics, jpeg, pngimage,
    DateUtils, Utils, Strings, Versions, VarRecs,
    EClasses, Kernel, ProtoClasses, CryptoClasses, MetaClasses, ParaClasses,
    HypoClasses, HyperClasses, CryptoSystem,
    HashTable,
    XMLUtils, XMLParser, XMLDOM,
    SQLite3, SQLite3DLL, SQLiteTable3;

type
{$M+}
    TPic = class;
    TPics = class;
    TUser = class;
    TUsers = class;
    TMessageType = class;
    TMessageStatus = class;
    TMessage = class;
    TMessages = class;
    TCategorieType = class;
    TCategorieStatus = class; 
    TCategorie = class;
    TCategories = class;
    TKeyWord = class;
    TKeyWords = class;
    TPackageType = class;
    TPackageStatus = class;
    TPackage = class;
    TPackages = class;
{$M-}

{ �������� ������ }
{$I 'TPic.int.inc'}
{$I 'TPics.int.inc'}
{ �������� ������� ������������ }
{$I 'TUser.int.inc'}
{$I 'TUsers.int.inc'}
{ �������� ������� ���� ��������� }
{$I 'TMessageType.int.inc'}
{ �������� ������� ������� ��������� }
{$I 'TMessageStatus.int.inc'}
{ �������� ������� ��������� }
{$I 'TMessage.int.inc'}
{$I 'TMessages.int.inc'}
{ �������� ������� ���� ��������� }
{$I 'TCategorieType.int.inc'}
{ �������� ������� ������� ��������� }
{$I 'TCategorieStatus.int.inc'}
{ �������� ������� ��������� }
{$I 'TCategorie.int.inc'}
{$I 'TCategories.int.inc'}
{ �������� ������� ��������� ����� }
{$I 'TKeyWord.int.inc'}
{$I 'TKeyWords.int.inc'}
{ �������� ������� ���� ������ }
{$I 'TPackageType.int.inc'}
{ �������� ������� ������� ������ }
{$I 'TPackageStatus.int.inc'}
{ �������� ������� ������ }
{$I 'TPackage.int.inc'}
{$I 'TPackages.int.inc'}
{ �������� ������ ������������� }
{$I 'UsersList.int.inc'}
{ �������� ������ ��������� }
{$I 'CategoriesTree.int.inc'}
{ �������� ������ ��������� }
{$I 'MessagesList.int.inc'}

resourcestring
    CLS_TPIC_NAME     = '������';
    PRP_TPIC_ID_OWNER = '������������� ���������';
    PRP_TPIC_FORMAT   = '������ ������';
    PRP_TPIC_DATA     = '��������� ������';

const
    _pic_id                = _id;
    _pic_time_stamp_create = _hypo_time_stamp_create;
    _pic_time_stamp_modify = _hypo_time_stamp_modify;
    _pic_time_stamp_public = _hypo_time_stamp_public;
    _pic_time_stamp_vector = _hypo_time_stamp_vector;
    _pic_version           = _hypo_version;
    _pic_key_hash          = _hypo_key_hash;
    _pic_data_hash         = _hypo_data_hash;
    _pic_id_owner          = _id + 8;
    _pic_format            = _id + 9;
    _pic_data              = _id + 10;

resourcestring
    CLS_TUSER_NAME           = '������������';
    PRP_TUSER_LOGIN          = '�����';
    PRP_TUSER_ID_OWNER       = '������������� ���������';
    PRP_TUSER_PASSWORD       = '������';
    PRP_TUSER_SALT           = '����';
    PRP_TUSER_ID_CRYPTO      = '������������� ������-�������';
    PRP_TUSER_EMAIL          = '����������� �����';
    PRP_TUSER_EMAIL_PASSWORD = '������ � ����������� �����';
    PRP_TUSER_IP             = 'ip-�����';
    PRP_TUSER_PORT           = '����';
    PRP_TUSER_DESCRIPTION    = '��������';
    PRP_TUSER_SEX            = '���';
    PRP_TUSER_BIRTHDAY       = '���� ��������';
    PRP_TUSER_HASH_PIC       = '���-���� ������';
    PRP_TUSER_ID_PIC         = '������������� ������';
    PRP_TUSER_PUBLIC_KEY     = '��������� ����';
    PRP_TUSER_PRIVATE_KEY    = '��������� ����';
    PRP_TUSER_TIMEOUT        = '������� ����������';
    PRP_TUSER_USE_PROXY      = '������������� proxy-�������';
    PRP_TUSER_PROXY_IP       = 'ip-����� proxy-�������';
    PRP_TUSER_PROXY_PORT     = '���� proxy-�������';
    PRP_TUSER_PROXY_LOGIN    = '����� proxy-�������';
    PRP_TUSER_PROXY_PASSWORD = '������ proxy-�������';
    PRP_TUSER_PROXY_PROTOCOL = '�������� proxy-�������';
    PRP_TUSER_SMTP_HOST      = 'smtp-������';
    PRP_TUSER_SMTP_PORT      = '���� smtp-�������';
    PRP_TUSER_POP3_HOST      = 'pop3-������';
    PRP_TUSER_POP3_PORT      = '���� pop3-�������';
    PRP_TUSER_AUTO_TLS       = 'auto tls';
    PRP_TUSER_FULL_SSL       = 'full ssl';

const
    _usr_id                = _id;
    _usr_login             = _id_external;
    _usr_time_stamp_create = _hyper_time_stamp_create;
    _usr_time_stamp_modify = _hyper_time_stamp_modify;
    _usr_time_stamp_public = _hyper_time_stamp_public;
    _usr_time_stamp_vector = _hyper_time_stamp_vector;
    _usr_version           = _hyper_version;
    _usr_key_hash          = _hyper_key_hash;
    _usr_data_hash         = _hyper_data_hash;
    _usr_id_owner          = _id_external + 8;
    _usr_password          = _id_external + 9;
    _usr_salt              = _id_external + 10;
    _usr_id_crypto         = _id_external + 11;
    _usr_email             = _id_external + 12;
    _usr_email_password    = _id_external + 13;
    _usr_ip                = _id_external + 14;
    _usr_port              = _id_external + 15;
    _usr_description       = _id_external + 16;
    _usr_sex               = _id_external + 17;
    _usr_birthday          = _id_external + 18;
    _usr_hash_pic          = _id_external + 19;
    _usr_id_pic            = _id_external + 20;
    _usr_public_key        = _id_external + 21;
    _usr_private_key       = _id_external + 22;
    _usr_timeout           = _id_external + 23;
    _usr_use_proxy         = _id_external + 24;
    _usr_proxy_ip          = _id_external + 25;
    _usr_proxy_port        = _id_external + 26;
    _usr_proxy_login       = _id_external + 27;
    _usr_proxy_password    = _id_external + 28;
    _usr_proxy_protocol    = _id_external + 29;
    _usr_smtp_host         = _id_external + 30;
    _usr_smtp_port         = _id_external + 31;
    _usr_pop3_host         = _id_external + 32;
    _usr_pop3_port         = _id_external + 33;
    _usr_auto_tls          = _id_external + 34;
    _usr_full_ssl          = _id_external + 35;

resourcestring
    CLS_TMESSAGETYPE_NAME        = '��� ���������';
    PRP_TMESSAGETYPE_NAME        = '������������';
    PRP_TMESSAGETYPE_DESCRIPTION = '��������';

const
    _msg_type_id          = _id;
    _msg_type_name        = _id_external;
    _msg_type_description = _id_external + 1;

resourcestring
    CLS_TMESSAGESTATUS_NAME        = '������ ���������';
    PRP_TMESSAGESTATUS_NAME        = '������������';
    PRP_TMESSAGESTATUS_DESCRIPTION = '��������';

const
    _msg_status_id          = _id;
    _msg_status_name        = _id_external;
    _msg_status_description = _id_external + 1;

resourcestring
    CLS_TMESSAGE_NAME           = '���������';
    PRP_TMESSAGE_HASH_AUTHOR    = '���-���� ������';
    PRP_TMESSAGE_ID_AUTHOR      = '������������� ������';
    PRP_TMESSAGE_ID_OWNER       = '������������� ���������';
    PRP_TMESSAGE_HASH_CATEGORIE = '���-���� ���������-���������';
    PRP_TMESSAGE_ID_CATEGORIE   = '������������� ���������-���������';
    PRP_TMESSAGE_ID_TYPE        = '������������� ����';
    PRP_TMESSAGE_ID_STATUS      = '������������� �������';
    PRP_TMESSAGE_SUBJECT        = '����';
    PRP_TMESSAGE_TEXT           = '�����';
    PRP_TMESSAGE_HASH_PIC       = '���-���� ������';
    PRP_TMESSAGE_ID_PIC         = '������������� ������';
    PRP_TMESSAGE_INDEX_PIC      = '������ ����������� ������';
    PRP_TMESSAGE_SALT           = '����';

const
    _msg_id                = _id;
    _msg_time_stamp_create = _hypo_time_stamp_create;
    _msg_time_stamp_modify = _hypo_time_stamp_modify;
    _msg_time_stamp_public = _hypo_time_stamp_public;
    _msg_time_stamp_vector = _hypo_time_stamp_vector;
    _msg_version           = _hypo_version;
    _msg_key_hash          = _hypo_key_hash;
    _msg_data_hash         = _hypo_data_hash;
    _msg_hash_categorie    = _id + 8;
    _msg_id_categorie      = _id + 9;
    _msg_hash_author       = _id + 10;
    _msg_id_author         = _id + 11;
    _msg_id_owner          = _id + 12;
    _msg_id_type           = _id + 13;
    _msg_id_status         = _id + 14;
    _msg_subject           = _id + 15;
    _msg_text              = _id + 16;
    _msg_hash_pic          = _id + 17;
    _msg_id_pic            = _id + 18;
    _msg_index_pic         = _id + 19;
    _msg_salt              = _id + 20;

resourcestring
    CLS_TCATEGORIETYPE_NAME        = '��� ���������';
    PRP_TCATEGORIETYPE_NAME        = '������������';
    PRP_TCATEGORIETYPE_DESCRIPTION = '��������';

const
    _ctg_type_id          = _id;
    _ctg_type_name        = _id_external;
    _ctg_type_description = _id_external + 1;

resourcestring
    CLS_TCATEGORIESTATUS_NAME        = '������ ���������';
    PRP_TCATEGORIESTATUS_NAME        = '������������';
    PRP_TCATEGORIESTATUS_DESCRIPTION = '��������';

const
    _ctg_status_id          = _id;
    _ctg_status_name        = _id_external;
    _ctg_status_description = _id_external + 1;

resourcestring
    CLS_TCATEGORIE_NAME        = '���������';
    PRP_TCATEGORIE_HASH_AUTHOR = '���-���� ������';
    PRP_TCATEGORIE_ID_AUTHOR   = '������������� ������';
    PRP_TCATEGORIE_ID_OWNER    = '������������� ���������';
    PRP_TCATEGORIE_HASH_PARENT = '���-���� ������';
    PRP_TCATEGORIE_ID_PARENT   = '������������� ������';
    PRP_TCATEGORIE_ID_TYPE     = '������������� ����';
    PRP_TCATEGORIE_ID_STATUS   = '������������� �������';
    PRP_TCATEGORIE_NAME        = '��������';
    PRP_TCATEGORIE_DESCRIPTION = '��������';
    PRP_TCATEGORIE_HASH_PIC    = '���-���� ������';
    PRP_TCATEGORIE_ID_PIC      = '������������� ������';
    PRP_TCATEGORIE_INDEX_PIC   = '������ ����������� ������';
    PRP_TCATEGORIE_SALT        = '����';

const
    _ctg_id                = _id;
    _ctg_time_stamp_create = _hypo_time_stamp_create;
    _ctg_time_stamp_modify = _hypo_time_stamp_modify;
    _ctg_time_stamp_public = _hypo_time_stamp_public;
    _ctg_time_stamp_vector = _hypo_time_stamp_vector;
    _ctg_version           = _hypo_version;
    _ctg_key_hash          = _hypo_key_hash;
    _ctg_data_hash         = _hypo_data_hash;
    _ctg_hash_parent       = _id + 8;
    _ctg_id_parent         = _id + 9;
    _ctg_hash_author       = _id + 10;
    _ctg_id_author         = _id + 11;
    _ctg_id_owner          = _id + 12;
    _ctg_id_type           = _id + 13;
    _ctg_id_status         = _id + 14;
    _ctg_name              = _id + 15;
    _ctg_description       = _id + 16;
    _ctg_hash_pic          = _id + 17;
    _ctg_id_pic            = _id + 18;
    _ctg_index_pic         = _id + 19;
    _ctg_salt              = _id + 20;

resourcestring
    CLS_TKEYWORD_NAME           = '�������� �����';
    PRP_TKEYWORD_KEY_WORD       = '�������� �����';
    PRP_TKEYWORD_HASH           = '��� ��������� �����';
    PRP_TKEYWORD_HASH_CATEGORIE = '���-���� ���������';
    PRP_TKEYWORD_ID_CATEGORIE   = '������������� ���������';
    PRP_TKEYWORD_HASH_MESSAGE   = '���-���� ���������';
    PRP_TKEYWORD_ID_MESSAGE     = '������������� ���������';
    PRP_TKEYWORD_HASH_AUTHOR    = '���-���� ������';
    PRP_TKEYWORD_ID_AUTHOR      = '������������� ������';
    PRP_TKEYWORD_ID_OWNER       = '������������� ���������';
    PRP_TKEYWORD_SALT           = '����';

const
    _kwd_id             = _id;
    _kwd_key_word       = _id + 1;
    _kwd_hash           = _id + 2;
    _kwd_hash_categorie = _id + 3;
    _kwd_id_categorie   = _id + 4;
    _kwd_hash_message   = _id + 5;
    _kwd_id_message     = _id + 6;
    _kwd_hash_author    = _id + 7;
    _kwd_id_author      = _id + 8;
    _kwd_id_owner       = _id + 9;
    _kwd_salt           = _id + 10;

resourcestring
    CLS_TPACKAGETYPE_NAME        = '��� ������';
    PRP_TPACKAGETYPE_NAME        = '������������';
    PRP_TPACKAGETYPE_DESCRIPTION = '��������';

const
    _pck_type_id          = _id;
    _pck_type_name        = _id_external;
    _pck_type_description = _id_external + 1;

resourcestring
    CLS_TPACKAGESTATUS_NAME        = '������ ������';
    PRP_TPACKAGESTATUS_NAME        = '������������';
    PRP_TPACKAGESTATUS_DESCRIPTION = '��������';

const
    _pck_status_id          = _id;
    _pck_status_name        = _id_external;
    _pck_status_description = _id_external + 1;

resourcestring
    CLS_TPACKAGE_NAME               = '�����';
    PRP_TPACKAGE_ID_SENDER          = '������������� �����������';
    PRP_TPACKAGE_SENDER_HASH        = '���-���� �����������';
    PRP_TPACKAGE_ID_RECEIVER        = '������������� ����������';
    PRP_TPACKAGE_RECEIVER_HASH      = '���-���� ����������';
    PRP_TPACKAGE_TIME_STAMP_CREATE  = '���� � ����� �������� ������';
    PRP_TPACKAGE_TIME_STAMP_SEND    = '���� � ����� �������� ������';
    PRP_TPACKAGE_TIME_STAMP_RECEIVE = '���� � ����� ��������� ������';
    PRP_TPACKAGE_VERSION            = '������';
    PRP_TPACKAGE_KEY_HASH           = '���-����';
    PRP_TPACKAGE_DATA_HASH          = '��� ������';
    PRP_TPACKAGE_ID_OWNER           = '������������� ���������';
    PRP_TPACKAGE_ID_TYPE            = '������������� ����';
    PRP_TPACKAGE_ID_STATUS          = '������������� �������';
    PRP_TPACKAGE_META_CLASS_ID      = '����� ����-������';
    PRP_TPACKAGE_META_DATA          = '����-������';

const
    _pck_id                 = _id;
    _pck_id_sender          = _id + 1;
    _pck_sender_hash        = _id + 2;
    _pck_id_receiver        = _id + 3;
    _pck_receiver_hash      = _id + 4;
    _pck_time_stamp_create  = _id + 5;
    _pck_time_stamp_send    = _id + 6;
    _pck_time_stamp_receive = _id + 7;
    _pck_version            = _id + 8;
    _pck_key_hash           = _id + 9;
    _pck_data_hash          = _id + 10;
    _pck_id_owner           = _id + 11;
    _pck_id_type            = _id + 12;
    _pck_id_status          = _id + 13;
    _pck_meta_class_id      = _id + 14;
    _pck_meta_data          = _id + 15;

{resourcestring
    CLS_TSESSION_NAME              = '�������� ������';
    PRP_TSESSION_ID_OWNER          = '������������� ���������';
    PRP_TSESSION_NAME              = '������������ ��������� ������';
    PRP_TSESSION_VALUE             = '�������� ��������� ������';
    PRP_TSESSION_TIME_STAMP_START  = '����� ������ �������� ��������� ������';
    PRP_TSESSION_TIME_STAMP_FINISH = '����� ��������� �������� ��������� ������';
    PRP_TSESSION_SALT              = '����';

const
    _ssn_id                = _id;
    _ssn_id_owner          = _id + 1;
    _ssn_name              = _id + 2;
    _ssn_value             = _id + 3;
    _ssn_time_stamp_start  = _id + 4;
    _ssn_time_stamp_finish = _id + 5;
    _ssn_salt              = _id + 6;}

{ ������ ������ }
{$I 'TPic.err.inc'}
{$I 'TPics.err.inc'}
{ ������ ������������ }
{$I 'TUser.err.inc'}
{$I 'TUsers.err.inc'}
{ ������ ������� ���� ��������� }
{$I 'TMessageType.err.inc'}
{ ������ ������� ������� ��������� }
{$I 'TMessageStatus.err.inc'}
{ ������ ������� ��������� }
{$I 'TMessage.err.inc'}
{$I 'TMessages.err.inc'}
{ ������ ������� ���� ��������� }
{$I 'TCategorieType.err.inc'}
{ ������ ������� ������� ��������� }
{$I 'TCategorieStatus.err.inc'}
{ ������ ������� ��������� }
{$I 'TCategorie.err.inc'}
{$I 'TCategories.err.inc'}
{ ������ ������� ��������� ����� }
{$I 'TKeyWord.err.inc'}
{$I 'TKeyWords.err.inc'}
{ ������ ������� ���� ������ }
{$I 'TPackageType.err.inc'}
{ ������ ������� ������� ������ }
{$I 'TPackageStatus.err.inc'}
{ ������ ������� ������ }
{$I 'TPackage.err.inc'}
{$I 'TPackages.err.inc'}
{ ������ ������ ������������� }
{$I 'UsersList.err.inc'}
{ ������ ������ ��������� }
{$I 'CategoriesTree.err.inc'}
{ ������ ������ ��������� }
{$I 'MessagesList.err.inc'}

resourcestring
    ERR_USER_NOT_ASSIGNED = '�� ������� ������� ���������� ������ ������������!';

var
    DATABASE_FILE_NAME      : String = '';  { ���� �� }
    USER_ID                 : TID    = 0;   { ������������� ����������� ������� ������������ }
    USER_KEY_HASH           : Hex    = '';
    USER                    : TUser  = NIL; { ���������� ������ ������������ }
    ROOT_CATEGORIE_ID       : TID    = 0;   { �������� ��������� }
    ROOT_CATEGORIE_KEY_HASH : Hex    = '';

const
    CATEGORIE_ROOT_TYPE_ID      = 1; { ������ }
    CATEGORIE_FORUM_TYPE_ID     = 2; { ������ }
    CATEGORIE_TOPIC_TYPE_ID     = 3; { ���� ��� ���-���� }

    CATEGORIE_OPENED_STATUS_ID  = 1; { �������� ���� }
    CATEGORIE_CLOSED_STATUS_ID  = 2; { �������� ���� }
    CATEGORIE_DELETED_STATUS_ID = 3; { ��������� ���� }

    MESSAGE_FORUM_TYPE_ID       = 1; { ��������� ������ }
    MESSAGE_PUBLIC_TYPE_ID      = 2; { ��������� ��������� }
    MESSAGE_PRIVATE_TYPE_ID     = 3; { ��������� ��������� }

    MESSAGE_ACTIVE_STATUS_ID    = 1; { �������� ��������� }
    MESSAGE_DELETED_STATUS_ID   = 2; { ��������� ��������� }

const
    MAX_MESSAGE_LENGTH = 4096;

const
    PACKAGE_GET_TYPE_ID = 1; { ��������� ������ }
    PACKAGE_PUT_TYPE_ID = 2; { �������� ������ }
    PACKAGE_DEL_TYPE_ID = 3; { ������� ������ }
    PACKAGE_UPD_TYPE_ID = 4; { ��������� ���������� }

    PACKAGE_TYPE : array [PACKAGE_GET_TYPE_ID..PACKAGE_UPD_TYPE_ID ] of ShortString = (
        'GET',
        'PUT',
        'DEL',
        'UPD'
    );

function GetPckTypeExternal (const anID: TID) : ShortString;

const
    PACKAGE_CREATED_STATUS_ID  = 1; { ����� ������ }
    PACKAGE_SENDED_STATUS_ID   = 2; { ����� ��������� }
    PACKAGE_RECEIVED_STATUS_ID = 3; { ����� ������ }
    PACKAGE_REJECTED_STATUS_ID = 4; { ����� ��������� }
    PACKAGE_EXECUTED_STATUS_ID = 5; { ����� �������� }

procedure UpdateMailData (const anUser: TUser);
procedure SetMailData (const anObject: TMetaObject);

const
    tbsEmpty  = 0;
    tbsLoaded = 1;

const
    tabForum = 0;
    tabUsers = 1;
    tabUser  = 2;
    tabMail  = 3;

procedure SetTabStatus (const aTabIndex: Integer; const aStatus: Integer);
function GetTabStatus (const aTabIndex: Integer) : Integer;

implementation

uses
    BBCode,
    DllThreads,
    DialogClasses,
    uMain;

{ ���������� ������ }
{$I 'TPic.imp.inc'}
{$I 'TPics.imp.inc'}
{ ���������� ������������ }
{$I 'TUser.imp.inc'}
{$I 'TUsers.imp.inc'}
{ ���������� ������� ���� ��������� }
{$I 'TMessageType.imp.inc'}
{ ���������� ������� ������� ��������� }
{$I 'TMessageStatus.imp.inc'}
{ ���������� ������� ��������� }
{$I 'TMessage.imp.inc'}
{$I 'TMessages.imp.inc'}
{ ���������� ������� ���� ��������� }
{$I 'TCategorieType.imp.inc'}
{ ���������� ������� ������� ��������� }
{$I 'TCategorieStatus.imp.inc'}
{ ���������� ������� ��������� }
{$I 'TCategorie.imp.inc'}
{$I 'TCategories.imp.inc'}
{ ���������� ������� ��������� ����� }
{$I 'TKeyWord.imp.inc'}
{$I 'TKeyWords.imp.inc'}
{ ���������� ������� ���� ������ }
{$I 'TPackageType.imp.inc'}
{ ���������� ������� ������� ������ }
{$I 'TPackageStatus.imp.inc'}
{ ���������� ������� ������ }
{$I 'TPackage.imp.inc'}
{$I 'TPackages.imp.inc'}
{ ���������� ������ ������������� }
{$I 'UsersList.imp.inc'}
{ ���������� ������ ��������� }
{$I 'CategoriesTree.imp.inc'}
{ ���������� ������ ��������� }
{$I 'MessagesList.imp.inc'}

var
    DATABASE       : TSQLiteDatabase;
    RootCategories : TCategories;

function GetPckTypeExternal (const anID: TID) : ShortString;
begin
    Result := '';
    if ( anID >= Low (PACKAGE_TYPE) ) and ( anID <= High (PACKAGE_TYPE) ) then
        Result := PACKAGE_TYPE [anID];
end;

procedure UpdateMailData (const anUser: TUser);
begin
    if Assigned (MainForm) then
        MainForm.UpdateMailData (anUser);
end;

procedure SetMailData (const anObject: TMetaObject);
begin
    if Assigned (MainForm) then
        MainForm.SetMailData (anObject);
end;

procedure SetTabStatus (const aTabIndex: Integer; const aStatus: Integer);
begin
    if Assigned (MainForm) and
       ( aTabIndex >= tabForum ) and
       ( aTabIndex <= tabMail ) then
    with MainForm.tabs.Pages [aTabIndex] do
    begin
        Tag := aStatus;
        if ( aTabIndex = tabForum ) then
            case aStatus of
                tbsEmpty  : ImageIndex := 1;
                else        ImageIndex := 0;
            end;
    end;
end;

function GetTabStatus (const aTabIndex: Integer) : Integer;
begin
    Result := -1;
    if Assigned (MainForm) and
       ( aTabIndex >= tabForum ) and
       ( aTabIndex <= tabMail ) then
        Result := MainForm.tabs.Pages [aTabIndex].Tag;
end;

initialization
{ ���� �� }
    DATABASE_FILE_NAME := ExtractFilePath (Application.ExeName) + 'database.db';
{ ����������� }
    if not SignIn (DATABASE_FILE_NAME,'') then
    begin
        FreeAndNil (User);
        Application.Terminate;
        Exit;
    end
    else
    begin
        USER_ID := User.ID;
        USER_KEY_HASH := User.KeyHash;
    end;
    // ���������� ����� � ������������ ����������
    Application.Title := User.Login;
{ ������������� �� }
    DATABASE := TSQLiteDatabase.Create (DATABASE_FILE_NAME);
    try
        { ���������� ����� ��������� }
        TCategorieType.Save (DATABASE,[ CATEGORIE_ROOT_TYPE_ID,  'ROOT',  'Root Categorie Type'  ]);
        TCategorieType.Save (DATABASE,[ CATEGORIE_FORUM_TYPE_ID, 'FORUM', 'Forum Categorie Type' ]);
        TCategorieType.Save (DATABASE,[ CATEGORIE_TOPIC_TYPE_ID, 'TOPIC', 'Topic Categorie Type' ]);
        { ���������� �������� ��������� }
        TCategorieStatus.Save (DATABASE,[ CATEGORIE_OPENED_STATUS_ID,  'OPENED',  'Opened Categorie Status' ]);
        TCategorieStatus.Save (DATABASE,[ CATEGORIE_CLOSED_STATUS_ID,  'CLOSED',  'Closed Categorie Status' ]);
        TCategorieStatus.Save (DATABASE,[ CATEGORIE_DELETED_STATUS_ID, 'DELETED', 'Deleted Categorie Status' ]);
        { ����� ��� �������� �������� ��������� }
        ROOT_CATEGORIE_ID := 0;
        RootCategories := TCategories.Load (DATABASE,[ _([]),
                                                       _([0]),
                                                       _([USER_ID]),
                                                       _([USER_ID]),
                                                       _([CATEGORIE_ROOT_TYPE_ID]) ]) as TCategories;
        if Assigned (RootCategories) and ( RootCategories.Count > 0 ) then
        begin
            ROOT_CATEGORIE_ID := RootCategories.ItemAt [0].ID;
            ROOT_CATEGORIE_KEY_HASH := RootCategories.ItemAt [0].KeyHash;
        end
        else
        begin
            with TCategorie.Create (DATABASE,[0,0,USER_ID,USER_ID,CATEGORIE_ROOT_TYPE_ID,CATEGORIE_OPENED_STATUS_ID]) do
            try
                Name := 'ROOT';
                Description := 'Root Categorie';
                Save;
                ROOT_CATEGORIE_ID := ID;
                ROOT_CATEGORIE_KEY_HASH := KeyHash;
                //ShowMessageFmt ('Root Categorie ID = %d',[ROOT_CATEGORIE_ID]);
            finally
                Free;
            end;
        end;
        { ���������� ����� ��������� }
        TMessageType.Save (DATABASE,[ MESSAGE_FORUM_TYPE_ID,   'FORUM',   'Forum Message Type'   ]);
        TMessageType.Save (DATABASE,[ MESSAGE_PRIVATE_TYPE_ID, 'PRIVATE', 'Private Message Type' ]);
        TMessageType.Save (DATABASE,[ MESSAGE_PUBLIC_TYPE_ID,  'PUBLIC',  'Public Message Type'  ]);
        { ���������� �������� ��������� }
        TMessageStatus.Save (DATABASE,[ MESSAGE_ACTIVE_STATUS_ID,  'OPENED', 'Active Message Status'  ]);
        TMessageStatus.Save (DATABASE,[ MESSAGE_DELETED_STATUS_ID, 'CLOSED', 'Deleted Message Status' ]);
        { ���������� ����� ������� }
        TPackageType.Save (DATABASE,[ PACKAGE_GET_TYPE_ID, 'GET', 'Get object'       ]);
        TPackageType.Save (DATABASE,[ PACKAGE_PUT_TYPE_ID, 'PUT', 'Put object'       ]);
        TPackageType.Save (DATABASE,[ PACKAGE_DEL_TYPE_ID, 'DEL', 'Delete object'    ]);
        TPackageType.Save (DATABASE,[ PACKAGE_UPD_TYPE_ID, 'UPD', 'Update objects'   ]);
        { ���������� �������� ������� }
        TPackageStatus.Save (DATABASE,[ PACKAGE_CREATED_STATUS_ID,  'CREATED',  'Created Package Status'  ]);
        TPackageStatus.Save (DATABASE,[ PACKAGE_SENDED_STATUS_ID,   'SENDED',   'Sended Package Status'   ]);
        TPackageStatus.Save (DATABASE,[ PACKAGE_RECEIVED_STATUS_ID, 'RECEIVED', 'Received Package Status' ]);
        TPackageStatus.Save (DATABASE,[ PACKAGE_REJECTED_STATUS_ID, 'REJECTED', 'Rejected Package Status' ]);
        TPackageStatus.Save (DATABASE,[ PACKAGE_EXECUTED_STATUS_ID, 'EXECUTED', 'Executed Package Status' ]);
    finally
        FreeAndNil (RootCategories);
        FreeAndNil (DATABASE);
    end;

finalization
    FreeAndNil (User);


end.
