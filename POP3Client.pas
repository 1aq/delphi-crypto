unit POP3Client;
{******************************************************************************}
{*  POP3 Client Unit                                                          *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2012                                             *}
{******************************************************************************}
interface

{$I 'std.inc'}

uses
    Windows, SysUtils, Variants, Classes,
    Controls, ComCtrls, Gauges,
{ utils }
    DateUtils, Utils, Strings, VarRecs, Versions, EClasses,
    { synapse }
    blcksock, synautil, synachar, pop3send, mimemess, mimepart,
    { synapse - open ssl }
    ssl_openssl;

type
{ ������ pop3 }
{$M+}
    EPOP3 = class (EClass) end;
{$M-}

{ pop3-������ }
{$M+}
    CPOP3Client = class of TPOP3Client;
    PPOP3Client = ^TPOP3Client;
    TPOP3Client = class (TObject)
    public
        class procedure _raise (anArgs: array of const;
                                const anEGUID: String = ''); overload; virtual;
        class procedure _raise (anArgs: array of const;
                                anEGUID: array of const); overload; virtual;
    private
        f_POP3: TPOP3Send;        { ������ }
        f_MimeMessage: TMimeMess; { ��������� }
        f_Host: String;           { ���� ������� }
        f_Port: WORD;             { ���� ������� }
        f_Login: String;          { ����� �� ������ }
        f_Password: String;       { ������ �� ������ }
        f_ProxyHost: String;      { ���� proxy-������� }
        f_ProxyPort: WORD;        { ���� proxy-������� }
        f_ProxyLogin: String;     { ����� �� proxy-������ }
        f_ProxyPassword: String;  { ������ �� proxy-������ }
        f_ProxyProtocol: String;  { �������� proxy-������� }
        f_TimeOut: LongWord;      { ����� �������� ms }
        f_AutoTLS: Boolean;       { ������������ TLS }
        f_FullSSL: Boolean;       { ������������ ����������� SSL }
    public
        constructor Create (anArgs: array of const); virtual;
        destructor Destroy; override;
    protected
        function SignIn : Boolean; virtual;
        procedure SignOut; virtual;
    public
        procedure Clear; virtual;
        procedure Prepare; virtual;
        function GetCount : Integer; virtual;
        function Load (const anIndex: Integer;
                       out aSender: String;
                       out aSubject: String;
                       out aData: TStream;
                       out aTimeStamp: TDateTime;
                       out anUserAgent: String) : Boolean; overload; virtual;
        function Delete (const anIndex: Integer) : Boolean; overload; virtual;
    public
        property POP3: TPOP3Send read f_POP3;
        property MimeMessage: TMimeMess read f_MimeMessage;
        property Host: String read f_Host write f_Host;
        property Port: WORD read f_Port write f_Port;
        property Login: String read f_Login write f_Login;
        property Password: String read f_Password write f_Password;
        property ProxyHost: String read f_ProxyHost write f_ProxyHost;
        property ProxyPort: WORD read f_ProxyPort write f_ProxyPort;
        property ProxyLogin: String read f_ProxyLogin write f_ProxyLogin;
        property ProxyPassword: String read f_ProxyPassword write f_ProxyPassword;
        property ProxyProtocol: String read f_ProxyProtocol write f_ProxyProtocol;
        property TimeOut: LongWord read f_TimeOut write f_TimeOut;
        property AutoTLS: Boolean read f_AutoTLS write f_AutoTLS;
        property FullSSL: Boolean read f_FullSSL write f_FullSSL;
    end;
{$M-}

{ TPOP3Client Errors }
resourcestring
    ERR_TPOP3CLIENT_CREATE          = '������ �������� pop3-�������!';
    ERR_TPOP3CLIENT_DESTROY         = '������ ����������� pop3-�������!';
    ERR_TPOP3CLIENT_PREPARE         = '������ ���������� �������!';
    ERR_TPOP3CLIENT_CLEAR           = '������ ������� ������������ ������!';
    ERR_TPOP3CLIENT_LOAD            = '������ �������� ������!';
    ERR_TPOP3CLIENT_DELETE          = '������ �������� ������!';
    ERR_TPOP3CLIENT_GET_COUNT       = '������ ������� ���������� �����!';
    ERR_TPOP3CLIENT_IVALID_HOST     = '������������ �����!';
    ERR_TPOP3CLIENT_IVALID_PORT     = '������������ ����!';
    ERR_TPOP3CLIENT_INVALID_TIMEOUT = '������������ ����� ��������!';
    ERR_TPOP3CLIENT_IVALID_LOGIN    = '������������ �����!';
    ERR_TPOP3CLIENT_IVALID_PASSWORD = '������������ ������!';
    ERR_TPOP3CLIENT_IVALID_STREAM   = '����� �� ���������������!';

implementation

{ TPOP3Client }
class procedure TPOP3Client._raise (anArgs: array of const;
                                    const anEGUID: String = '');
