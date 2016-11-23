unit uPOP3Client;
{******************************************************************************}
{*  Package POP3 Client Unit                                                  *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2012                                             *}
{******************************************************************************}
interface

{$I 'std.inc'}

uses
    Windows, SysUtils, Variants, Classes,
    Controls, ComCtrls, Gauges,
    sListView,
{ utils }
    DateUtils, Utils, Strings, VarRecs, Versions, EClasses,
    DllThreads,
{ synapse }
    WinSock, BlckSock, SynaUtil, POP3Send,
    PingSend,
{ pop3 }
    POP3Client,
{ kernel }
    Kernel, ProtoClasses, CryptoClasses, MetaClasses, ParaClasses,
    HypoClasses, HyperClasses,
{ engine }
    Engine,
{ SQLite }
    SQLite3, SQLite3DLL, SQLiteTable3;

{ ������ }
const
    pckDefault = 0;
    pckEmpty   = 1;
    pckFull    = 2;
    pckTest    = 3;
    pckError   = 4;
    pckSend    = 5;
    pckReceive = 6;

type
    PLogRecord = ^TLogRecord;
    TLogRecord = packed record
        Caption    : ShortString;
        ImageIndex : Integer;
        Sender     : ShortString;
        Receiver   : ShortString;
        Message    : ShortString;
    end;

type
{ ������ pop3-������� }
{$M+}
    EPOP3ClientError = class (EThreadError) end;
{$M-}

{ ����� ��������� ������� }
{$M+}
    CPOP3PackageClient = class of TPOP3PackageClient;
    PPOP3PackageClient = ^TPOP3PackageClient;
    TPOP3PackageClient = class (TDllThread)
    public
        class procedure _raise (anArgs: array of const;
                                const anEGUID: String = ''); override;
        class procedure _raise (anArgs: array of const;
                                anEGUID: array of const); override;
    private
        f_POP3: TPOP3Client;         { ������ }
        f_Host: String;              { pop3-���� }
        f_Port: WORD;                { pop3-���� }
        f_Login: String;             { ����� ����� }
        f_Password: String;          { ������ ����� }
        f_AutoTLS: Boolean;          { auto tls }
        f_FullSSL: Boolean;          { full ssl }
        f_ProxyHost: String;         { ���� proxy-������� }
        f_ProxyPort: WORD;           { ���� proxy-������� }
        f_ProxyLogin: String;        { ����� �� proxy-������ }
        f_ProxyPassword: String;     { ������ �� proxy-������ }
        f_ProxyProtocol: String;     { �������� proxy-������� }
        f_TimeOut: LongWord;         { ����� �������� ms }
        f_DBFileName: String;        { ���� ���� ������ }
        f_DB: TSQLiteDatabase;       { ������ ���� ������ }
        f_ListView: TsListView;      { ��� }
        f_Gauge: TGauge;             { ���������� ��������� �������� }
        f_StatusPanel: TStatusPanel; { ������ ��������� �������� }
        f_MailCount: LongInt;        { ������ �������� ����� }
        f_MailIndex: LongInt;        { ������� � ������ ������ }
        f_IdleTime: LongInt;         { ����� �������� ����� ��������� }
    private
        f_Log: TItems;
        f_Status: String;
        f_MaxProgress: WORD;
        f_Progress: WORD;
    public
        // DBFileName, Host, Port, Login, Password, AutoTLS, FullSSL,
        // ListView, Gauge, StatusPanel, TimeOut,
        // ProxyHost, ProxyPort, ProxyLogin, ProxyPassword, ProxyProtocol
        constructor Create (anArgs: array of const); override;
        destructor Destroy; override;
    public
        procedure Main; override;
        procedure Return; override;
    protected
        procedure WriteStatus (const aMessage: String); overload;
        procedure WriteStatus (const aMessage: String;
                               aParams: array of const); overload;
        procedure WriteLog (const aSender: String;
                            const aReceiver: String;
                            const aMessage: String;
                            const anImageIndex: Integer = pckDefault;
                            const aPackageType: String = '';
                            const aMetaClassID: String = ''); overload;
        procedure WriteLog (const aSender: String;
                            const aReceiver: String;
                            const aMessage: String;
                            aParams: array of const;
                            const anImageIndex: Integer = pckDefault;
                            const aPackageType: String = '';
                            const aMetaClassID: String = ''); overload;
    public
        property POP3: TPOP3Client read f_POP3 write f_POP3;
        property Host: String read f_Host write f_Host;
        property Port: WORD read f_Port write f_Port;
        property Login: String read f_Login write f_Login;
        property Password: String read f_Password write f_Password;
        property AutoTLS: Boolean read f_AutoTLS write f_AutoTLS;
        property FullSSL: Boolean read f_FullSSL write f_FullSSL;
        property ProxyHost: String read f_ProxyHost write f_ProxyHost;
        property ProxyPort: WORD read f_ProxyPort write f_ProxyPort;
        property ProxyLogin: String read f_ProxyLogin write f_ProxyLogin;
        property ProxyPassword: String read f_ProxyPassword write f_ProxyPassword;
        property ProxyProtocol: String read f_ProxyProtocol write f_ProxyProtocol;
        property TimeOut: LongWord read f_TimeOut write f_TimeOut;
        property DBFileName: String read f_DBFileName;
        property DB: TSQLiteDatabase read f_DB write f_DB;
        property ListView: TsListView read f_ListView write f_ListView;
        property Gauge: TGauge read f_Gauge write f_Gauge;
        property StatusPanel: TStatusPanel read f_StatusPanel write f_StatusPanel;
        property MailCount: LongInt read f_MailCount write f_MailCount;
        property MailIndex: LongInt read f_MailIndex write f_MailIndex;
        property IdleTime: LongInt read f_IdleTime write f_IdleTime;
        property Log: TItems read f_Log write f_Log;
        property Status: String read f_Status write f_Status;
        property MaxProgress: WORD read f_MaxProgress write f_MaxProgress;
        property Progress: WORD read f_Progress write f_Progress;
    end;
{$M-}

