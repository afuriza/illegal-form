unit base_window;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, StdCtrls, ComCtrls, Controls, Graphics, Dialogs,
  ExtCtrls, BCPanel, BCButton,
  {$ifdef LCLQT5}
  qt5, qtwidgets, QtWSForms,
  {$endif}
  LMessages,
  LCLIntf, LCLType, DateUtils, base_window_maximisehint, BGRABitmap, BCTypes,
  BCMaterialDesignButton, BGRASVGImageList, BGRABitmapTypes, Unit2;

type

  { TfrBaseWindow }

  TfrBaseWindow = class(TForm)
    BGRASVGImageList1: TBGRASVGImageList;
    Image1: TImage;
    imgTitleBar: TImage;
    lbTitlebar: TLabel;
    pnDrag: TPanel;
    pnBackground: TPanel;
    pnContainer: TBCPanel;
    pnControlWindow: TPanel;
    pnTitleBar: TPanel;
    procedure btCloseWindowClick(Sender: TObject);
    procedure btMaximiseWindowClick(Sender: TObject);
    procedure btMinimizeWindowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure imgTitleBarResize(Sender: TObject);
    procedure pnContainerDblClick(Sender: TObject);
    procedure pnContainerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnContainerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnContainerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnControlWindowResize(Sender: TObject);
    procedure pnDragMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnDragMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure pnDragMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnDragPaint(Sender: TObject);
  private
    embeddedForm: TForm;
    handlePos: boolean;
    handleSize: boolean;
    handleHeightTop: boolean;
    handleHeightBot: boolean;
    handleWidthLeft: boolean;
    handleWidthRight: boolean;
    formX: integer;
    formY: integer;
    mouseX: integer;
    mouseY: integer;
    prevHeight: integer;
    prevWidth: integer;
    prevTop: integer;
    prevLeft: integer;
    procedure setBaseWindowState;
    procedure setClientWindowRect;
    procedure paintPnDrag;
  public
    fillWindow: boolean;
    procedure setFillWindow;
  end;

var
  frBaseWindow: TfrBaseWindow;

implementation

{$R *.lfm}

{ TfrBaseWindow }

procedure TfrBaseWindow.setBaseWindowState;
begin
  if WindowState = wsMaximized then
  begin
    WindowState:=wsNormal;
    Height:=prevHeight;
    Width:=prevWidth;
    Top:=prevTop;
    Left:=prevLeft;
    pnBackground.BorderSpacing.Around:=5;
  end
  else
  begin
    pnBackground.BorderSpacing.Around:=0;
    prevHeight:=Height;
    prevWidth:=Width;
    prevTop:=Top;
    prevLeft:=Left;
    Width:=Screen.WorkAreaWidth;
    Height:=Screen.WorkAreaHeight;
    WindowState:=wsMaximized;
  end;

end;

procedure TfrBaseWindow.FormCreate(Sender: TObject);
begin
  fillWindow:=true;


  {$ifdef LCLQT5}
  //QT5 Translucent Window
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
  {$endif}
end;

procedure TfrBaseWindow.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

end;

procedure TfrBaseWindow.FormResize(Sender: TObject);
begin
  setClientWindowRect;
end;

procedure TfrBaseWindow.btCloseWindowClick(Sender: TObject);
begin
  Close;
end;

procedure TfrBaseWindow.btMaximiseWindowClick(Sender: TObject);
begin
  setBaseWindowState;
end;

procedure TfrBaseWindow.btMinimizeWindowClick(Sender: TObject);
begin
  WindowState:=wsMinimized;
end;

procedure TfrBaseWindow.setFillWindow;
begin
  if Assigned(embeddedForm) then
  begin
    if fillWindow then
    begin
      pnTitleBar.Parent := embeddedForm;
      pnTitleBar.Align:=alTop;
      pnTitleBar.Align:=alNone;
      pnTitleBar.Anchors:=[akLeft, akTop, akRight];
      pnTitleBar.BringToFront;
      imgTitleBar.Visible:=false;
      lbTitlebar.Visible:=false;
    end
    else
    begin
      pnTitleBar.Parent := pnContainer;
      pnTitleBar.Align:=alTop;
      imgTitleBar.Visible:=true;
      lbTitlebar.Visible:=true;
    end;
  end;