begin
    raise EPOP3.Create ( _([self],anArgs), anEGUID );
end;

class procedure TPOP3Client._raise (anArgs: array of const;
                                    anEGUID: array of const);
begin
    raise EPOP3.Create ( _([self],anArgs), anEGUID );
end;

constructor TPOP3Client.Create (anArgs: array of const);
begin
    try
        inherited Create;
        { ������� ������ }
        f_POP3 := TPOP3Send.Create;
        f_MimeMessage := TMimeMess.Create;
        { ������ �������� - ���� }
        f_Host := '127.0.0.1';
        if notEmpty (0,anArgs) then
        begin
            f_Host := toString (anArgs [0]);
        end;
        if isEmpty (Host) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_HOST);
        { ������ �������� - ���� }
        f_Port := 110;
        if notEmpty (1,anArgs) then
        begin
            f_Port := toInteger (anArgs [1]);
        end;
        if not ( Port > 0 ) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_PORT);
        { ������ �������� - ����� }
        f_Login := '';
        if notEmpty (2,anArgs) then
        begin
            f_Login := GetEmailAddr ( toString (anArgs [2]) );
        end;
        if isEmpty (Login) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_LOGIN);
        { ��������� �������� - ������ }
        f_Password := '';
        if notEmpty (3,anArgs) then
        begin
            f_Password := GetEmailAddr ( toString (anArgs [3]) );
        end;
        if isEmpty (Password) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_PASSWORD);
        { ����� �������� - proxy-���� }
        f_ProxyHost := '';
        if notEmpty (4,anArgs) then
        begin
            f_ProxyHost := toString (anArgs [4]);
        end;
        { ������ �������� - proxy-���� }
        f_ProxyPort := 0;
        if notEmpty (5,anArgs) then
        begin
            f_ProxyPort := toInteger (anArgs [5]);
        end;
        { ������� �������� - proxy-����� }
        f_ProxyLogin := '';
        if notEmpty (6,anArgs) then
        begin
            f_ProxyLogin := toString (anArgs [6]);
        end;
        { ������� �������� - proxy-������ }
        f_ProxyPassword := '';
        if notEmpty (7,anArgs) then
        begin
            f_ProxyPassword := toString (anArgs [7]);
        end;
        { ������� �������� - �������� proxy-������� }
        f_ProxyProtocol := 'SOCKS5';
        if notEmpty (8,anArgs) then
        begin
            f_ProxyProtocol := toString (anArgs [8]);
        end;
        { ������� �������� - ����� �������� }
        f_TimeOut := 120000;
        if notEmpty (9,anArgs) then
        begin
            f_TimeOut := toInteger (anArgs [9]);
        end;
        if ( TimeOut = 0 ) then
            raise Exception.Create (ERR_TPOP3CLIENT_INVALID_TIMEOUT);
        { ������������ �������� - TLS }
        f_AutoTLS := FALSE;
        if notEmpty (10,anArgs) then
        begin
            f_AutoTLS := toBoolean (anArgs [10]);
        end;
        { ����������� �������� - SSL }
        f_FullSSL := FALSE;
        if notEmpty (11,anArgs) then
        begin
            f_FullSSL := toBoolean (anArgs [11]);
        end;
    except on E: Exception do
        _raise (['Create',ERR_TPOP3CLIENT_CREATE,E],
                ['{B4E2D749-0B21-4EA6-977D-6D26C06DFFD6}']);
    end;
end;

destructor TPOP3Client.Destroy;
begin
    try
        _FillChar ( f_Host, Length (f_Host), $00 );
        f_Port := 0;
        _FillChar ( f_Login, Length (f_Login), $00 );
        _FillChar ( f_Password, Length (f_Password), $00 );
        _FillChar ( f_ProxyHost, Length (f_ProxyHost), $00 );
        f_ProxyPort := 0;
        _FillChar ( f_ProxyLogin, Length (f_ProxyLogin), $00 );
        _FillChar ( f_ProxyPassword, Length (f_ProxyPassword), $00 );
        _FillChar ( f_ProxyProtocol, Length (f_ProxyProtocol), $00 );
        FreeAndNil (f_POP3);
        if Assigned (MimeMessage) then
            MimeMessage.Clear;
        FreeAndNil (f_MimeMessage);
         inherited Destroy;
    except on E: Exception do
        _raise (['Destroy',ERR_TPOP3CLIENT_DESTROY,E],
                ['{6050F64C-F8C7-4202-8118-84495CC8063D}']);
    end;
end;

procedure TPOP3Client.Clear;
begin
    try
        { ������� ��������� ������� }
        MimeMessage.Clear;
    except on E: Exception do
        _raise (['Clear',ERR_TPOP3CLIENT_CLEAR,E],
                ['{F66DC368-2F7C-4B90-9457-906D9742D749}']);
    end;
end;

