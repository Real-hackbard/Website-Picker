# Website-Picker:

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) ![Delphi Multi](https://github.com/user-attachments/assets/6f915192-b89c-4258-a94e-9367b6d5249a)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) ![None](https://github.com/user-attachments/assets/30ebe930-c928-4aaf-a8e1-5f68ec1ff349)  
![Discription](https://github.com/user-attachments/assets/4a778202-1072-463a-bfa3-842226e300af) ![Admin Execute](https://github.com/user-attachments/assets/893c9b19-6069-4a3e-bcf0-96067a3cab9e)  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) ![122025](https://github.com/user-attachments/assets/2123510b-f411-4624-a2fc-695ffb3c4b70)  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)  

</br>

Websie Picker can find and download the possible images of a website. But it also includes files like JavaScript or log files that can be found.

Of course, many images are not directly accessible via a URL; every website is structured and designed differently. These are accessible images that can be downloaded automatically.

If no images are found, you can try adding a / to the end of the link to potentially find files that were not found.

</br>

![Website Picker](https://github.com/user-attachments/assets/ab30ce2e-46ba-48f4-9fe2-99f704c4c5e7)

</br>

In today's digital world, downloading images is far more than a simple right-click. It has evolved into a specialized discipline, ranging from simple archiving to complex data mining projects by 2025.

While modern browsers offer a basic "save image as" function, these tools go far beyond that by enabling batch downloads (bulk downloads) that can often capture hundreds of images with just one click.

# Batch Download:
Parse the HTML page and retrieve everything between ```START_STRING``` and ```END_STRING```

The ```MyHTTPs.pas file contains``` ```https:\\``` as the transfer protocol, which can be changed if necessary. It is important to ensure that the Trim value matches the characters.

```pascal
procedure TPicker.ParseHtml;
var
    chain  : AnsiString;
    LinkString   : String;
const
    IMG_BALISE = 'src="'; //  Target of the image address
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
        else if Trim(LeftStr(LinkString, 8          // Trimming the URL address, for https:\\ the value 8
                                        )) <>
                                        'https:\\'  // Start of the trimmed URL address
                                        then
            LinkString := Trim(SlachHTTP(Site) + LinkString );

        Links.Add(LinkString);
        Application.ProcessMessages
    end;
end;
```

# URL Extracting:
After the HTML code has been downloaded, a parse function is applied to extract the URL links.

```pascal
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
```