end;

procedure TfrBaseWindow.FormShow(Sender: TObject);

begin
  embeddedForm := Form2;
  if Assigned(embeddedForm) then
  begin
    OnClose:=embeddedForm.OnClose;
    OnWindowStateChange := embeddedForm.OnWindowStateChange;
    embeddedForm.Parent:=pnContainer;
    embeddedForm.BorderStyle:=bsNone;
    embeddedForm.Align:=alClient;

    embeddedForm.Show;
    embeddedForm.BorderSpacing.Around:=1;
    setFillWindow;
  end;
end;

procedure TfrBaseWindow.FormWindowStateChange(Sender: TObject);
begin

end;

procedure TfrBaseWindow.imgTitleBarResize(Sender: TObject);
begin

end;

procedure TfrBaseWindow.pnContainerDblClick(Sender: TObject);
begin
  setBaseWindowState;
end;

procedure TfrBaseWindow.pnContainerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  formX := Mouse.CursorPos.X - Left;
  formY := Mouse.CursorPos.Y - Top;
  mouseX := Mouse.CursorPos.X;
  mouseY := Mouse.CursorPos.Y;
  handlePos:=true;
end;

procedure TfrBaseWindow.pnContainerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if handlePos then
  begin
    if WindowState = wsMaximized then
    begin
      if (Mouse.CursorPos.y- mouseY) > 4 then
      begin
        setBaseWindowState;
        formX:=Width div 2;
      end;
    end
    else
    begin
      if (Mouse.CursorPos.Y <= 25) and (Top <= 1) then
      begin
        frMaximiseHint.Show;
        BringToFront;
      end
      else
      begin
        frMaximiseHint.Hide;
      end;
      Left := Mouse.CursorPos.X - formX;
      Top := Mouse.CursorPos.Y - formY;
    end;
  end;

end;

procedure TfrBaseWindow.pnContainerMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (WindowState = wsNormal) then
  begin
    if (Mouse.CursorPos.Y <= 25) and (Top <= 1) then
    begin
      setBaseWindowState;
    end;
  end;
  handlePos:=false;
  frMaximiseHint.Hide;
end;

procedure TfrBaseWindow.pnControlWindowResize(Sender: TObject);
begin
  //btMinimizeWindow.Width:=btMinimizeWindow.Height;
  //btMaximiseWindow.Width:=btMinimizeWindow.Height;
  //btCloseWindow.Width:=btMinimizeWindow.Height;
end;

procedure TfrBaseWindow.pnDragMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  handleSize:=true;

  formX := Mouse.CursorPos.X - Left;
  formY := Mouse.CursorPos.Y - Top;
  prevHeight:=Height;
  prevWidth:=width;
  mouseX := Mouse.CursorPos.X;
  mouseY := Mouse.CursorPos.Y;

  handleHeightTop:=false;
  handleHeightBot:=false;
  handleWidthLeft:=false;
  handleWidthRight:=false;
  //top
  if ((x >= 8) and (x <= pnDrag.Width-8)) and (y <= 8) then
  begin
      handleHeightTop := true;
  end
  //bot
  else if ((x >= 8) and (x <= pnDrag.Width-8)) and (y >= pnDrag.Height - 8) then
  begin
      handleHeightBot := true;
  end
  //left
  else if ((y >= 8) and (y <= pnDrag.Height -8)) and (x <= 8) then
  begin
      handleWidthLeft := true;
  end
  //right
  else if ((y >= 8) and (y <= pnDrag.Height -8)) and (x >= -8) then
  begin
      handleWidthRight := true;
  end
  //top-left
  else if (y <= 8) and (x <= 8) then
  begin
      handleWidthLeft:=true;
      handleHeightTop:=true;
  end
  //bot-left
  else if (y >= pnDrag.Height -8) and (x <= 8) then
  begin
      handleHeightBot:=true;
      handleWidthLeft:=true;
  end
  //top-right
  else if (y <= 8) and (x >= pnDrag.Width - 8) then
  begin
      handleHeightTop:=true;
      handleWidthRight:=true;
  end
  //botright
  else if (y >= pnDrag.Height -8) and (x >= pnDrag.Height -8) then
  begin
      handleHeightBot:=true;
      handleWidthRight:=true;
  end;
