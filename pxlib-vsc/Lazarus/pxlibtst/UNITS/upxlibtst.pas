unit upxlibtst;

{$mode objfpc}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids;

type
  { TForm1 }
  TForm1 = class(TForm)
    btnTest: TButton;
    StringGrid1: TStringGrid;
    procedure btnTestClick(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

uses
  ctypes, pxlib;

{$R *.lfm}

procedure ReadRecords(pxh: pxhead_t; pxdoc: Ppxdoc_t);
var
  offset: longword;
  j, i: integer;
  {$ifndef windows}
  year, month, day: integer;
  {$endif}
  mod_nr, ret: integer;
  size: cint;

  Data: Pcchar;
  pxf: Ppx_field;

  PCharData: PChar;
  LongVal: longint;
  //ShortIntVal: shortint;
  SmallIntVal: smallint;
  DoubleVal: double;
  ByteVal: byte;
  blobdata: PByte;
  Buffer: string;
begin
  Data := AllocMem(pxdoc^.px_head^.px_recordsize);

  try
    pxf := pxh.px_fields;

    Form1.StringGrid1.RowCount := pxh.px_numrecords + 1;
    Form1.StringGrid1.ColCount := pxh.px_numfields + 1;

    for i := 1 to pxh.px_numfields do
    begin
      Form1.StringGrid1.Cells[i, 0] := pxf^.px_fname;
      Inc(pxf);
    end;

    for j := 0 to pxh.px_numrecords - 1 do
    begin
      Form1.StringGrid1.Cells[0, j + 1] := IntToStr(j + 1);

      if (PX_get_record(pxdoc, j, Data) <> nil) then
      begin
        Buffer := '';
        offset := 0;
        pxf := pxh.px_fields;

        for i := 0 to pxh.px_numfields - 1 do
        begin
          Buffer := '-_-_-_';

          case pxf^.px_ftype of
            pxfAlpha:
            begin
              if (0 < PX_get_data_alpha(pxdoc, @Data[offset], pxf^.px_flen,
                @PCharData)) then
              begin
                Buffer := PCharData;
                pxdoc^.Free(pxdoc, PCharData);
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfDate:
            begin
              if (0 < PX_get_data_long(pxdoc, @Data[offset], pxf^.px_flen,
                @LongVal)) then
              begin
                {$ifndef windows}
                PX_SdnToGregorian(LongVal + 1721425, year, month, day);
                {$endif}
                Buffer := IntToStr(LongVal);
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfShort:
            begin
              if (0 < PX_get_data_short(pxdoc, @Data[offset], pxf^.px_flen,
                @SmallIntVal)) then
              begin
                Buffer := IntToStr(SmallIntVal);
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfAutoInc,
            pxfLong:
            begin
              if (0 < PX_get_data_long(pxdoc, @Data[offset], pxf^.px_flen,
                @LongVal)) then
              begin
                Buffer := IntToStr(LongVal);
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfTimestamp:
            begin
              if (0 < PX_get_data_double(pxdoc, @Data[offset],
                pxf^.px_flen, @DoubleVal)) then
              begin
                PCharData := PX_timestamp2string(pxdoc, DoubleVal, 'Y-m-d H:i:s');
                Buffer := PCharData;
                pxdoc^.Free(pxdoc, PCharData);
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfTime:
            begin
              if (0 < PX_get_data_long(pxdoc, @Data[offset], pxf^.px_flen,
                @LongVal)) then
              begin
                Buffer := IntToStr(LongVal);
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfCurrency,
            pxfNumber:
            begin
              if (0 < PX_get_data_double(pxdoc, @Data[offset],
                pxf^.px_flen, @DoubleVal)) then
              begin
                Buffer := FloatToStr(DoubleVal);
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfLogical:
            begin
              if (0 < PX_get_data_Byte(pxdoc, @Data[offset], pxf^.px_flen,
                @ByteVal)) then
              begin
                if (ByteVal <> 0) then
                  Buffer := 'True'
                else
                  Buffer := 'False';
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfBLOb,
            pxfGraphic,
            pxfOLE,
            pxfMemoBLOb,
            pxfFmtMemoBLOb:
            begin
              if (pxf^.px_ftype = pxfGraphic) then
                ret := PX_get_data_graphic(pxdoc, @Data[offset],
                  pxf^.px_flen, @mod_nr, @size, @blobdata)
              else
                ret := PX_get_data_blob(pxdoc, @Data[offset], pxf^.px_flen,
                  @mod_nr, @size, @blobdata);

              if (ret > 0) then
              begin
                if (blobdata <> nil) then
                begin
                  if (pxf^.px_ftype = pxfGraphic) then
                    Buffer := '<Imagem>'
                  else if (pxf^.px_ftype in [pxfBLOb, pxfMemoBLOb, pxfFmtMemoBLOb]) then
                    Buffer := PChar(blobdata)
                  else //if (pxf^.px_ftype = pxfBLOb) then
                    Buffer := '<OLE>';

                  pxdoc^.Free(pxdoc, blobdata);
                end
                else
                begin
                  Buffer := '*** ERRO ***';
                end;
              end
              else
              begin
                Buffer := '*** ERRO ***';
              end;
            end;

            pxfBCD:
            begin
              ret := PX_get_data_bcd(pxdoc, @Data[offset], pxf^.px_fdc, @ByteVal);

              if (0 < ret) then
              begin
                Buffer := IntToStr(ByteVal);
                pxdoc^.Free(pxdoc, @ByteVal);
              end
              else if (ret = 0) then
              begin
                Buffer := '*** ERRO (1) ***';
              end
              else
              begin
                Buffer := '*** ERRO (2) ***';
              end;
            end;

            pxfBytes:
            begin
              Buffer := '<Bytes>';
            end;
            else
              Buffer := '(' + IntToStr(pxf^.px_ftype) + ')???';
          end;

          Form1.StringGrid1.Cells[i + 1, j + 1] := Buffer;
          Inc(offset, pxf^.px_flen);
          Inc(pxf);
        end;
      end
      else
        raise Exception.Create(Format('Couldn''t get record number %d'#13#10, [j]));
    end;
  finally
    Freemem(Data, pxdoc^.px_head^.px_recordsize);
  end;
end;

procedure TForm1.btnTestClick(Sender: TObject);
var
  a, b, c, d, e, f: integer;
  g: PChar;
  hDb, hMb: integer;
  s: string;
  pxdoc: Ppxdoc_t;
  fpDB, fpMB: PChar;
  //Data: array of byte;
  //PData: PByte;
begin
  PX_boot();

  try
    a := PX_get_majorversion();
    b := PX_get_minorversion();
    c := PX_get_subminorversion();
    d := PX_has_recode_support();
    e := PX_has_gsf_support();
    f := PX_is_bigendian();
    g := PX_get_builddate();

    //FillByte(pxdoc, sizeof(px_doc), 0);
    pxdoc := PX_new();

    try
      //fpDB := 'C:\etc\cias.db'#0;
      //fpDB := 'C:\etc\fa24.db'#0;
      fpDB := 'C:\etc\biolife.db'#0;
      hDb := PX_open_file(pxdoc, fpDB);

      fpMB := 'C:\etc\biolife.mb'#0;
      PX_new_blob(pxdoc);
      hMb := PX_open_blob_file(pxdoc^.px_blob, fpMB);

      try
        {
        SetLength(Data, pxdoc^.px_head^.px_recordsize + 20);
        Pdata := @Data;

        try
          PX_get_record(pxdoc, 1, @PData);
        finally
          //Freemem(Data, pxdoc^.px_head^.px_recordsize);
          SetLength(Data, 0);
        end;
        }

        ReadRecords(pxdoc^.px_head^, pxdoc);
      finally
        PX_close(pxdoc);
      end;
    finally
      PX_delete(pxdoc);
    end;
  finally
    PX_shutdown();
  end;

  s := Format(#13#10 + 'Major version: %d'#13#10 + 'Minor version: %d'#13#10 +
    'Subminor version: %d'#13#10 + 'Has recode support: %d'#13#10 +
    'Has GSF support: %d'#13#10 + 'Is Big Endian: %d'#13#10 +
    'Buid date: %s'#13#10 + 'Open DB file: %d'#13#10 + 'Open MB file: %d'#13#10,
    [a, b, c, d, e, f, g, hDb, hMb]);

  ShowMessage(s);
end;

end.
