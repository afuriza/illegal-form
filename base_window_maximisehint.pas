unit base_window_maximisehint;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  BCPanel, qt5, qtwidgets;

type

  { TfrMaximiseHint }

  TfrMaximiseHint = class(TForm)
    BCPanel1: TBCPanel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frMaximiseHint: TfrMaximiseHint;

implementation

{$R *.lfm}

{ TfrMaximiseHint }

procedure TfrMaximiseHint.FormCreate(Sender: TObject);
begin
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
end;

end.

