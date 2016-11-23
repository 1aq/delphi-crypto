unit Fonts;
{******************************************************************************}
{*  Fonts Unit                                                                *}
{*  Revolutionary Confederation of Anarcho Syndicalists                       *}
{*  Written by: black.rabbit 2012                                             *}
{******************************************************************************}
interface

uses
    Windows, SysUtils, Classes, Messages;

function RegisterFont (const aFileName: String; const doUpdate: Boolean = TRUE) : Integer;
function RegisterFonts (const aDir: String) : Integer;

resourcestring
    ERR_REGISTER_FONT  = '������ �������� ������ ''%s''!';
    ERR_REGISTER_FONTS = '������ �������� ������� �� ���������� ''%s''!';

implementation

uses
    Utils;

function RegisterFont (const aFileName: String; const doUpdate: Boolean = TRUE) : Integer;
begin
    Result := -1;
    try
        if not FileExists (aFileName) then
            raise Exception.CreateFmt (ERR_FILE_NOT_FOUND,[aFileName]);
        Result := AddFontResourceEx ( PChar (aFileName), FR_PRIVATE, NIL );
        { ������� ������ ������� ������ �������������� ������ � ������ ������� }
        if not ( Result > 0 ) then
            raise Exception.CreateFmt ('Error code: %d',[Result]);
        { ��������� }
        if doUpdate then
            SendMessage (HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
    except on E: Exception do
        raise Exception.CreateFmt ('%s#13#10%s',[ Format (ERR_REGISTER_FONT,[aFileName]), E.Message ]);
    end;
end;

function RegisterFonts (const aDir: String) : Integer;
var
    lst : TStrings;
    I   : Integer;
begin
    Result := 0;
    try
        lst := TStringList.Create;
        try
            { ��������� ������ ������ �� �������� }
            GetFiles (aDir,lst,TRUE,[ '*.fon',
                                      '*.fnt',
                                      '*.ttf',
                                      '*.ttc',
                                      '*.fot',
                                      '*.otf',
                                      '*.mmm',
                                      '*.pfb',
                                      '*.pfm' ]);
            for I := 0 to lst.Count - 1 do
            try
                { ������������ ������ }
                if ( RegisterFont (lst [I],FALSE) > 0 ) then
                    Inc (Result);
            except
                { ���������� ������, ������� �� ������� ��������� }
            end;
        finally
            FreeAndNil (lst);
        end;
        { ��������� }
        SendMessage (HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
    except on E: Exception do
        raise Exception.CreateFmt ('%s#13#10%s',[ Format (ERR_REGISTER_FONTS,[aDir]), E.Message ]);
    end;
end;

end.
