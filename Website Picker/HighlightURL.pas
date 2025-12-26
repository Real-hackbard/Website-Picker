unit HighlightURL;
{$R-}
{$I-}
{$Q-}
{$RANGECHECKS OFF}
{$WARNINGS OFF}

interface

uses ComCtrls, Windows, Messages, RichEdit, Graphics, Controls;

procedure HighlightLinks(const RichEdit : TRichEdit);
function GetURLUnderCursor(const RichEdit : TRichEdit) : string;
procedure UpdateWordUnderCursor(const RichEdit : TRichEdit);

implementation

function isValidChar(const c : char) : boolean;
const validChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$-_.+!*''(),{}|\^~[]`<>#%|<>;/?:@&=';
begin
  result := Pos(c, validChars) <> 0;
end;

procedure HighlightLinks(const RichEdit : TRichEdit);
var
  sCopy : string;
  memoIndex : integer;
  s : string;
  urlPos : integer;
  j : integer;
  URL : string;

begin
  try
    s := RichEdit.Lines.Text;
    sCopy := Copy(s, 0, length(s));
    memoIndex := 0;

    RichEdit.Tag := 1;
    // Hide the selection marker before processing
    // --> WM_USER + 63 = EM_HIDESELECTION
    RichEdit.Perform(Messages.WM_USER + 63, WPARAM(TRUE), LPARAM(FALSE));
    // Makes all text black / ununderlined
    RichEdit.SelectAll;
    RichEdit.SelAttributes.Color := clBlack;
    RichEdit.SelAttributes.Style := [];

    // Find a URL
    urlPos := Pos('http', sCopy);
     try
      while urlPos <> 0 do begin
        // Copies the text from the beginning of the URL to the end of the text
        sCopy := Copy(sCopy, urlPos, length(sCopy));
        memoIndex := memoIndex + urlPos;
        // Places the cursor at the beginning of the URL
        RichEdit.SelStart := memoIndex - 1;
        j := 1;
        URL := '';
         try
          // Find the end of the URL
          while isValidChar(sCopy[j]) do begin
            URL := URL + sCopy[j];
            j := j + 1;
          end;
         except
         end;

        sCopy := copy(sCopy, j, length(sCopy));
        memoIndex := memoIndex + j - 2;
        // Highlight the URL in blue and underline it
        RichEdit.SelLength := memoIndex - RichEdit.SelStart;
        RichEdit.SelAttributes.Color := clBlue;
        RichEdit.SelAttributes.Style := [fsUnderline];
        // Find the next URL to process
        urlPos := Pos('http', sCopy);
      end;
     except
     end;

    RichEdit.SelStart := 0;
    // --> WM_USER + 63 = EM_HIDESELECTION
    RichEdit.Perform(Messages.WM_USER + 63, WPARAM(FALSE), LPARAM(FALSE));
    RichEdit.Tag := 0;
  except
  end;
end;

function GetURLUnderCursor(const RichEdit : TRichEdit) : string;
var
  iWordStart, iWordEnd,
  iCharIndex, iLineIndex, iCharOffset: Integer;
  Pt: TPoint;
  mouse : TMouse;
begin
  Result := '';
  mouse := TMouse.Create();
  Pt := mouse.CursorPos;
  Pt := RichEdit.ScreenToClient(Pt);
  // Retrieves the character under the cursor
  // (The function returns -1 if it fails)
  iCharIndex := SendMessage(RichEdit.Handle, Messages.EM_CHARFROMPOS, 0, Integer(@Pt));
  if iCharIndex >= 0 then begin
    // If the characters are valid, please check the adjacent characters
    // determine if the word under the cursor is a URL
    if isValidChar(RichEdit.Text[iCharIndex]) then begin
      // Retrieves the row index
      iLineIndex := RichEdit.Perform(EM_EXLINEFROMCHAR, 0, LPARAM(iCharIndex));
      // Retrieves the character's position from the beginning of the line
      iCharOffset := iCharIndex - RichEdit.Perform(Messages.EM_LINEINDEX, WPARAM(iLineIndex), 0);
      // Retrieve the word under the cursor
      if length(RichEdit.Lines[iLineIndex]) > 0 then begin
        // The left part of the word
        iWordStart := iCharOffset + 1;
        while iWordStart > 0 do begin
          if isValidChar(RichEdit.Lines[iLineIndex][iWordStart]) then
            iWordStart := iWordStart - 1
          else
            break;
        end;
        // The right part
        iWordEnd := iCharOffset + 1;
        while iWordEnd < length(RichEdit.Lines[iLineIndex]) do
        begin
          if isValidChar(RichEdit.Lines[iLineIndex][iWordEnd]) then
            iWordEnd := iWordEnd + 1
          else
            break;
        end;

        // We copy the word into the Result
        Result := Copy(RichEdit.Lines[iLineIndex], iWordStart + 1, iWordEnd - iWordStart);
      end;

      // If the word is not a URL, an empty string is returned.
      if pos('http', Result) <> 1 then Result := '';
    end;
  end;
end;

procedure UpdateWordUnderCursor(const RichEdit : TRichEdit);
var
  iWordStart, iWordEnd,
  iCharIndex, iLineIndex, iCharOffset: Integer;
  theWord : string;
  saveSelStart : integer;
begin
  if RichEdit.Cursor <> crNone then RichEdit.Cursor := crNone;

  iCharIndex := RichEdit.SelStart;

  if iCharIndex >= 0 then begin
    // Retrieves the row index
    iLineIndex := RichEdit.Perform(EM_EXLINEFROMCHAR, 0, LPARAM(iCharIndex));
    // Retrieves the character's position relative to the beginning of the line
    iCharOffset := iCharIndex - RichEdit.Perform(Messages.EM_LINEINDEX, WPARAM(iLineIndex), 0);

   // Retrieve the word under the cursor
    if length(RichEdit.Lines[iLineIndex]) > 0 then
    begin
      // The left part of the word
      iWordStart := iCharOffset;
      iCharIndex := iCharIndex;
      while iWordStart > 0 do begin
        if isValidChar(RichEdit.Lines[iLineIndex][iWordStart]) then
        begin
          iWordStart := iWordStart - 1;
          iCharIndex := iCharIndex - 1;
        end else begin
          break;
        end;
      end;

      // The right part
      iWordEnd := iCharOffset + 1;
      while iWordEnd < length(RichEdit.Lines[iLineIndex]) do
      begin
        if isValidChar(RichEdit.Lines[iLineIndex][iWordEnd]) then
          iWordEnd := iWordEnd + 1
        else
          break;
      end;

      theWord := Copy(RichEdit.Lines[iLineIndex], iWordStart + 1, iWordEnd - iWordStart);
    end;

    // We save the current cursor position
    SaveSelStart := RichEdit.SelStart;
    // We hide the selection marker
    RichEdit.Perform(Messages.WM_USER + 63, WPARAM(TRUE), LPARAM(FALSE));
    // Position the cursor at the beginning of the word
    RichEdit.SelStart := iCharIndex;
    // Expand the selection to select the entire word
    RichEdit.SelLength := length(theWord);
    // If the word is a URL
    if pos('http', theWord) = 1 then
    begin // We put it in blue with an underlined note.
      RichEdit.SelAttributes.Color := clBlue;
      RichEdit.SelAttributes.Style := [fsUnderline];
    end else begin // Otherwise, we restore the default color (here, black).
      RichEdit.SelAttributes.Color := clBlack;
      RichEdit.SelAttributes.Style := [];
    end;
    // We return the cursor to its initial position
    RichEdit.SelStart := SaveSelStart;
    // The cursor is made visible again.
    RichEdit.Perform(Messages.WM_USER + 63, WPARAM(FALSE), LPARAM(FALSE));
  end;
end;

end.
 