

program WebsitePicker;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  MyHTTPs in 'MyHTTPs.pas',
  FunctionsChain in 'FunctionsChain.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