{ TPOP3PackageClient Errors }
resourcestring
    ERR_TPOP3PACKAGECLIENT_INCORRECT_DATABASE     = '�� ��������������� ������ ��!';
    ERR_TPOP3PACKAGECLIENT_INVALID_HOST           = '������������ smtp-����!';
    ERR_TPOP3PACKAGECLIENT_INVALID_PORT           = '������������ smtp-����!';
    ERR_TPOP3PACKAGECLIENT_INVALID_LOGIN          = '������������ ����� � smtp-�������!';
    ERR_TPOP3PACKAGECLIENT_INVALID_PROXY_HOST     = '������������ proxy-����!';
    ERR_TPOP3PACKAGECLIENT_INVALID_PROXY_PORT     = '������������ proxy-����!';
    ERR_TPOP3PACKAGECLIENT_INVALID_PROXY_PROTOCOL = '������������ proxy-��������!';
    ERR_TPOP3PACKAGECLIENT_INVALID_TIMEOUT        = '������������ ������� ��� ����������!';
    ERR_TPOP3PACKAGECLIENT_INVALID_DATA           = '������������ ������!';
    ERR_TPOP3PACKAGECLIENT_CREATE                 = '������ �������� ������ ��������� �������!';
    ERR_TPOP3PACKAGECLIENT_DESTROY                = '������ ����������� ������ ��������� �������!';
    ERR_TPOP3PACKAGECLIENT_MAIN                   = '������ ���������� ������� ������� ������ ��������� �������!';
    ERR_TPOP3PACKAGECLIENT_RETURN                 = '������ ���������� ������� �������� ������ ��������� �������!';
    ERR_TPOP3PACKAGECLIENT_WRITE_STATUS           = '������ ����������� �������!';
    ERR_TPOP3PACKAGECLIENT_WRITE_LOG              = '������ ������ � ���!';
    ERR_TPOP3PACKAGECLIENT_DELETE_MAIL            = '������ �������� ������ # %d.';
    ERR_TPOP3PACKAGECLIENT_LOAD_PACKAGES          = '������ �������� ������� �� ������!';
    ERR_TPOP3PACKAGECLIENT_INVALID_PACKAGE        = '������� ������������ �����!';

{ TPOP3PackageClient Hints }
resourcestring
    MSG_TPOP3PACKAGECLIENT_SAVED_PACKAGE          = '������� ����� ''%s''.';

implementation

