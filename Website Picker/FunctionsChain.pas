unit FunctionsChain;

interface


function right(substr: string; s: string): string;
function rightlink(substr: string; s: string): string;
function left(substr: string; s: string): string;
function NbSubString(substr: string; s: string): integer;
function Nright(substr: string; s: string;n:integer): string;
function leftNDright(substr: string; s: string;n:integer): string;

implementation

function right(substr: string; s: string): string;
begin
  if pos(substr,s)=0 then result:='' else
    result:=copy(s,
                 pos(substr, s)+length(substr),
                 length(s)-pos(substr, s)+length(substr));
end;

function rightlink(substr: string; s: string): string;
begin
  Repeat
    S:=right(substr,s);
  until pos(substr,s)=0;
  result:=S;
end;

function left(substr: string; s: string): string;
{============================================================================}
{ function that returns the substring located to the left of the substring   }
{ string substr                                                              }
{ e.g., if substr = '\' and S = 'truc\tr\essai.exe', left returns truc       }
{============================================================================}
begin
  result:=copy(s, 1, pos(substr, s)-1);
end;

function NbSubString(substr: string; s: string): integer;
{============================================================================}
{ returns the number of times the substring substr appears in the string S   }
{============================================================================}
begin
  result:=0;
  while pos(substr,s)<>0 do
  begin
    S:=right(substr,s);
    inc(result);
  end;
end;

function Nright(substr: string; s: string;n:integer): string;
{============================================================================}
{ returns what is to the right of the nth substring of the string S          }
{============================================================================}
var i:integer;
begin
  for i:=1 to n do
  begin
    S:=right(substr,s);
  end;
  result:=S;
end;

function leftNDright(substr: string; s: string;n:integer): string;
{==============================================================================}
{ returns what is to the left of the right of the nth substring                }
{ from the S chain                                                             }
{ e.g.: LeftRight('/','c:machin\truc\essai.exe',1) returns 'truc'              }
{ Allows you to extract elements from a string one by one, separated           }
{ by a separator.                                                              }
{==============================================================================}
var i:integer;
begin
  S:=S+substr;
  for i:=1 to n do
  begin
    S:=copy(s, pos(substr, s)+length(substr),
            length(s)-pos(substr, s)+length(substr));
  end;
  result:=copy(s, 1, pos(substr, s)-1);
end;


end.
