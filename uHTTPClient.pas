unit uHTTPClient;
{******************************************************************************}
{*  Package HTTP Client Unit                                                  *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2011-2012                                        *}
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
    WinSock, BlckSock, SynaUtil, HTTPSend,
    PingSend,
{ http }
    HTTPClient,
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
{ ������ http-������� }
{$M+}
    EHTTPClientError = class (EThreadError) end;
{$M-}

{ ����� ��������� ������� }
{$M+}
    CHTTPPackageClient = class of THTTPPackageClient;
    PHTTPPackageClient = ^THTTPPackageClient;
    THTTPPackageClient = class (TDllThread)
    public
        class procedure _raise (anArgs: array of const;
                                const anEGUID: String = ''); override;
        class procedure _raise (anArgs: array of const;
                                anEGUID: array of const); override;
    private
        f_Threads: TDllThreads;      { �������� ������ }
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
        f_Users: TUsers;             { ������ ��������� � �������� }
        f_UserIndex: LongInt;        { ������� � ������ ������ }
    public
        // DBFileName, ListView, Gauge, StatusPanel, TimeOut, ProxyHost, ProxyPort, ProxyLogin, ProxyPassword, ProxyProtocol
        constructor Create (anArgs: array of const); override;
        destructor Destroy; override;
    public
        procedure Main; override;
        procedure Return; override;
    protected
        procedure WriteStatus (const aMessage: String); overload;
        procedure WriteStatus (const aMessage: String;
                               aParams: array of const); overload;
    public
        property Threads: TDllThreads read f_Threads write f_Threads;
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
        property Users: TUsers read f_Users write f_Users;
        property UserIndex: LongInt read f_UserIndex write f_UserIndex;
    end;
{$M-}

{ �������� ����� ��������� ������� }
{$M+}
    CHTTPPackageClientThread = class of THTTPPackageClientThread;
    PHTTPPackageClientThread = ^THTTPPackageClientThread;
    THTTPPackageClientThread = class (TDllThread)
    public
        class procedure _raise (anArgs: array of const;
                                const anEGUID: String = ''); override;
        class procedure _raise (anArgs: array of const;
                                anEGUID: array of const); override;
    private
        f_HTTP: THTTPClient;         { ������ }
        f_ProxyHost: String;         { ���� proxy-������� }
        f_ProxyPort: WORD;           { ���� proxy-������� }
        f_ProxyLogin: String;        { ����� �� proxy-������ }
        f_ProxyPassword: String;     { ������ �� proxy-������ }
        f_ProxyProtocol: String;     { �������� proxy-������� }
        f_TimeOut: LongWord;         { ����� �������� ms }
        f_DBFileName: String;        { ���� ���� ������ }
        f_DB: TSQLiteDatabase;       { ������ ���� ������ }
        f_ReceiverID: TID;           { ������������� ���������� }
        f_Receiver: TUser;           { ���������� }
        f_ListView: TsListView;      { ��� }
        f_Gauge: TGauge;             { ���������� ��������� �������� }
        f_StatusPanel: TStatusPanel; { ������ ��������� �������� }
        f_Packages: TPackages;       { ������ ������� ��� �������� }
        f_PackageIndex: LongInt;     { ������� � ������ ������ }
        f_IdleTime: LongInt;         { ����� �������� ����� ��������� }
    private
        f_Log: TItems;
        f_Status: String;
        f_MaxProgress: WORD;
        f_Progress: WORD;
    public
        // DBFileName, ReceiverID, ListView, Gauge, StatusPanel, TimeOut, ProxyHost, ProxyPort, ProxyLogin, ProxyPassword, ProxyProtocol
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
        property HTTP: THTTPClient read f_HTTP;
        property ProxyHost: String read f_ProxyHost write f_ProxyHost;
        property ProxyPort: WORD read f_ProxyPort write f_ProxyPort;
        property ProxyLogin: String read f_ProxyLogin write f_ProxyLogin;
        property ProxyPassword: String read f_ProxyPassword write f_ProxyPassword;
        property ProxyProtocol: String read f_ProxyProtocol write f_ProxyProtocol;
        property TimeOut: LongWord read f_TimeOut write f_TimeOut;
        property DBFileName: String read f_DBFileName;
        property DB: TSQLiteDatabase read f_DB write f_DB;
        property ReceiverID: TID read f_ReceiverID write f_ReceiverID;
        property Receiver: TUser read f_Receiver;
        property ListView: TsListView read f_ListView write f_ListView;
        property Gauge: TGauge read f_Gauge write f_Gauge;
        property StatusPanel: TStatusPanel read f_StatusPanel write f_StatusPanel;
        property Packages: TPackages read f_Packages write f_Packages;
        property PackageIndex: LongInt read f_PackageIndex write f_PackageIndex;
        property IdleTime: LongInt read f_IdleTime write f_IdleTime;
        property Log: TItems read f_Log write f_Log;
        property Status: String read f_Status write f_Status;
        property MaxProgress: WORD read f_MaxProgress write f_MaxProgress;
        property Progress: WORD read f_Progress write f_Progress;
    end;
{$M-}

