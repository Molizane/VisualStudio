unit Ffactwin;

{$MODE Delphi}

{ This application shows how to display Paradox style memo and graphic
 fields in a form. Table1's DatabaseName property should point to the
 Delphi sample database. Table1's TableName property should be set to 
 the BIOLIFE table. }

interface

uses
  SysUtils, LCLIntf, LCLType, LMessages, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, DBCtrls, DBGrids, DB, sqldb, Buttons, Grids, ExtCtrls,
  paradox;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBImage1: TDBImage;
    DBLabel1: TDBText;
    DBLabel2: TDBText;
    DBMemo1: TDBMemo;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Table1: TParadox;
    Table1Category1: TStringField;
    Table1Common_Name1: TStringField;
    Table1Graphic1: TBlobField;
    Table1Lengthcm1: TFloatField;
    Table1Length_In1: TFloatField;
    Table1Notes1: TMemoField;
    Table1SpeciesName1: TStringField;
    procedure FormShow(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin
  Table1.Open;
end;

end.