end;

procedure TfrBaseWindow.pnDragMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  newHeight, newWidth, newTop, newLeft: integer;
begin
  newHeight := Height;
  newWidth := Width;
  newTop := Top;
  newLeft := Left;
  if handleSize and handleHeightTop and handleWidthLeft then
  begin
    newTop := Mouse.CursorPos.Y - formY;
    newHeight := prevHeight - (Mouse.CursorPos.Y - mousey);
    newLeft := Mouse.CursorPos.X - formX;
    newWidth := prevWidth - (Mouse.CursorPos.X - mouseX);
  end
  else if handleSize and handleHeightTop and handleWidthRight then
  begin
    newTop := Mouse.CursorPos.Y - formY;
    newHeight := prevHeight - (Mouse.CursorPos.Y - mousey);
    newWidth := prevWidth + (Mouse.CursorPos.X - mouseX);
  end
  else if handleSize and handleHeightBot and handleWidthLeft then
  begin
    newHeight := prevHeight + (Mouse.CursorPos.Y - mousey);
    newLeft := Mouse.CursorPos.X - formX;
    newWidth := prevWidth - (Mouse.CursorPos.X - mouseX);
  end
  else if handleSize and handleHeightBot and handleWidthRight then
  begin
    newHeight := prevHeight + (Mouse.CursorPos.Y - mousey);
    newWidth := prevWidth + (Mouse.CursorPos.X - mouseX);
  end
  else if handleSize and handleHeightTop then
  begin
    newTop := Mouse.CursorPos.Y - formY;
    newHeight := prevHeight - (Mouse.CursorPos.Y - mousey);
  end
  else if handleSize and handleHeightBot then
  begin
    newHeight := prevHeight + (Mouse.CursorPos.Y - mousey);
  end
  else if handleSize and handleWidthLeft then
  begin
    newLeft := Mouse.CursorPos.X - formX;
    newWidth := prevWidth - (Mouse.CursorPos.X - mouseX);
  end
  else if handleSize and handleWidthRight then
  begin
    newWidth := prevWidth + (Mouse.CursorPos.X - mouseX);
  end;

  if (newHeight > 30) and (newWidth > 50) then
  begin
    Top := newTop;
    Left := newLeft;
    Height := newHeight;
    Width := newWidth;
  end;

  //top
  if ((x >= 8) and (x <= pnDrag.Width-8)) and (y <= 8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor := crSizeN;
    end;
  end
  //bot
  else if ((x >= 8) and (x <= pnDrag.Width-8)) and (y >= pnDrag.Height - 8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor := crSizeS;
    end;
  end
  //left
  else if ((y >= 8) and (y <= pnDrag.Height -8)) and (x <= 8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor := crSizeW;
    end;
  end
  //right
  else if ((y >= 8) and (y <= pnDrag.Height -8)) and (x >= -8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor := crSizeW;
    end;
  end
  //top-left
  else if (y <= 8) and (x <= 8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor:=crSizeNW;
    end;
  end
  //bot-left
  else if (y >= pnDrag.Height -8) and (x <= 8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor:=crSizeSW;
    end;
  end
  //top-right
  else if (y <= 8) and (x >= pnDrag.Width - 8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor:=crSizeNE;
    end;
  end
  //botright
  else if (y >= pnDrag.Height -8) and (x >= pnDrag.Height -8) then
  begin
    if not handleSize then
    begin
      pnDrag.Cursor:=crSizeSE;
    end;
  end
  else
  begin
    if not handleSize then
      pnDrag.Cursor:=crDefault;
  end;
end;

procedure TfrBaseWindow.pnDragMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  handleSize:=false;
  handleHeightTop:=false;
  handleHeightBot:=false;
  handleWidthLeft:=false;
  handleWidthRight:=false;
  setClientWindowRect;
end;

procedure TfrBaseWindow.setClientWindowRect;
var
  rgn: HRGN;
  rrgn1, rrgn2: integer;
begin
  if Assigned(embeddedForm) then
  begin



    if WindowState = wsMaximized then
    begin
      rrgn1:=0;
      rrgn2:=0;
      pnContainer.Border.Width:=0;
      pnContainer.Rounding.RoundX:=1;
      pnContainer.Rounding.RoundX:=1;

    end
    else
    begin
      rrgn1:=20;
      rrgn2:=20;
      pnContainer.Border.Width:=1;
      pnContainer.Rounding.RoundX:=5;
      pnContainer.Rounding.RoundX:=5;
      if (embeddedForm.Align <> alNone) and (handleSize) then
      begin
        embeddedForm.Align:=alNone;
        embeddedForm.Top:=3;
        embeddedForm.Left:=3;
        embeddedForm.Width:=Width;
        embeddedForm.Height:=Height;
      end else
      if (embeddedForm.Align <> alClient) and (not handleSize) then
        embeddedForm.Align:=alClient;
    end;
    if Assigned(embeddedForm) and (not handleSize) then
    begin
      if fillWindow then
        rgn := CreateRoundRectRgn(
          0,
          -2,
          embeddedForm.Width,
          embeddedForm.Height,
          rrgn1,
          rrgn2
        )
      else
        rgn := CreateRoundRectRgn(
          -2,
          -7,
          embeddedForm.Width,
          embeddedForm.Height,
          rrgn1,
          rrgn2
        );
      SetWindowRgn(embeddedForm.Handle, rgn, true);
    end;
  end;
end;

procedure TfrBaseWindow.paintPnDrag;
var
  bmp: TBGRABitmap;
  rgn: HRGN;
  rrgn1, rrgn2: integer;
begin
  bmp := TBGRABitmap.Create(pnDrag.Width, pnDrag.Height);
  bmp.SetSize(pnDrag.Width, pnDrag.Height);
  bmp.RoundRectAntialias(pnBackground.BorderSpacing.Around*2,
    pnBackground.BorderSpacing.Around*2, pnBackground.Width,
    pnBackground.Height, pnBackground.BorderSpacing.Around,
    pnBackground.BorderSpacing.Around,
    BGRA(0, 0, 0, 200), 1, BGRA(0, 0, 0, 200), [rrDefault]);
  BGRAReplace(bmp, bmp.FilterBlurRadial(10,
    10, rbFast) as TBGRABitmap);
  bmp.EraseRoundRectAntialias(pnBackground.BorderSpacing.Around,
    pnBackground.BorderSpacing.Around, pnBackground.Width,
    pnBackground.Height, pnBackground.BorderSpacing.Around,
    pnBackground.BorderSpacing.Around, 255, [rrDefault]);
  bmp.Draw(pnDrag.Canvas, 0, 0, false);
  bmp.Free;

  if WindowState = wsMaximized then
  begin
    rrgn1:=0;
    rrgn2:=0;
    pnContainer.Border.Width:=0;
    pnContainer.Rounding.RoundX:=1;
    pnContainer.Rounding.RoundX:=1;
  end
  else
  begin
    rrgn1:=20;
    rrgn2:=20;
    pnContainer.Border.Width:=1;
    pnContainer.Rounding.RoundX:=5;
    pnContainer.Rounding.RoundX:=5;
  end;
end;

procedure TfrBaseWindow.pnDragPaint(Sender: TObject);
begin
  if (WindowState <> wsMaximized) and (not handleSize) then
  begin
    paintPnDrag;
  end
end;

end.

