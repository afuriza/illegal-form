unit base_window;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, StdCtrls, ComCtrls, Controls, Graphics, Dialogs,
  ExtCtrls, BCPanel, BCButton,
  {$ifdef LCLQT5}
  qt5, qtwidgets, QtWSForms,
  {$endif}
  {$IFDEF WINDOWS}
  windows,
  {$endif}
  LMessages, LCLIntf, LCLType, DateUtils, base_window_maximisehint, BGRABitmap,
  BCTypes, BCMaterialDesignButton, BGRASVGImageList, uPSI_BGRAPascalScript,
  BGRABitmapTypes, Unit2;

{$IFDEF WINDOWS}
{Function SetLayeredWindowAttributes Lib "user32" (ByVal hWnd As Long, ByVal Color As Long, ByVal X As Byte, ByVal alpha As Long) As Boolean }
function SetLayeredWindowAttributes(hWnd: longint; Color: longint;
  X: byte; alpha: longint): bool stdcall; external 'USER32';

{not sure how to alias these functions here ????   alias setwindowlonga!!}
{Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long }
function SetWindowLongA(hWnd: longint; nIndex: longint;
  dwNewLong: longint): longint stdcall; external 'USER32';

{Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long) As Long }
function GetWindowLongA(hWnd: longint; nIndex: longint): longint stdcall;
  external 'user32';

procedure SetTranslucent(ThehWnd: longint; Color: longint; nTrans: integer);

{$endif}


type

  { TfrBaseWindow }

  TfrBaseWindow = class(TForm)
    imgMaximize: TImage;
    imgClose: TImage;
    imgList: TImageList;
    svgList: TBGRASVGImageList;
    imgMinimize: TImage;
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
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure imgMinimizePaint(Sender: TObject);
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
    prevState: TWindowState;
    procedure setBaseWindowState;
    procedure setClientWindowRect;
    procedure paintPnDrag;
  public
    fillWindow: boolean;
    procedure setFillWindow;
  end;

const
  LWA_COLORKEY = 1;
  LWA_ALPHA = 2;
  LWA_BOTH = 3;
  WS_EX_LAYERED = $80000;
  GWL_EXSTYLE = -20;

var
  frBaseWindow: TfrBaseWindow;

implementation

{$R *.lfm}

{$IFDEF WINDOWS}
procedure SetTranslucent(ThehWnd: longint; Color: longint; nTrans: integer);
var
  Attrib: longint;
begin
  {SetWindowLong and SetLayeredWindowAttributes are API functions, see MSDN for details }
  Attrib := GetWindowLongA(ThehWnd, GWL_EXSTYLE);
  SetWindowLongA(ThehWnd, GWL_EXSTYLE, attrib or WS_EX_LAYERED);
  {anything with color value color will completely disappear if flag = 1 or flag = 3  }
  SetLayeredWindowAttributes(ThehWnd, Color, nTrans, 1);
end;
{$ENDIF}

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
    prevState:=wsNormal;
  end
  else if WindowState = wsNormal then
  begin
    pnBackground.BorderSpacing.Around:=0;
    prevHeight:=Height;
    prevWidth:=Width;
    prevTop:=Top;
    prevLeft:=Left;

    {$ifdef Windows}
    WindowState:=wsMaximized;
    {$endif}
    Width:=Screen.WorkAreaWidth;
    Height:=Screen.WorkAreaHeight;
    Top := 0;
    Left := 0;
    {$ifdef LCLQT5}
    WindowState:=wsMaximized;
    {$endif}


    prevState:=wsMaximized;
  end;

end;

procedure TfrBaseWindow.FormCreate(Sender: TObject);
{$IFDEF WINDOWS}
var
  Transparency: longint;
{$endif}
begin
  fillWindow:=true;
  prevHeight:=0;
  prevWidth:=0;
  svgList.PopulateImageList(imgList, [imgMinimize.Height]);
  imgList.GetBitmap(0, imgClose.Picture.Bitmap);

  imgList.GetBitmap(1, imgMaximize.Picture.Bitmap);
  imgList.GetBitmap(3, imgMinimize.Picture.Bitmap);


  {$ifdef LCLQT5}
  //QT5 Translucent Window
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
  {$endif}
  {$IFDEF WINDOWS}
  Self.Color := clRed;
  Transparency := Self.Color;
  SetTranslucent(Self.Handle, Transparency, 0);
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
  paintPnDrag;
end;

procedure TfrBaseWindow.FormActivate(Sender: TObject);
begin
  if (WindowState <> wsMaximized) and (prevState = wsMaximized) and (not handlePos)
    and (not handleSize) then
  begin
    WindowState:=wsMaximized;
    setClientWindowRect;
    {$ifdef windows}
    Width:=Screen.WorkAreaWidth;
    Height:=Screen.WorkAreaHeight;
    {$endif}
  end
  else if (prevState = wsMaximized) and (not handlePos) then
  begin
    {$ifdef windows}
    Width:=Screen.WorkAreaWidth;
    Height:=Screen.WorkAreaHeight;
    {$endif} ;
  end;
end;

procedure TfrBaseWindow.setFillWindow;
begin
  if Assigned(embeddedForm) then
  begin
    if fillWindow then
    begin
      pnTitleBar.Parent := embeddedForm;
      //pnTitleBar.Align:=alTop;
      //pnTitleBar.Align:=alNone;
      pnTitleBar.Width := embeddedForm.Width;
      pnTitleBar.Anchors:=[akLeft, akTop, akRight];
      pnTitleBar.BringToFront;
      //imgTitleBar.Visible:=false;
      //lbTitlebar.Visible:=false;
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
    imgTitleBar.Picture.Icon := embeddedForm.Icon;
    OnWindowStateChange := embeddedForm.OnWindowStateChange;
    embeddedForm.Parent:=pnContainer;
    embeddedForm.BorderStyle:=bsNone;
    embeddedForm.Align:=alClient;

    embeddedForm.Show;
    embeddedForm.BorderSpacing.Around:=1;
    setFillWindow;
  end;

  if (WindowState <> wsMaximized) and (prevState = wsMaximized) and (not handlePos)
    and (not handleSize) then
  begin

    {$ifdef windows}
    WindowState:=wsMaximized;
    Width:=Screen.WorkAreaWidth;
    Height:=Screen.WorkAreaHeight;
    {$endif}
  end
  else if (prevState = wsMaximized) and (not handlePos) then
  begin
    {$ifdef windows}
    Width:=Screen.WorkAreaWidth;
    Height:=Screen.WorkAreaHeight;
    {$endif}
  end;
end;

procedure TfrBaseWindow.FormWindowStateChange(Sender: TObject);
begin

end;

procedure TfrBaseWindow.imgMinimizePaint(Sender: TObject);
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
        frMaximiseHint.Width:=Screen.WorkAreaWidth;
        frMaximiseHint.Height:=Screen.WorkAreaHeight;
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

  if (newHeight > 150) and (newWidth > 200) then
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
  pnDrag.Invalidate;
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