{ TPOP3PackageClient }
class procedure TPOP3PackageClient._raise (anArgs: array of const;
                                           const anEGUID: String = '');
begin
    raise EPOP3ClientError.Create ( _([self],anArgs), anEGUID );
end;

class procedure TPOP3PackageClient._raise (anArgs: array of const;
                                           anEGUID: array of const);
begin
    raise EPOP3ClientError.Create ( _([self],anArgs), anEGUID );
end;

constructor TPOP3PackageClient.Create (anArgs: array of const);
var
    I    : Integer;
    args : array_of_const;
    OBJ  : TObject;
begin
    try
        { �������� ��������� �������� �������� ������,
          ������� � ������������ ��������� }
        if ( High (anArgs) >= 16 ) then
        begin
            SetLength ( Args, High (anArgs)-16 +1 );
            for I := 16 to High (anArgs) do
                args [I-16] := anArgs [I];
        end
        else
            args := _array_of_const ([]);
        inherited Create (args);
        { ���� ��������� �� ������������� ����������� ������ �� ��������� ������ }
        FreeOnTerminate := TRUE;
        { ��� ������ }
        Name := ClassName;
        { ��������� }
        Priority := tpIdle;
        { ������ �������� - ���� �� }
        f_DBFileName := '';
        f_DB := NIL;
        if notEmpty (0,anArgs) then
        begin
            f_DBFileName := toString (anArgs [0]);
            f_DB := TSQLiteDatabase.Create (f_DBFileName);
        end;
        if ( not Assigned (f_DB) ) then
            raise Exception.Create (ERR_TPOP3PACKAGECLIENT_INCORRECT_DATABASE);
        { ������ �������� - ���� smtp-������� }
        f_Host := '';
        if notEmpty (1,anArgs) then
        begin
            f_Host := toString (anArgs [1]);
        end;
        if isEmpty (Host) {or not isIPAddress (Host)} then
            raise Exception.Create (ERR_TPOP3PACKAGECLIENT_INVALID_HOST);
        { ������ �������� - ���� smtp-������� }
        f_Port := 0;
        if notEmpty (2,anArgs) then
        begin
            f_Port := toInteger (anArgs [2]);
        end;
        if ( Port <= 0 ) and ( Host <> '' ) then
            raise Exception.Create (ERR_TPOP3PACKAGECLIENT_INVALID_PORT);
        { ��������� �������� - ����� � smtp-������� }
        f_Login := '';
        if notEmpty (3,anArgs) then
        begin
            f_Login := toString (anArgs [3]);
        end;
        if isEmpty (Login) then
            raise Exception.Create (ERR_TPOP3PACKAGECLIENT_INVALID_LOGIN);
        { ����� �������� - ������ � smtp-������� }
        f_Password := '';
        if notEmpty (4,anArgs) then
        begin
            f_Password := toString (anArgs [4]);
        end;
        { ������ �������� - AutoTLS }
        f_AutoTLS := FALSE;
        if notEmpty (5,anArgs) then
        begin
            f_AutoTLS := toBoolean (anArgs [5]);
        end;
        { ������� �������� - FullSSL }
        f_FullSSL := FALSE;
        if notEmpty (6,anArgs) then
        begin
            f_FullSSL := toBoolean (anArgs [6]);
        end;
        { ������� �������� - ListView
          ��� ����� }
        f_ListView := NIL;
        if notEmpty (7,anArgs) then
        begin
            OBJ := toObject (anArgs [7]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TsListView) ) then
                f_ListView := TsListView (OBJ);
        end;
        { ������� �������� - Gauge
          ���������� ��������� �������� }
        f_Gauge := NIL;
        if notEmpty (8,anArgs) then
        begin
            OBJ := toObject (anArgs [8]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TControl) ) then
                f_Gauge := TGauge (OBJ);
        end;
        { ������� �������� - StatusPanel
          ���������� ��������� �������� }
        f_StatusPanel := NIL;
        if notEmpty (9,anArgs) then
        begin
            OBJ := toObject (anArgs [9]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TStatusPanel) ) then
                f_StatusPanel := TStatusPanel (OBJ);
        end;
        { ������������ �������� - ����� �������� ms }
        f_TimeOut := 120000;
        if notEmpty (10,anArgs) then
        begin
            f_TimeOut := toInteger (anArgs [10]);
        end;
        if ( TimeOut = 0 ) then
            raise Exception.Create (ERR_TPOP3PACKAGECLIENT_INVALID_TIMEOUT);
        { ����������� �������� - ���� proxy-������� }
        f_ProxyHost := '';
        if notEmpty (11,anArgs) then
        begin
            f_ProxyHost := toString (anArgs [11]);
        end;
        if ( ProxyHost <> '' ) and not isIPAddress (ProxyHost) then
            raise Exception.Create (ERR_TPOP3PACKAGECLIENT_INVALID_PROXY_HOST);
        { ����������� �������� - ���� proxy-������� }
        f_ProxyPort := 0;
        if notEmpty (12,anArgs) then
        begin
            f_ProxyPort := toInteger (anArgs [12]);
        end;
        if ( ProxyPort <= 0 ) and ( ProxyHost <> '' ) then
            raise Exception.Create (ERR_TPOP3PACKAGECLIENT_INVALID_PROXY_PORT);
        { ������������� �������� - ����� proxy-������� }
        f_ProxyLogin := '';
        if notEmpty (13,anArgs) then
        begin
            f_ProxyLogin := toString (anArgs [13]);
        end;
        { ����������� �������� - ������ proxy-������� }
        f_ProxyPassword := '';
        if notEmpty (14,anArgs) then
        begin
            f_ProxyPassword := toString (anArgs [14]);
        end;
        { ������������ �������� - �������� proxy-������� }
        f_ProxyProtocol := '';
        if notEmpty (15,anArgs) then
        begin
            f_ProxyProtocol := toString (anArgs [15]);
        end;
        { ������ }
        f_POP3 := TPOP3Client.Create ([Host,Port,
                                       Login,Password,
                                       ProxyHost,ProxyPort,
                                       ProxyLogin,ProxyPassword,
                                       ProxyProtocol,
                                       TimeOut,
                                       AutoTLS,
                                       FullSSL]);
        { ������ ����� }
        f_MailCount := -1;
        f_MailIndex := -1;
        { ����� �������� }
        f_IdleTime := -1;
        { ��� }
        f_Log := TItems.Create ([]);
    except on E: Exception do
        _raise ([ 'Create', ERR_TPOP3PACKAGECLIENT_CREATE, E, Exception (FatalException) ],
                ['{8BE36B7C-F038-43C2-A8C9-B67257106D87}']);
    end;