procedure TPOP3Client.Prepare;
begin
    try
        { ���������� ��������� ������� }
        if isEmpty (Host) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_HOST);
        POP3.TargetHost := Host;
        if not ( Port > 0 ) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_PORT);
        POP3.TargetPort := IntToStr (Port);
        if isEmpty (Login) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_LOGIN);
        POP3.UserName := Login;
        if isEmpty (Password) then
            raise Exception.Create (ERR_TPOP3CLIENT_IVALID_PASSWORD);
        { -- SOCKS-proxy }
        POP3.Password := Password;
        if (  Pos ( 'SOCKS', UpperCase (ProxyProtocol) ) > 0  ) then
        begin
            if notEmpty (ProxyHost) then
                POP3.Sock.SocksIP := ProxyHost;
            if ( ProxyPort > 0 ) then
                POP3.Sock.SocksPort := IntToStr (ProxyPort);
            if notEmpty (ProxyLogin) then
                POP3.Sock.SocksUsername := ProxyLogin;
            if notEmpty (ProxyPassword) then
                POP3.Sock.SocksPassword := ProxyPassword;
            if ( UpperCase (ProxyProtocol) = 'SOCKS4' ) then
                POP3.Sock.SocksType := ST_Socks4
            else if ( UpperCase (ProxyProtocol) = 'SOCKS5' ) then
                POP3.Sock.SocksType := ST_Socks5;
            POP3.Sock.SocksResolver := FALSE;
        end;
        POP3.TimeOut := TimeOut;
        POP3.AutoTLS := AutoTLS;
        POP3.FullSSL := FullSSL;
    except on E: Exception do
        _raise (['Prepare',ERR_TPOP3CLIENT_PREPARE,E],
                ['{853F1995-66B8-4530-BD84-4EC1EA43E26B}']);
    end;
end;

function TPOP3Client.SignIn : Boolean;
begin
    Result := POP3.Login;
    if not Result and ( Pos ('@',Login) > 0 ) then
    begin
        POP3.UserName := SeparateLeft (Login,'@');
        Result := POP3.Login;
    end;
end;

procedure TPOP3Client.SignOut;
begin
    POP3.Logout;
end;

function TPOP3Client.GetCount : Integer;
begin
    Result := -1;
    try
        { �������������� ������ }
        Prepare;
        { ���������� ������ }
        if SignIn then
        try
            if POP3.Stat then
                Result := POP3.StatCount;
        finally
            SignOut;
        end;
    except on E: Exception do
        _raise (['GetCount',ERR_TPOP3CLIENT_GET_COUNT,E],
                ['{F2842734-AE3F-4640-91A5-C8AF739954DE}']);
    end;
end;

function TPOP3Client.Load (const anIndex: Integer;
                           out aSender: String;
                           out aSubject: String;
                           out aData: TStream;
                           out aTimeStamp: TDateTime;
                           out anUserAgent: String) : Boolean;
var
    Count : Integer;
begin
    Result := FALSE;
    try
        { �������������� ������ }
        Prepare;
        { ���������� ������ }
        if SignIn then
        try
            Count := -1;
            if POP3.Stat then
                Count := POP3.StatCount; { GetCount }
            if ( Count > 0 ) and
               ( anIndex >= 0 ) and
               ( anIndex <= Count-1 ) then
            begin
                { ������� ����� }
                Clear;
                { ������ ��������� }
                if POP3.Retr (anIndex+1) then
                begin
                    MimeMessage.Lines.Assign (POP3.FullResult);
                    MimeMessage.DecodeMessage;
                    { ��������� ������ }
                    aSender := MimeMessage.Header.From;
                    aSubject := MimeMessage.Header.Subject;
                    aTimeStamp := MimeMessage.Header.Date;
                    anUserAgent := MimeMessage.Header.XMailer;
                    aData.Size := 0;
                    MimeMessage.MessagePart.PartBody.SaveToStream (aData);
                    Result := TRUE;
                end;
            end;
        finally
            SignOut;
        end;
    except on E: Exception do
        _raise (['Load',ERR_TPOP3CLIENT_LOAD,E],
                ['{147B0239-4F70-4A10-A30D-6562E3922DC0}']);
    end;
end;

function TPOP3Client.Delete (const anIndex: Integer) : Boolean;
var
    Count : Integer;
begin
    Result := FALSE;
    try
        { �������������� ������ }
        Prepare;
        { ���������� ������ }
        if SignIn then
        try
            //Count := -1;
            //if POP3.Stat then
            //    Count := POP3.StatCount; { GetCount }
            //if ( Count > 0 ) and
            //   ( anIndex >= 0 ) and
            //   ( anIndex <= Count-1 ) then
            //begin
                { ������� ��������� }
                Result := POP3.Dele (anIndex+1);
            //end;
        finally
            SignOut;
        end;
    except on E: Exception do
        _raise (['Delete',ERR_TPOP3CLIENT_DELETE,E],
                ['{AEA1C6E0-EA4D-4FCF-BB3E-39F466332D23}']);
    end;
end;


end.
