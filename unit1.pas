unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, LCLIntf,
  StdCtrls, ExtCtrls, BCPanel, BCButton, BCListBox, Unit2,
  {$ifdef LCLQT5}
  qt5, qtwidgets,
  QtWSForms,
  {$endif}
  InterfaceBase, LCLPlatformDef, LMessages, base_window;

type

  { TForm1 }

  TForm1 = class(TForm)
    BCPanel1: TBCPanel;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    mouseHandled: boolean;
    mouseX: integer;
    mouseY: integer;
    formX: integer;
    formY: integer;
    procedure WMWindowPosChanged(var Message: TLMWindowPosChanged); message
      LM_CHECKRESIZE;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
{$IFDEF WINDOWS}
var
  Transparency: longint;
{$endif}
begin
  mouseHandled:=false;

  //QWidget_setVisible(TQtMainWindow(Self.Handle).GetContainerWidget, false);
  //TQtWidget(BCPanel1.Handle).setParent(TQtMainWindow(Self.Handle).Widget);
  {$ifdef LCLQT5}
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);


    Button1.Caption:= 'qt5';
  {$endif}
  {$IFDEF WINDOWS}
  Self.Color := clRed;
  Transparency := Self.Color;
  SetTranslucent(Self.Handle, Transparency, 0);
  {$endif}
  BCPanel1.Align:=alClient;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  frBaseWindow.Show;
  //ShowMessage('clicked');
  //Width:=Width+10;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

begin

end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  //Panel1.Height:=Height;
  //Panel1.Width:=Width;

end;

procedure TForm1.WMWindowPosChanged(var Message: TLMWindowPosChanged);
begin
  Caption := IntToStr(StrToInt(Caption)+ 1);
end;

procedure TForm1.FormShow(Sender: TObject);
var
  rgn: HRGN;
  rgnn: TRegion;
begin
  rgn := CreateRoundRectRgn(
    0,
    1,
    ClientWidth,
    ClientHeight,
    10,
    10
  );
  //SetWindowRgn(Handle, rgn, true);
  rgnn.Handle:=rgn;
  //Form2.Parent := BCPanel1;
  //Form2.Show;
  //Form2.Align:=alClient;
  //SetShape(rgnn);
end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouseX:= x;
  mouseY:= Y;
  formX := Left;
  formY := Top;
  mouseHandled:=true;
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  currentX: integer;
  currentY: integer;
begin
  currentX := mouseX - formX;
  currentY := mouseY - mouseY;
  if mouseHandled then
  begin
    //Top := Mouse.CursorPos.Y - mouseY;
    //Left := Mouse.CursorPos.X - mouseX;
    SetBounds(Mouse.CursorPos.X - mouseX, Mouse.CursorPos.Y - mouseY, Width, Height);
    //message
  end;


end;

procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouseHandled:=false;
end;

end.