end;

destructor TPOP3PackageClient.Destroy;
begin
    try
        try
            _FillChar ( f_Host, Length (f_Host), $00 );
            f_Port := 0;
            _FillChar ( f_Login, Length (f_Login), $00 );
            _FillChar ( f_Password, Length (f_Password), $00 );
            _FillChar ( f_ProxyHost, Length (f_ProxyHost), $00 );
            f_ProxyPort := 0;
            _FillChar ( f_ProxyLogin, Length (f_ProxyLogin), $00 );
            _FillChar ( f_ProxyPassword, Length (f_ProxyPassword), $00 );
            FreeAndNil (f_Log);
            FreeAndNil (f_POP3);
            FreeAndNil (f_DB);
        finally
            inherited Destroy;
        end;
    except on E: Exception do
        _raise ([ 'Destroy', ERR_TPOP3PACKAGECLIENT_DESTROY, E, Exception (FatalException) ],
                ['{B2747A00-DFA5-413A-BD29-AA8EFE2CA82C}']);
    end;
end;

procedure TPOP3PackageClient.Main;
var
    Sender    : String;
    Subject   : String;
    Stream    : TStream;
    TimeStamp : TDateTime;
    UserAgent : String;
    Packages  : TPackages;
    I         : Integer;
begin
    try
        if Terminated then Exit;
        inherited Main;
        if not ( MailCount > 0 ) then
        begin
            POP3.Clear;
            MailCount := POP3.GetCount;
            MailIndex := -1;
        end;
        // ������ ����� ��������� ��������, ����� �� ����������� ����
        // ������ ���������� ���������� � �������� �����
        Sleep (1);
        if ( MailCount <= 0 ) then
            Terminate
        else if ( MailIndex >= MailCount-1 ) then
            Terminate
        else
        try
            { ������� }
            IdleTime := IdleTime +1;
            if ( IdleTime >= TimeOut div 10 ) then
                IdleTime := -1
            else
                Exit;
            { ����� �������� - ������������ ��������� ����� }
            MailIndex := MailIndex + 1;
            { �������� }
            Progress := Progress + 1;
            { ������ ������ }
            Stream := TMemoryStream.Create;
            try
                if POP3.Load (MailIndex,
                              Sender,
                              Subject,
                              Stream,
                              TimeStamp,
                              UserAgent) then
                begin
                    { ������ ������ }
                    if notEmpty (Subject) then
                    begin
                        _TrimW (Stream,HexSymbols);
                        { ��������� ������ }
                        Packages := TPackages.Create (DB,[]);
                        try
                            try
                                Stream.Position := 0;
                                Packages.LoadFromStream (Stream);
                            except on E: Exception do begin
                                WriteLog ( Format ('%s:%d',
                                                   [ POP3.POP3.Sock.GetRemoteSinIP,
                                                     POP3.POP3.Sock.GetRemoteSinPort ]),
                                           Format ('%s:%d',
                                                   [ POP3.POP3.Sock.GetLocalSinIP,
                                                     POP3.POP3.Sock.GetLocalSinPort ]),
                                           ERR_TPOP3PACKAGECLIENT_LOAD_PACKAGES,
                                           pckError );
                            end; end;
                            for I := 0 to Packages.Count-1 do
                            try
                                { ��������� - ����� �� �����? }
                                if not (  TPackages.Find ( DB,
                                                           Packages.ItemAt [I].KeyHash,
                                                           USER_ID ) > 0  ) then
                                begin
                                    { ������ ����� ����� - ����� ������� }
                                    Packages.ItemAt [I].IDStatus := PACKAGE_RECEIVED_STATUS_ID;
                                    Packages.ItemAt [I].Save;
                                    { ����� � ��� ������ ������ }
                                    WriteLog ( Format ('%s:%d',
                                                       [ POP3.POP3.Sock.GetRemoteSinIP,
                                                         POP3.POP3.Sock.GetRemoteSinPort ]),
                                               Format ('%s:%d',
                                                       [ POP3.POP3.Sock.GetLocalSinIP,
                                                         POP3.POP3.Sock.GetLocalSinPort ]),
                                               Format (MSG_TPOP3PACKAGECLIENT_SAVED_PACKAGE,
                                                       [ Packages.ItemAt [I].KeyHash ]),
                                               pckReceive,
                                               GetPckTypeExternal (Packages.ItemAt [I].IDType),
                                               Packages.ItemAt [I].MetaClass.GetClassID );
                                end;
                            except on SaveError: Exception do begin
                                if Assigned (Packages.ItemAt [I]) then
                                begin
                                    { ����� � ��� ������� ������ }
                                    WriteLog ( Format ('%s:%d',
                                                       [ POP3.POP3.Sock.GetRemoteSinIP,
                                                         POP3.POP3.Sock.GetRemoteSinPort ]),
                                               Format ('%s:%d',
                                                       [ POP3.POP3.Sock.GetLocalSinIP,
                                                         POP3.POP3.Sock.GetLocalSinPort ]),
                                               Format ('%s : %s',
                                                       [ ERR_TPOP3PACKAGECLIENT_INVALID_PACKAGE,
                                                         SaveError.Message ]),
                                               pckError );
                                end
                                else
                                    WriteStatus (SaveError.Message);
                            end; end;
                        finally
                            FreeAndNil (Packages);
                        end;
                    end;
                    { ������� ����������� ������ }
                    if not POP3.Delete (MailIndex) then
                        raise Exception.CreateFmt (ERR_TPOP3PACKAGECLIENT_DELETE_MAIL,
                                                   [MailIndex+1]);
                end;
            finally
                FreeAndNil (Stream);
                _FillChar ( Sender, Length (Sender), $00 );
                _FillChar ( Subject, Length (Subject), $00 );
                _FillChar ( UserAgent, Length (UserAgent), $00 );
                TimeStamp := 0.0;
            end;
        except on Error: Exception do
            WriteStatus (Error.Message);
        end;
    except on E: Exception do
        _raise ([ 'Main', ERR_TPOP3PACKAGECLIENT_MAIN, E, Exception (FatalException) ],
                ['{D6DC0E72-884F-4442-9E1C-0858CA206865}']);
    end;
