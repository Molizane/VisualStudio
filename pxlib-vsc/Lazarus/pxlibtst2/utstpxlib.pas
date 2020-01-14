unit uTstPxlib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, paradox, Forms, Controls, Graphics, Dialogs,
  DbCtrls, DBGrids;

type

  { TForm1 }

  TForm1 = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBImage1: TDBImage;
    DBMemo1: TDBMemo;
    DBNavigator1: TDBNavigator;
    Paradox1: TParadox;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Paradox1.Open;
end;

end.

