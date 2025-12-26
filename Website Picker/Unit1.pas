

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WinInet, StdCtrls, Buttons, CheckLst, MyHTTPs, ComCtrls, Menus,
  XPMan, ImgList, ShellApi, ExtCtrls, FileCtrl, HighlightURL, tlhelp32;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    ListView1: TListView;
    Panel1: TPanel;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    RichEdit1: TRichEdit;
    HeaderControl1: THeaderControl;
    Panel4: TPanel;
    ListBox1: TListBox;
    HeaderControl2: THeaderControl;
    Splitter1: TSplitter;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    PopupMenu1: TPopupMenu;
    C1: TMenuItem;
    Label4: TLabel;
    H1: TMenuItem;
    N1: TMenuItem;
    L1: TMenuItem;
    PopupMenu2: TPopupMenu;
    N2: TMenuItem;
    SaveDialog1: TSaveDialog;
    S1: TMenuItem;
    C2: TMenuItem;
    N3: TMenuItem;
    H2: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    E1: TMenuItem;
    S2: TMenuItem;
    S3: TMenuItem;
    ImageList1: TImageList;
    C3: TMenuItem;
    N6: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure C1Click(Sender: TObject);
    procedure H1Click(Sender: TObject);
    procedure L1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure C2Click(Sender: TObject);
    procedure H2Click(Sender: TObject);
    procedure RichEdit1Change(Sender: TObject);
    procedure RichEdit1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure E1Click(Sender: TObject);
    procedure S2Click(Sender: TObject);
    procedure S3Click(Sender: TObject);
    procedure C3Click(Sender: TObject);
  private
    { Private-Deklarationen }
    flbHorzScrollWidth: Integer;
    abort : boolean;
    procedure popoff;
    procedure popon;
  public
    { Public-Deklarationen }

end;

var
    Form1: TForm1;

implementation

{$R *.dfm}
function GetProcessID(Exename: string): DWORD; 
var
   hProcSnap: THandle;
   pe32: TProcessEntry32;
begin
   result := 0;
   hProcSnap := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
   if hProcSnap <> INVALID_HANDLE_VALUE then
      begin
         pe32.dwSize := SizeOf(ProcessEntry32);
         if Process32First(hProcSnap, pe32) = true then
            begin
               while Process32Next(hProcSnap, pe32) = true do
                  begin
                     if pos(Exename, pe32.szExeFile) <> 0 then
                        result := pe32.th32ProcessID;
                   end;
               end;
               CloseHandle(hProcSnap);
   end;
end;

function KillProcess(PID: DWord): Bool;
var
   hProcess: THandle;
begin
   hProcess := OpenProcess(PROCESS_TERMINATE, False, PID);
   Result := TerminateProcess(hProcess, 0);
end;

procedure TForm1.popoff;
begin
  C1.Enabled := false;
  H1.Enabled := false;
  L1.Enabled := falsE;
  E1.Enabled := false;
  S2.Enabled := false;
  S3.Enabled := false;
  N2.Enabled := false;
  S1.Enabled := false;
  C2.Enabled := false;
  H2.Enabled := false;
  Button2.Enabled := false;
  Button3.Enabled := false;
end;

procedure TForm1.popon;
begin
  C1.Enabled := true;
  H1.Enabled := true;
  L1.Enabled := true;
  E1.Enabled := true;
  S2.Enabled := true;
  S3.Enabled := true;
  N2.Enabled := true;
  S1.Enabled := true;
  C2.Enabled := true;
  H2.Enabled := true;
  Button2.Enabled := true;
  Button3.Enabled := true;
end;


function DeleteFile(const AFile: string): boolean;
var
 sh: SHFileOpStruct;