end;

procedure TPOP3PackageClient.Return;
var
    Itm        : TListItem;
    ImageIndex : Integer;
begin
    try
        inherited Return;
        if Assigned (ListView) and Assigned (Log) then
        begin
            while Log.Count > 0 do
            begin
                Itm := ListView.Items.Add;
                Itm.Caption := PLogRecord (Log.Item [0])^.Caption;
                Itm.ImageIndex := PLogRecord (Log.Item [0])^.ImageIndex;
                Itm.SubItems.Add ( PLogRecord (Log.Item [0])^.Sender );
                Itm.SubItems.Add ( PLogRecord (Log.Item [0])^.Receiver );
                Itm.SubItems.Add ( PLogRecord (Log.Item [0])^.Message );
                Dispose ( PLogRecord (Log.Item [0]) );
                Log.Delete (0);
            end;
        end;
        if Assigned (StatusPanel) and notEmpty (Status) then
        begin
            StatusPanel.Text := Status;
        end;
        if Assigned (Gauge) then
        begin
            Gauge.MinValue := 0;
            Gauge.MaxValue := MaxProgress;
            Gauge.Progress := Progress;
        end;
        ProcessMessages;
    except on E: Exception do
        _raise ([ 'Return', ERR_TPOP3PACKAGECLIENT_RETURN, E, Exception (FatalException) ],
                ['{65CAB000-93F5-4C20-AAB0-49B73FF33D9D}']);
    end;