{ THTTPPackageClient Errors }
resourcestring
    ERR_THTTPPACKAGECLIENT_INCORRECT_DATABASE     = '�� ��������������� ������ ��!';
    ERR_THTTPPACKAGECLIENT_INVALID_PROXY_HOST     = '������������ proxy-����!';
    ERR_THTTPPACKAGECLIENT_INVALID_PROXY_PORT     = '������������ proxy-����!';
    ERR_THTTPPACKAGECLIENT_INVALID_PROXY_PROTOCOL = '������������ proxy-��������!';
    ERR_THTTPPACKAGECLIENT_INVALID_TIMEOUT        = '������������ ������� ��� ����������!';
    ERR_THTTPPACKAGECLIENT_CREATE                 = '������ �������� ������ ��������� �������!';
    ERR_THTTPPACKAGECLIENT_DESTROY                = '������ ����������� ������ ��������� �������!';
    ERR_THTTPPACKAGECLIENT_MAIN                   = '������ ���������� ������� ������� ������ ��������� �������!';
    ERR_THTTPPACKAGECLIENT_RETURN                 = '������ ������� �������� ��������� �������!';
    ERR_THTTPPACKAGECLIENT_WRITE_STATUS           = '������ ����������� �������!';

{ THTTPPackageClientThread Errors }
resourcestring
    ERR_THTTPPACKAGECLIENTTHREAD_INCORRECT_DATABASE     = '�� ��������������� ������ ��!';
    ERR_THTTPPACKAGECLIENTTHREAD_INVALID_RECEIVER_ID    = '������������ ������������� ����������!';
    ERR_THTTPPACKAGECLIENTTHREAD_INVALID_RECEIVER       = '������������ ����������!';
    ERR_THTTPPACKAGECLIENTTHREAD_INVALID_PROXY_HOST     = '������������ proxy-����!';
    ERR_THTTPPACKAGECLIENTTHREAD_INVALID_PROXY_PORT     = '������������ proxy-����!';
    ERR_THTTPPACKAGECLIENTTHREAD_INVALID_PROXY_PROTOCOL = '������������ proxy-��������!';
    ERR_THTTPPACKAGECLIENTTHREAD_INVALID_TIMEOUT        = '������������ ������� ��� ����������!';
    ERR_THTTPPACKAGECLIENTTHREAD_INVALID_DATA           = '������������ ������!';
    ERR_THTTPPACKAGECLIENTTHREAD_CREATE                 = '������ �������� ��������� ������ ��������� �������!';
    ERR_THTTPPACKAGECLIENTTHREAD_DESTROY                = '������ ����������� ��������� ������ ��������� �������!';
    ERR_THTTPPACKAGECLIENTTHREAD_MAIN                   = '������ ���������� ������� ������� ��������� ������ ��������� �������!';
    ERR_THTTPPACKAGECLIENTTHREAD_RETURN                 = '������ ���������� ������� �������� ��������� ������ ��������� �������!';
    ERR_THTTPPACKAGECLIENTTHREAD_WRITE_STATUS           = '������ ����������� �������!';
    ERR_THTTPPACKAGECLIENTTHREAD_WRITE_LOG              = '������ ������ � ���!';

