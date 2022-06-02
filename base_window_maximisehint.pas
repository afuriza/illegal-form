unit base_window_maximisehint;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  {$ifdef LCLQT5}
  qt5, qtwidgets,
  {$endif}
  BCPanel
  ;

type

  { TfrMaximiseHint }

  TfrMaximiseHint = class(TForm)
    BCPanel1: TBCPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frMaximiseHint: TfrMaximiseHint;

implementation
uses
  base_window;

{$R *.lfm}

{ TfrMaximiseHint }

procedure TfrMaximiseHint.FormCreate(Sender: TObject);
{$IFDEF WINDOWS}
var
  Transparency: longint;
{$endif}
begin
  {$ifdef LCLQT5}
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
  {$endif}
  {$IFDEF WINDOWS}
  Self.Color := clRed;
  Transparency := Self.Color;
  SetTranslucent(Self.Handle, Transparency, 0);
  {$endif}
  WindowState := wsMaximized;

end;

procedure TfrMaximiseHint.FormShow(Sender: TObject);
begin

end;

end.

