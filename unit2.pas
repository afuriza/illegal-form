unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  BCPanel, BCListBox, BGRABitmap, BCTypes, BCMaterialDesignButton, BCButton,
  BGRABitmapTypes;

type

  { TForm2 }

  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    MyProperty1: TBCButton;
    MySampleButton: TBCButton;
    Panel1: TPanel;
    procedure BCPanel1Resize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Panel1Paint(Sender: TObject);
  private
    fbgrashadow: TBGRABitmap;
  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure SingleColor(Bitmap: TBGRABitmap; Color: TBGRAPixel);
var
  i: integer;
  p: PBGRAPixel;
begin
  p := Bitmap.Data;

  for i := Bitmap.NBPixels - 1 downto 0 do
  begin
    p^.red := Color.Red;
    p^.green := Color.Green;
    p^.blue := Color.Blue;
    Inc(p);
  end;
end;

function Shadow(Source: TBGRABitmap; Color: TBGRAPixel; Blur: integer): TBGRABitmap;
begin
  Result := TBGRABitmap.Create(Source.Width + (2 * Blur), Source.Height + (2 * Blur));
  Result.PutImage(Blur, Blur, Source, dmDrawWithTransparency);
  SingleColor(Result, Color);
  BGRAReplace(Result, Result.FilterBlurRadial(Blur, rbFast));
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ShowMessage('closed');
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  //Shadow(BCPanel1.);
  fbgrashadow := TBGRABitmap.Create(100, 100);
  FBGRAShadow.FillTransparent;
  //if FShadow then
  //begin
    FBGRAShadow.RoundRectAntialias(5, 5, 90,
      90, 5, 5,
      BGRA(10, 30, 40, 100), 1, BGRA(10, 30, 40, 100), [rrDefault]);
    BGRAReplace(FBGRAShadow, FBGRAShadow.FilterBlurRadial(10,
      10, rbFast) as TBGRABitmap);
    fbgrashadow.EraseRoundRectAntialias(5, 5, 90,
      90, 5, 5, 255, [rrDefault]);

  //end;
end;

procedure TForm2.FormPaint(Sender: TObject);
begin

end;

procedure TForm2.FormResize(Sender: TObject);
begin


end;

procedure TForm2.Panel1Paint(Sender: TObject);
begin
  //fbgrashadow.Draw(Panel1.Canvas, 0, 0, false);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin

end;

procedure TForm2.BCPanel1Resize(Sender: TObject);
begin

end;

end.