{ THTTPPackage Hints }
resourcestring
    MSG_THTTPPACKAGE_SEND_TO          = '�������� ������� ��� ''%s''...';
    MSG_THTTPPACKAGE_SEND_ERROR       = '������ �������� ������. HTTP Error: %d';
    MSG_THTTPPACKAGE_SENDED_PACKAGE   = '����� ''%s'' ��������� ����������.';
    MSG_THTTPPACKAGE_RECEIVED_PACKAGE = '����� ''%s'' ��������� ����������.';
    MSG_THTTPPACKAGE_EXECUTED_PACKAGE = '����� ''%s'' ��������� �����������.';
    MSG_THTTPPACKAGE_REJECTED_PACKAGE = '����� ''%s'' ��������� �����������.';

implementation

{ THTTPPackageClient }
class procedure THTTPPackageClient._raise (anArgs: array of const;
                                           const anEGUID: String = '');
begin
    raise EHTTPClientError.Create ( _([self],anArgs), anEGUID );
end;

class procedure THTTPPackageClient._raise (anArgs: array of const;
                                           anEGUID: array of const);
begin
    raise EHTTPClientError.Create ( _([self],anArgs), anEGUID );
end;

constructor THTTPPackageClient.Create (anArgs: array of const);
var
    I    : Integer;
    args : array_of_const;
    OBJ  : TObject;
begin
    try
        { �������� ��������� �������� �������� ������,
          ������� � ������������� ��������� }
        if ( High (anArgs) >= 10 ) then
        begin
            SetLength ( Args, High (anArgs)-10 +1 );
            for I := 10 to High (anArgs) do
                args [I-10] := anArgs [I];
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
            raise Exception.Create (ERR_THTTPPACKAGECLIENT_INCORRECT_DATABASE);
        { ������ �������� - ListView
          ��� ����� }
        f_ListView := NIL;
        if notEmpty (1,anArgs) then
        begin
            OBJ := toObject (anArgs [1]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TsListView) ) then
                f_ListView := TsListView (OBJ);
        end;
        { ������ �������� - Gauge
          ���������� ��������� �������� }
        f_Gauge := NIL;
        if notEmpty (2,anArgs) then
        begin
            OBJ := toObject (anArgs [2]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TControl) ) then
                f_Gauge := TGauge (OBJ);
        end;
        { ��������� �������� - StatusPanel
          ���������� ��������� �������� }
        f_StatusPanel := NIL;
        if notEmpty (3,anArgs) then
        begin
            OBJ := toObject (anArgs [3]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TStatusPanel) ) then
                f_StatusPanel := TStatusPanel (OBJ);
        end;
        { ����� �������� - ����� �������� ms }
        f_TimeOut := 120000;
        if notEmpty (4,anArgs) then
        begin
            f_TimeOut := toInteger (anArgs [4]);
        end;
        if ( TimeOut = 0 ) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENT_INVALID_TIMEOUT);
        { ������ �������� - ���� proxy-������� }
        f_ProxyHost := '';
        if notEmpty (5,anArgs) then
        begin
            f_ProxyHost := toString (anArgs [5]);
        end;
        if ( ProxyHost <> '' ) and not isIPAddress (ProxyHost) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENT_INVALID_PROXY_HOST);
        { ������� �������� - ���� proxy-������� }
        f_ProxyPort := 0;
        if notEmpty (6,anArgs) then
        begin
            f_ProxyPort := toInteger (anArgs [6]);
        end;
        if ( ProxyPort <= 0 ) and ( ProxyHost <> '' ) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENT_INVALID_PROXY_PORT);
        { ������� �������� - ����� proxy-������� }
        f_ProxyLogin := '';
        if notEmpty (7,anArgs) then
        begin
            f_ProxyLogin := toString (anArgs [7]);
        end;
        { ������� �������� - ������ proxy-������� }
        f_ProxyPassword := '';
        if notEmpty (8,anArgs) then
        begin
            f_ProxyPassword := toString (anArgs [8]);
        end;
        { ������� �������� - �������� proxy-������� }
        f_ProxyProtocol := '';
        if notEmpty (9,anArgs) then
        begin
            f_ProxyProtocol := toString (anArgs [9]);
        end;
        { ������� ��������� �������� ������� }
        f_Threads := TDllThreads.Create ([]);
        { ������ ������������� }
        f_Users := NIL;
        f_UserIndex := -1;
    except on E: Exception do
        _raise ([ 'Create', ERR_THTTPPACKAGECLIENT_CREATE, E, Exception (FatalException) ],
                ['{CCF6F48B-3667-4DD9-ADD1-5676797FD0ED}']);
    end;
