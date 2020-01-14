program Fishfact;

{$MODE Delphi}

uses
  Forms, Interfaces,
  Ffactwin in 'FFACTWIN.PAS' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
