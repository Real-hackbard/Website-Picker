unit MyHTTPs;

interface

uses
    Windows, Forms, Classes, WinInet, SysUtils, Grids, StdCtrls, Dialogs,
    StrUtils, FunctionsChain;

Type TPicker = class
  private
     { Private-Deklarationen }
    PConnectionInternet : HINTERNET;
    PConnectionHTTPs    : HINTERNET;
    BufferPageWeb       : AnsiString;    // Source code of the HTML page or file read
    Links               : TStringList;   // List of links found
    Site                : string;        // Site on which we are located
  public
    { Public-Deklarationen }
    destructor Destroy;
    function  Connection   ( URL : string ) : Boolean;
    function  GetSourcePage : AnsiString;
    function  GetLiens : TStringList;
    procedure ParseHtml;
    procedure GetFileInMemory;
    procedure GetFileToLocalFile( FileName : string );
  end;

    function  ExtractPathURLToCompleteURL ( URL : string ) : string;
    function  ExtractFileNameToURL ( URL : string ) : string;
    function  Slach    ( path : string ) : string;
    function  SlachHTTP( URL : string    ) : string;
    function  TakeBeforeFolder( PathURL : string ) : string;

implementation
{$I-}

{ Creates the object and connects to the HTTP Server }
function TPicker.Connection( URL : string ) : Boolean;
var
    Temp : Boolean;
begin
    Temp := False;
    PConnectionInternet := InternetOpen(PChar(Application.Title),
                                        INTERNET_OPEN_TYPE_PRECONFIG,
                                        nil,
                                        nil,
                                        0);

    if PConnectionInternet = nil then
        Temp := False
    else begin
        PConnectionHTTPs := InternetOpenUrl(PConnectionInternet,
                                            PChar(URL),
                                            nil ,
                                            0,
                                            INTERNET_FLAG_RELOAD,
                                            0 );

    if PConnectionHTTPs = nil then
    begin
      InternetCloseHandle( PConnectionInternet );
      Temp  := False;
    end else
      Temp  := True;
      Site  := ExtractPathURLToCompleteURL(URL);
      Links := TStringList.Create;
    end;

    Result := Temp;
end;

{ Load web page into a buffer }
procedure TPicker.GetFileInMemory;
var
    Buffer    : Array[1..32] of Char;
    BufferLen : DWORD;
begin
    BufferPageWeb := '';
    repeat
        Wininet.InternetReadFile(PConnectionHTTPs,
                                 @Buffer,
                                 SizeOf(Buffer),
                                 BufferLen);
        BufferPageWeb :=  BufferPageWeb + Buffer
    until BufferLen = 0;
end;

procedure TPicker.GetFileToLocalFile( FileName : string );
var
    Buffer    : Array[1..4096] of Char;
    BufferLen : DWORD;
    FilePath  : File;
    indexF    : Integer;
    TempFileName : string;
begin
    // File name
    TempFileName := FileName;
    indexF := 0;
    while FileExists(TempFileName) do
    begin
        Inc(indexF);
        TempFileName := ChangeFileExt( Filename,
                                       '(' + IntToStr( indexF ) +
                                       ')' + ExtractFileExt( FileName ) );
    end;
    // Copy
    AssignFile( FilePath, TempFileName );
    Rewrite   ( FilePath, 1 );

    repeat
        Wininet.InternetReadFile( PConnectionHTTPs, @Buffer, SizeOf(Buffer), BufferLen );
        BlockWrite( FilePath, Buffer, BufferLen );
        Application.ProcessMessages
    until (BufferLen = 0);
    CloseFile( FilePath );
end;

{ Referring to the page's source code }
function TPicker.GetSourcePage : AnsiString;
begin
    Result := BufferPageWeb;
end;

{ Review the list of links }
function TPicker.GetLiens : TStringList;
begin
    Result := Links;
end;

{ Parse the HTML page and retrieve everything between START_STRING and END_STRING }
procedure TPicker.ParseHtml;
var
    chain  : AnsiString;
    LinkString   : String;
const
    IMG_BALISE = 'src="';
begin
    Links.Clear;
    chain := LowerCase(Trim(BufferPageWeb));
    while pos( IMG_BALISE, chain ) <> 0 do
    begin
        chain := right(IMG_BALISE, chain);
        LinkString   := Trim(left('"', chain ));
        if Trim(LeftStr(LinkString, 2 ) ) = '..' then
            LinkString := Trim(SlachHTTP(TakeBeforeFolder(Site)) +
                                    Trim(Copy(LinkString,
                                    4,
                                    Length(LinkString) - 3)))
        else if Trim(LeftStr(LinkString, 1 ) ) = '.' then
            LinkString := Trim(SlachHTTP(Site) +
                          Trim(Copy(LinkString,
                          3,
                          Length(LinkString) - 2)))
        else if Trim(LeftStr(LinkString, 8 ) ) <> 'https:\\' then
            LinkString := Trim(SlachHTTP(Site) + LinkString );

        Links.Add(LinkString);
        Application.ProcessMessages
    end;
end;

{ Destroys connection pointers }
destructor TPicker.Destroy;
begin
    inherited Destroy();
    Links.Free;
    InternetCloseHandle( PConnectionInternet );
    InternetCloseHandle( PConnectionHTTPs     );
end;


// ************** Exceptional Functions **************

{ Extracting the filename from a URL }
function ExtractFileNameToURL ( URL : string ) : string;
var
    Temp : string;
    Position : Integer;
begin
    Position := Length( URL ) - 1;
    if Pos('/', URL) <> 0 then
    begin
        while (Copy( URL, Position, 1 ) <> '/' ) do Dec(Position);
        Temp := RightStr( URL, (Length(URL) - Position ) )
    end else
        Temp := Trim(URL);
    Result := Temp;
end;

function  ExtractPathURLToCompleteURL ( URL : string ) : string;
var
    Temp : string;
    Position : Integer;
begin
    if RightStr( Trim(URL) , 1) = '/' then
        Temp := URL
    else begin
        Position := Length( URL );
        if Pos( '/', URL ) <> 0 then
        begin
            while ( Copy( URL, Position, 1 ) <> '/' ) do dec( Position );
            Temp := LeftStr( URL, Position )
        end else
            Temp := Trim( URL );
    end;
    Result := Trim(Temp);
end;

function TakeBeforeFolder( PathURL : string ) : string;
var
    temp : string;
    Position : integer;
begin
    if RightStr( Trim(PathURL) , 1) = '/' then
        Temp := Copy( PathURL, 1, Length(PathURL) - 1 );
        Position := Length( Temp );

        if Pos( '/', Temp ) <> 0 then
        begin
            while ( Copy( Temp, Position, 1 ) <> '/' ) do dec( Position );
            Temp := LeftStr( Temp, Position  )
        end else
            Temp := Trim( Temp );
    Result := Trim(Temp);
end;

{ Add a backslash ('\') to the end of the path if it's not already there. }
function Slach( path : string ) : string;
begin
    if Copy( path, length(path), 1 ) <> '\' then
        Result := Trim(path) + '\'
    else
        Result := Trim(path);
end;

{ Add '/' to the end of the URL if it is not already there }
function SlachHTTP( URL : string ) : string;
begin
    if Copy( URL, length(URL), 1 ) <> '/' then
        Result := Trim(URL) + '/'
    else
        Result := Trim(URL);
end;

end.