begin
 ZeroMemory(@sh, sizeof(sh));
 with sh do
   begin
   Wnd := Application.Handle;
   wFunc := fo_Delete;
   pFrom := PChar(AFile +#0);
   fFlags := fof_Silent or fof_NoConfirmation;
   end;
 result := SHFileOperation(sh) = 0;
end;

function MyGetFileSize(const Filename: string): TULargeInteger; 
var 
  Find: THandle;
  Data: TWin32FindData; 
begin 
  Result.QuadPart := -1; 
  Find := FindFirstFile(PChar(Filename), Data); 
  if (Find <> INVALID_HANDLE_VALUE) then 
  begin 
    Result.LowPart := Data.nFileSizeLow; 
    Result.HighPart := Data.nFileSizeHigh; 
    Windows.FindClose(Find); 
  end; 
end;

{ Analyze & Download button }
procedure TForm1.Button1Click(Sender: TObject);
begin
  abort := true;
  KillProcess(GetProcessID('WebsitePicker.exe'));
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  WebPicker  : TPicker;
  DownFile : TPicker;
  x : Integer;
  item : TListItem;

begin
  if not DirectoryExists(Edit2.Text) then
  begin
    MessageBoxA( Handle, PChar('The target folder does not exist.!'),
                         PChar('Destination Folder'), MB_ICONINFORMATION );
    Exit;
  end;


  { URL presence check }
  if Trim(Edit1.Text) = '' then
  begin
    MessageBoxA( Handle, PChar('Enter a URL !'), PChar('URL ?'), MB_ICONINFORMATION );
    Exit;
  end;

    Screen.Cursor := crHourGlass;
    abort := false;
    RichEdit1.Clear;
    ListBox1.Clear;
    ListView1.Clear;
    popoff;
    StatusBar1.Panels[1].Text := 'Connection to the Website ...';
    Application.ProcessMessages;
    { Create the object }
    WebPicker := TPicker.Create;

    { Connection established on the page, if error Stop }
    if WebPicker.Connection(Trim(Edit1.Text)) = False then
    begin
        MessageBox( Handle, PChar('This URL could not be accessed. !'),
                            PChar('URL ?'), MB_ICONINFORMATION );
        WebPicker.Free;
        StatusBar1.Panels[1].Text := 'Download abort ... could not be accessed';
        Exit;
    end;

    { Retrieve the page }
    StatusBar1.Panels[1].Text := 'Download the page ...';
    WebPicker.GetFileInMemory;
    RichEdit1.Text := WebPicker.GetSourcePage;
    Application.ProcessMessages;

    { Parse and retrieve the links }
    StatusBar1.Panels[1].Text := 'Page analysis ...';
    Application.ProcessMessages;
    WebPicker.ParseHtml;
    ListBox1.Items := WebPicker.GetLiens;
    HeaderControl2.Sections[1].Text := IntToStr(ListBox1.Items.Count) + ' Files found.';
    HeaderControl1.Sections[1].Text := IntToStr(RichEdit1.Lines.Count);
    try
        if WebPicker.GetLiens.Count <= 0 then
            StatusBar1.Panels[1].Text := 'No images found on this site !'
        else
          begin
            for X := 0 to WebPicker.GetLiens.Count - 1 do
            begin
              try
                if abort = true then
                begin
                 StatusBar1.Panels[1].Text := 'Download abort.';
                 Screen.Cursor := crDefault;
                 StatusBar1.Panels[2].Text := 'Downloading, abort ...';
                 popon;
                 Application.ProcessMessages;
                 Exit;
                end;

                StatusBar1.Panels[1].Text := 'Download of : ' +
                               ExtractFileNameToURL(WebPicker.Getliens.Strings[x]);
                DownFile := TPicker.Create;
                DownFile.Connection( WebPicker.Getliens.Strings[X] );
                DownFile.GetFileToLocalFile( Slach(Edit2.Text) +
                            ExtractFileNameToURL( WebPicker.Getliens.Strings[X] ) );
                DownFile.Free;
              except
                DownFile.Free;
                WebPicker.Free;
                popon;
                 Application.ProcessMessages;
                StatusBar1.Panels[1].Text := 'Download abort ... could not be accessed';
               Exit;
              end;

              //ListView1.Items.BeginUpdate;
              Item := ListView1.Items.Add;
              // get downloaded filename
              Item.Caption := ExtractFileNameToURL(WebPicker.Getliens.Strings[x]);
              // get file extinsion
              Item.SubItems.Add(ExtractFileExt(ExtractFileNameToURL(WebPicker.Getliens.Strings[x])));
              // get files size
              Item.SubItems.Add(IntToStr(MyGetFileSize(Edit2.Text + '\' +
                                         ExtractFileNameToURL( WebPicker.Getliens.Strings[X] )).QuadPart) +
                                         ' bytes');


              if ListView1.Items.Item[x].SubItems[1] = '-1 bytes' then
              begin
                ListView1.Items.Item[x].SubItems[1] := '0 bytes';
                Item.SubItems.Add('not found');
                item.ImageIndex := 1;
              end else begin
                Item.SubItems.Add('Downloaded');
                item.ImageIndex := 0;
              end;


              (* Here you can insert the files that should be
                 deleted after downloading.*)


              // remove png iamge file
              if CheckBox1.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.png' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              // remove gif iamge file
              if CheckBox2.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.gif' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              // remove jpg iamge file
              if CheckBox3.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.jpg' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              // remove bmp iamge file
              if CheckBox4.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.bmp' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              // remove bmp iamge file
              if CheckBox5.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.ico' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              // remove svg iamge file
              if CheckBox6.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.svg' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              // remove js (javascript) iamge file
              if CheckBox7.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.js' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              // remove webp iamge file
              if CheckBox8.Checked = true then
                begin
                if ExtractFileExt(Edit2.Text + '\' +
                                  ExtractFileNameToURL( WebPicker.Getliens.Strings[X])) = '.webp' then
                begin
                DeleteFile(Edit2.Text + '\' +
                           ExtractFileNameToURL( WebPicker.Getliens.Strings[X]));
                ListView1.Items.Item[x].SubItems[2] := 'Removed';
                item.ImageIndex := 2;
                end;
              end;

              ListView1.Scroll(0,Item.Position.y);
              StatusBar1.Panels[2].Text := 'Downloading, please wait ...';
              StatusBar1.Panels[1].Text := 'Finished with : ' + IntToStr(X) +
                                            ' files uploaded...';
              Application.ProcessMessages;
           end;
        end;
    finally
        Screen.Cursor := crDefault;
        WebPicker.Free;
        Beep;
        ShowMessage('Download finish.');
        StatusBar1.Panels[2].Text := 'Download finish.';
        popon;
    end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Directory: string;
begin
  if SelectDirectory('Select directory', '', Directory) then
  Edit2.Text := Directory;
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  ScrollBarA: array[0..3] of TScrollStyle = (
    ssBoth,ssHorizontal,ssNone,ssVertical);
begin
  Listbox1.Perform(LB_SetHorizontalExtent, 1500, Longint(0));
  RichEdit1.MaxLength := $7FFFFFF0;
  RichEdit1.ScrollBars := ScrollBarA[0];
  RichEdit1.WordWrap := False;
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
 Len: Integer;
 NewText: String;
begin
  NewText:=Listbox1.Items[Index];

  with Listbox1.Canvas do
  begin
    FillRect(Rect);
    TextOut(Rect.Left + 1, Rect.Top, NewText);
    Len:=TextWidth(NewText) + Rect.Left + 10;
    if Len>flbHorzScrollWidth then
    begin
      flbHorzScrollWidth:=Len;
      Listbox1.Perform(LB_SETHORIZONTALEXTENT, flbHorzScrollWidth, 0 );
    end;
  end;
end;

procedure TForm1.C1Click(Sender: TObject);
begin
  abort := false;
  RichEdit1.Clear;
  ListBox1.Clear;
  ListView1.Clear;
  HeaderControl2.Sections[1].Text := IntToStr(ListBox1.Items.Count);
  HeaderControl1.Sections[1].Text := IntToStr(RichEdit1.Lines.Count);
end;

procedure TForm1.H1Click(Sender: TObject);
begin
  if H1.Checked = true then
  Begin
    Panel3.Visible := true;
    Panel3.Align := alLeft;
  end else begin
    Panel3.Visible := false;
    Panel4.Align := alClient;
  end;

  if (L1.Checked = false) and (H1.Checked = false) then
  begin
    Panel2.Visible := false;
    ListView1.Align := alClient;
  end else begin
    Panel2.Visible := true;
    ListView1.Height := Form1.Height div 3;
  end;
end;

procedure TForm1.L1Click(Sender: TObject);
begin
  if L1.Checked = true then
  Begin
    Panel3.Align := alLeft;
    Panel3.Width := Form1.Width div 2;
    Panel4.Visible := true;
  end else begin
    Panel4.Visible := false;
    Panel3.Align := alClient;
  end;

  if (L1.Checked = false) and (H1.Checked = false) then
  begin
    Panel2.Visible := false;
    ListView1.Align := alClient;
  end else begin
    Panel2.Visible := true;
    ListView1.Height := Form1.Height div 3;
  end;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  RichEdit1.PlainText := True ;
  if SaveDialog1.Execute then
     RichEdit1.Lines.SaveToFile(SaveDialog1.FileName + '.txt');
end;

procedure TForm1.S1Click(Sender: TObject);
begin
  RichEdit1.Perform(EM_SETSEL,0,-1);
end;

procedure TForm1.C2Click(Sender: TObject);
begin
  RichEdit1.Perform(WM_COPY,0,0);
end;

procedure TForm1.H2Click(Sender: TObject);
begin
  HighlightLinks(RichEdit1);
end;

procedure TForm1.RichEdit1Change(Sender: TObject);
begin
  UpdateWordUnderCursor(RichEdit1);
end;

procedure TForm1.RichEdit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  s : string;
begin
  try
    s := GetURLUnderCursor(RichEdit1);
    if s = '' then
    begin
      s := 'No URL under the cursor';
      RichEdit1.Cursor := crDefault;
    end else begin
      RichEdit1.Cursor := crHandPoint;
    end;
  except
  end;
end;

procedure TForm1.E1Click(Sender: TObject);
begin
  if E1.Checked = true then
  Listview1.Column[1].Width := 100
  else
  Listview1.Column[1].Width := 0;
end;

procedure TForm1.S2Click(Sender: TObject);
begin
  if S2.Checked = true then
  Listview1.Column[2].Width := 100
  else
  Listview1.Column[2].Width := 0;
end;

procedure TForm1.S3Click(Sender: TObject);
begin
  if S3.Checked = true then
  Listview1.Column[3].Width := 100
  else
  Listview1.Column[3].Width := 0;
end;

procedure TForm1.C3Click(Sender: TObject);
begin
  DeleteFile(Edit2.Text + '\*.*');
end;

end.