end;

destructor THTTPPackageClient.Destroy;
begin
    try
        try
            _FillChar ( f_ProxyHost, Length (f_ProxyHost), $00 );
            f_ProxyPort := 0;
            _FillChar ( f_ProxyLogin, Length (f_ProxyLogin), $00 );
            _FillChar ( f_ProxyPassword, Length (f_ProxyPassword), $00 );
            if Assigned (Threads) then
                Threads.Terminate;
            FreeAndNil (f_Threads);
            FreeAndNil (f_Users);
            FreeAndNil (f_DB);
        finally
            inherited Destroy;
        end;
    except on E: Exception do
        _raise ([ 'Destroy', ERR_THTTPPACKAGECLIENT_DESTROY, E, Exception (FatalException) ],
                ['{769B1840-E59A-4FF4-A30E-A31EAFE47018}']);
    end;
end;

procedure THTTPPackageClient.Main;
begin
    try
        if Terminated then Exit;
        inherited Main;
        if not Assigned (Users) then
        try
            f_Users := TUsers.Load (DB,[ _([]),
                                         _([]),
                                         _([USER_ID]) ],
                                       [],
                                       [],
                                       [objSimple]) as TUsers;
        except
            FreeAndNil (f_Users);
        end;
        Sleep (TimeOut{*10});
    except on E: Exception do
        _raise ([ 'Main', ERR_THTTPPACKAGECLIENT_MAIN, E, Exception (FatalException) ],
                ['{0F6AC9B4-8CED-44E8-B8AE-5388F7154BBC}']);
    end;
end;

procedure THTTPPackageClient.Return;
var
    Thr : THTTPPackageClientThread;
begin
    try
        if Terminated then Exit;
        if ( not Assigned (Users) or (Users.Count <= 0) ) then
            Terminate
        else if ( UserIndex >= Users.Count - 1 ) then
        begin
            UserIndex := -1;
        end
        { ���� ���� �� �������� ������� ���������� - ��������� ��� ����� }
        else if ( UserIndex <= Users.Count - 1 ) and
                not Assigned ( Threads.ItemOf [ Users.ItemAt [UserIndex+1].KeyHash ] ) then
        try
            inherited Return;
            UserIndex := UserIndex + 1;
            if {( Users.ItemAt [UserIndex].IP <> '127.0.0.1' ) and}
               ( PingHost (Users.ItemAt [UserIndex].IP) >= 0 ) then
            try
                Thr := THTTPPackageClientThread.Create ([ DBFileName,
                                                          Users.ItemAt [UserIndex].ID,
                                                          ListView,
                                                          Gauge,
                                                          StatusPanel,
                                                          TimeOut,
                                                          ProxyHost, ProxyPort,
                                                          ProxyLogin, ProxyPassword,
                                                          ProxyProtocol,
                                                          FALSE, TRUE,
                                                          TP_IDLE,
                                                          NIL, NIL,
                                                          Users.ItemAt [UserIndex].KeyHash ]);
                if ( Threads.Add (Thr) < 0 ) then
                    FreeAndNil (Thr);
            except
                FreeAndNil (Thr);
            end;
        except on E: Exception do
            WriteStatus (E.Message);
        end;
    except on E: Exception do
        _raise ([ 'Return', ERR_THTTPPACKAGECLIENT_RETURN, E, Exception (FatalException) ],
                ['{C1DE6724-28A6-4B18-8921-1906B006E425}']);
    end;
end;