end;


procedure TPOP3PackageClient.WriteStatus (const aMessage: String);
begin
    try
        Status := aMessage;
    except on E: Exception do
        _raise (['WriteStatus',ERR_TPOP3PACKAGECLIENT_WRITE_STATUS,E],
                ['{91593C8D-58FD-4F73-8999-E5EA155BA36F}']);
    end;
end;

procedure TPOP3PackageClient.WriteStatus (const aMessage: String;
                                                aParams: array of const);
begin
    try
        WriteStatus ( Format (aMessage,aParams) );
    except on E: Exception do
        _raise (['WriteStatus',ERR_TPOP3PACKAGECLIENT_WRITE_STATUS,E],
                ['{F1632684-1405-4B31-960F-5CC62C5FE0A0}']);
    end;
end;

procedure TPOP3PackageClient.WriteLog (const aSender: String;
                                       const aReceiver: String;
                                       const aMessage: String;
                                       const anImageIndex: Integer = pckDefault;
                                       const aPackageType: String = '';
                                       const aMetaClassID: String = '');
var
    Rec : PLogRecord;
begin
    try
        if Assigned (Log) then
        begin
            Rec := AllocMem ( SizeOf (TLogRecord) + 1 );
            Rec^.Caption := _DateTimeToStr (now);
            Rec^.ImageIndex := anImageIndex;
            Rec^.Sender := aSender;
            Rec^.Receiver := aReceiver;
            if notEmpty (aMetaClassID) then
                Rec^.Message := Format ('%s : %s : %s',[aMetaClassID,aPackageType,aMessage])
            else
                Rec^.Message := aMessage;
            Log.Add (Rec);
        end;
    except on E: Exception do
        _raise (['WriteLog',ERR_TPOP3PACKAGECLIENT_WRITE_LOG,E],
                ['{546A187F-F452-4840-B2C2-8C82D2D74A11}']);
    end;
end;

procedure TPOP3PackageClient.WriteLog (const aSender: String;
                                       const aReceiver: String;
                                       const aMessage: String;
                                       aParams: array of const;
                                       const anImageIndex: Integer = pckDefault;
                                       const aPackageType: String = '';
                                       const aMetaClassID: String = '');
begin
    try
        WriteLog ( aSender, aReceiver, Format (aMessage,aParams), anImageIndex, aPackageType, aMetaClassID );
    except on E: Exception do
        _raise (['WriteLog',ERR_TPOP3PACKAGECLIENT_WRITE_LOG,E],
                ['{E6C8F886-56BB-4AE3-9396-A0AD6CFA5582}']);
    end;
end;

end.