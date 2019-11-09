unit unTabla;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, Menus;

type
  TFormTabla = class(TForm)
    sg: TStringGrid;
    PopupMenu1: TPopupMenu;
    Calcular1: TMenuItem;
    procedure sgSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Calcular1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTabla: TFormTabla;

implementation

{$R *.dfm}

procedure TFormTabla.sgSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
        // Seleccionar el componente:


end;

procedure TFormTabla.Calcular1Click(Sender: TObject);
var
        p,i,l       : Integer;
begin
        //
        p:=1;

        for i:=1 to sg.RowCount-1 do
        begin
                sg.cells[1,i]:=inttostr(p);
                l:=strtoint( sg.Cells[2,i] );
                p:=p+l;
        end;

end;

end.