procedure THTTPPackageClient.WriteStatus (const aMessage: String);
begin
    try
        if Assigned (StatusPanel) then
        begin
            StatusPanel.Text := aMessage;
            ProcessMessages;
        end;
    except on E: Exception do
        _raise (['WriteStatus',ERR_THTTPPACKAGECLIENT_WRITE_STATUS,E],
                ['{42AD2D85-5DAE-4561-B9F6-F68290CC2D65}']);
    end;
end;

procedure THTTPPackageClient.WriteStatus (const aMessage: String;
                                          aParams: array of const);
begin
    try
        WriteStatus ( Format (aMessage,aParams) );
    except on E: Exception do
        _raise (['WriteStatus',ERR_THTTPPACKAGECLIENT_WRITE_STATUS,E],
                ['{1C6E36C5-D670-4274-AA8C-52E2A00BF96A}']);
    end;
end;

{ THTTPPackageClientThread }
class procedure THTTPPackageClientThread._raise (anArgs: array of const;
                                                 const anEGUID: String = '');
begin
    raise EHTTPClientError.Create ( _([self],anArgs), anEGUID );
end;

class procedure THTTPPackageClientThread._raise (anArgs: array of const;
                                                 anEGUID: array of const);
begin
    raise EHTTPClientError.Create ( _([self],anArgs), anEGUID );
end;

constructor THTTPPackageClientThread.Create (anArgs: array of const);
var
    I    : Integer;
    args : array_of_const;
    OBJ  : TObject;
begin
    try
        { �������� ��������� �������� �������� ������,
          ������� � ������������ ��������� }
        if ( High (anArgs) >= 11 ) then
        begin
            SetLength ( Args, High (anArgs)-11 +1 );
            for I := 11 to High (anArgs) do
                args [I-11] := anArgs [I];
        end
        else
            args := _array_of_const ([]);
        inherited Create (args);
        { ���� ��������� �� ������������� ����������� ������ �� ��������� ������ }
        FreeOnTerminate := TRUE;
        { ������ �������� - ���� �� }
        f_DBFileName := '';
        f_DB := NIL;
        if notEmpty (0,anArgs) then
        begin
            f_DBFileName := toString (anArgs [0]);
            f_DB := TSQLiteDatabase.Create (f_DBFileName);
        end;
        if ( not Assigned (f_DB) ) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENTTHREAD_INCORRECT_DATABASE);
        { ������ �������� - ReceiverID
          ������������� ���������� }
        f_ReceiverID := 0;
        if notEmpty (1,anArgs) then
        begin
            f_ReceiverID := toInt64 (anArgs [1]);
        end;
        if not ( ReceiverID > 0 ) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENTTHREAD_INVALID_RECEIVER_ID);
        f_Receiver := TUser.Load (DB,ReceiverID,[objSimple]) as TUser;
        if not Assigned (Receiver) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENTTHREAD_INVALID_RECEIVER);
        { ������ �������� - ListView
          ��� ����� }
        f_ListView := NIL;
        if notEmpty (2,anArgs) then
        begin
            OBJ := toObject (anArgs [2]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TsListView) ) then
                f_ListView := TsListView (OBJ);
        end;
        { ��������� �������� - Gauge
          ���������� ��������� �������� }
        f_Gauge := NIL;
        if notEmpty (3,anArgs) then
        begin
            OBJ := toObject (anArgs [3]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TControl) ) then
                f_Gauge := TGauge (OBJ);
        end;
        { ����� �������� - StatusPanel
          ���������� ��������� �������� }
        f_StatusPanel := NIL;
        if notEmpty (4,anArgs) then
        begin
            OBJ := toObject (anArgs [4]);
            if ( Assigned (OBJ) and OBJ.InheritsFrom (TStatusPanel) ) then
                f_StatusPanel := TStatusPanel (OBJ);
        end;
        { ������ �������� - ����� �������� ms }
        f_TimeOut := 120000;
        if notEmpty (5,anArgs) then
        begin
            f_TimeOut := toInteger (anArgs [5]);
        end;
        if ( TimeOut = 0 ) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENTTHREAD_INVALID_TIMEOUT);
        { ������� �������� - ���� proxy-������� }
        f_ProxyHost := '';
        if notEmpty (6,anArgs) then
        begin
            f_ProxyHost := toString (anArgs [6]);
        end;
        if ( ProxyHost <> '' ) and not isIPAddress (ProxyHost) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENTTHREAD_INVALID_PROXY_HOST);
        { ������� �������� - ���� proxy-������� }
        f_ProxyPort := 0;
        if notEmpty (7,anArgs) then
        begin
            f_ProxyPort := toInteger (anArgs [7]);
        end;
        if ( ProxyPort <= 0 ) and ( ProxyHost <> '' ) then
            raise Exception.Create (ERR_THTTPPACKAGECLIENTTHREAD_INVALID_PROXY_PORT);
        { ������� �������� - ����� proxy-������� }
        f_ProxyLogin := '';
        if notEmpty (8,anArgs) then
        begin
            f_ProxyLogin := toString (anArgs [8]);
        end;
        { ������� �������� - ������ proxy-������� }
        f_ProxyPassword := '';
        if notEmpty (9,anArgs) then
        begin
            f_ProxyPassword := toString (anArgs [9]);
        end;
        { ������������ �������� - �������� proxy-������� }
        f_ProxyProtocol := '';
        if notEmpty (10,anArgs) then
        begin
            f_ProxyProtocol := toString (anArgs [10]);
        end;
        { ������ ������� }
        f_Packages := NIL;
        f_PackageIndex := -1;
        { ������ }
        f_HTTP := THTTPClient.Create ([ Receiver.IP, Receiver.Port,
                                        ProxyHost, ProxyPort,
                                        ProxyLogin, ProxyPassword,
                                        ProxyProtocol,
                                        TimeOut,
                                        'POST', '/',
                                        'Application/hex-stream' ]);
        { ����� �������� }
        f_IdleTime := -1;
        { ��� }
        f_Log := TItems.Create ([]);
    except on E: Exception do
        _raise ([ 'Create', ERR_THTTPPACKAGECLIENTTHREAD_CREATE, E, Exception (FatalException) ],
                ['{FF55D018-CCE7-4B20-8BF1-710450D118AE}']);
    end;
end;

destructor THTTPPackageClientThread.Destroy;
begin
    try
        _FillChar ( f_ProxyHost, Length (f_ProxyHost), $00 );
        f_ProxyPort := 0;
        _FillChar ( f_ProxyLogin, Length (f_ProxyLogin), $00 );
        _FillChar ( f_ProxyPassword, Length (f_ProxyPassword), $00 );
        FreeAndNil (f_Log);
        FreeAndNil (f_HTTP);
        if ( ReceiverID <> USER_ID ) and ( ReceiverID <> 0 ) then
            FreeAndNil (f_Receiver);
        FreeAndNil (f_Packages);
        FreeAndNil (f_DB);
        inherited Destroy;
    except on E: Exception do
        _raise ([ 'Destroy', ERR_THTTPPACKAGECLIENTTHREAD_DESTROY, E, Exception (FatalException) ],
                ['{4545AECC-0B18-4123-B1F0-683F7FDB0335}']);
    end;
end;

procedure THTTPPackageClientThread.Main;
var
    Stream   : TStream;
    KeyHash  : Hex;
    IDStatus : TID;
begin
    try
        if Terminated then Exit;
        inherited Main;
        if not Assigned (Packages) then
        try
            f_Packages := TPackages.Load (DB,[ _([]),
                                               _([{USER_KEY_HASH}]),
                                               _([Receiver.KeyHash]),
                                               _([USER_ID]),
                                               _([]),
                                               _([PACKAGE_CREATED_STATUS_ID]),
                                               _([ TUser, {TPic,} TMessage, TCategorie, TMetaObject ]) ],
                                             [ _pck_time_stamp_create ]) as TPackages;
            MaxProgress := Packages.Count;
            Progress := 0;
        except
            FreeAndNil (f_Packages);
        end;
        // ������ ����� ��������� ��������, ����� �� ����������� ����
        // ������ ���������� ���������� � �������� �����
        Sleep (1);
        if not Assigned (Packages) or ( Packages.Count <= 0 ) then
            Terminate
        else if ( PackageIndex >= Packages.Count-1 ) then
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
            PackageIndex := PackageIndex + 1;
            { �������� }
            Progress := Progress + 1;
            { ���������� ����� }
            if Assigned (Packages.ItemAt [PackageIndex]) then
            begin
                HTTP.Clear;
                Stream := TMemoryStream.Create;
                try
                    Packages.ItemAt [PackageIndex].SaveToStream (Stream);
                    HTTP.InputData.Position := 0;
                    WriteStreamL (HTTP.InputData,Stream);
                finally
                    FreeAndNil (Stream);
                end;
                { ���������� ����� }
                if HTTP.Send then
                begin
                    { ������ ����� ������� }
                    with HTTP.OutputData, HTTP do
                    begin
                        Position := 0;
                        while ( Position < Size ) do
                        try
                            { ������ ������ ������, ������� �������� ��� ���������� }
                            KeyHash := ReadStrL (OutputData);
                            IDStatus := StrToInt (  HexToStr ( ReadStrL (OutputData) )  );
                            if ( Packages.ItemAt [PackageIndex].KeyHash = KeyHash ) then
                            begin
                                case IDStatus of
                                    { ������ ������ ������, ���� �� ������� ��� ���������, �� "������������" }
                                    PACKAGE_RECEIVED_STATUS_ID,
                                    PACKAGE_EXECUTED_STATUS_ID : begin
                                        Packages.ItemAt [PackageIndex].IDStatus := PACKAGE_SENDED_STATUS_ID;
                                        Packages.ItemAt [PackageIndex].Save;
                                    end;
                                    { ����� - ������ ������ ������ �� "�����������" }
                                    else begin
                                        // ������ ������� ������������ �����
                                        Packages.ItemAt [PackageIndex].Delete;
                                        //Packages.ItemAt [PackageIndex].IDStatus := PACKAGE_REJECTED_STATUS_ID;
                                        //Packages.ItemAt [PackageIndex].Save;
                                    end;
                                end;
                                { ����� � ��� ������ ������ }
                                case IDStatus of
                                    PACKAGE_RECEIVED_STATUS_ID :
                                        WriteLog ( Format ('%s:%d',
                                                           [ HTTP.Sock.GetLocalSinIP,
                                                             HTTP.Sock.GetLocalSinPort ]),
                                                   Format ('%s:%d',
                                                           [ HTTP.Sock.GetRemoteSinIP,
                                                             HTTP.Sock.GetRemoteSinPort ]),
                                                   Format (MSG_THTTPPACKAGE_RECEIVED_PACKAGE,
                                                           [ KeyHash ]),
                                                   pckSend,
                                                   Packages.ItemAt [PackageIndex].PckType.IDExternal,
                                                   Packages.ItemAt [PackageIndex].MetaClass.GetClassID );
                                    PACKAGE_EXECUTED_STATUS_ID :
                                        WriteLog ( Format ('%s:%d',
                                                           [ HTTP.Sock.GetLocalSinIP,
                                                             HTTP.Sock.GetLocalSinPort ]),
                                                   Format ('%s:%d',
                                                           [ HTTP.Sock.GetRemoteSinIP,
                                                             HTTP.Sock.GetRemoteSinPort ]),
                                                   Format (MSG_THTTPPACKAGE_EXECUTED_PACKAGE,
                                                           [ KeyHash ]),
                                                   pckFull,
                                                   Packages.ItemAt [PackageIndex].PckType.IDExternal,
                                                   Packages.ItemAt [PackageIndex].MetaClass.GetClassID );
                                    PACKAGE_REJECTED_STATUS_ID :
                                        WriteLog ( Format ('%s:%d',
                                                          [ HTTP.Sock.GetLocalSinIP,
                                                            HTTP.Sock.GetLocalSinPort ]),
                                                   Format ('%s:%d',
                                                           [ HTTP.Sock.GetRemoteSinIP,
                                                             HTTP.Sock.GetRemoteSinPort ]),
                                                   Format (MSG_THTTPPACKAGE_REJECTED_PACKAGE,
                                                           [ KeyHash ]),
                                                   pckError,
                                                   Packages.ItemAt [PackageIndex].PckType.IDExternal,
                                                   Packages.ItemAt [PackageIndex].MetaClass.GetClassID );
                                    else
                                        WriteLog ( Format ('%s:%d',
                                                          [ HTTP.Sock.GetLocalSinIP,
                                                            HTTP.Sock.GetLocalSinPort ]),
                                                   Format ('%s:%d',
                                                           [ HTTP.Sock.GetRemoteSinIP,
                                                             HTTP.Sock.GetRemoteSinPort ]),
                                                   Format (MSG_THTTPPACKAGE_SENDED_PACKAGE,
                                                           [ KeyHash ]),
                                                   pckSend,
                                                   Packages.ItemAt [PackageIndex].PckType.IDExternal,
                                                   Packages.ItemAt [PackageIndex].MetaClass.GetClassID );
                                end;
                            end
                            else
                                raise Exception.CreateFmt (ERR_TPACKAGE_NOT_FOUND_HASH,[KeyHash]);
                        except on E: Exception do
                            { ����� � ��� ������� ������ }
                            WriteLog ( Format ('%s:%d',
                                               [ HTTP.Sock.GetLocalSinIP,
                                                 HTTP.Sock.GetLocalSinPort ]),
                                       Format ('%s:%d',
                                               [ HTTP.Sock.GetRemoteSinIP,
                                                 HTTP.Sock.GetRemoteSinPort ]),
                                       Format ('%s : %s',
                                               [ ERR_THTTPPACKAGECLIENTTHREAD_INVALID_DATA,
                                                 E.Message ]),
                                       pckError );
                        end;
                    end;
                end
                else
                    WriteLog ( Format ('%s:%d',
                                       [ HTTP.HTTP.Sock.GetLocalSinIP,
                                         HTTP.HTTP.Sock.GetLocalSinPort ]),
                               Format ('%s:%d',
                                       [ HTTP.HTTP.Sock.GetRemoteSinIP,
                                         HTTP.HTTP.Sock.GetRemoteSinPort ]),
                               Format (MSG_THTTPPACKAGE_SEND_ERROR,
                                       [ HTTP.HTTP.ResultCode ]),
                               pckError );
            end;
        except on Error: Exception do
            WriteStatus (Error.Message);
        end;
    except on E: Exception do
        _raise ([ 'Main', ERR_THTTPPACKAGECLIENTTHREAD_MAIN, E, Exception (FatalException) ],
                ['{180FCCAC-75A3-47D4-BA25-CEA16ECB0B96}']);
    end;
end;

procedure THTTPPackageClientThread.Return;
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
        _raise ([ 'Return', ERR_THTTPPACKAGECLIENTTHREAD_RETURN, E, Exception (FatalException) ],
                ['{C48FD3B5-8272-4396-9DC5-0E5CA897F2C3}']);
    end;
end;


procedure THTTPPackageClientThread.WriteStatus (const aMessage: String);
begin
    try
        Status := aMessage;
    except on E: Exception do
        _raise (['WriteStatus',ERR_THTTPPACKAGECLIENTTHREAD_WRITE_STATUS,E],
                ['{68F05474-C488-443C-B50B-EB60732C56D3}']);
    end;
end;

procedure THTTPPackageClientThread.WriteStatus (const aMessage: String;
                                                aParams: array of const);
begin
    try
        WriteStatus ( Format (aMessage,aParams) );
    except on E: Exception do
        _raise (['WriteStatus',ERR_THTTPPACKAGECLIENTTHREAD_WRITE_STATUS,E],
                ['{B766E5C6-1371-4D40-83C4-B684541C6878}']);
    end;
end;

procedure THTTPPackageClientThread.WriteLog (const aSender: String;
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
        _raise (['WriteLog',ERR_THTTPPACKAGECLIENTTHREAD_WRITE_LOG,E],
                ['{6205E9B7-E16B-4034-9580-F5AAAAD48A62}']);
    end;
end;

procedure THTTPPackageClientThread.WriteLog (const aSender: String;
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
        _raise (['WriteLog',ERR_THTTPPACKAGECLIENTTHREAD_WRITE_LOG,E],
                ['{BBC5AE04-4D9B-403F-AD4A-E37D99C5BC57}']);
    end;
end;

end.
