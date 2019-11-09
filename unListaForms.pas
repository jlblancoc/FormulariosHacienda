unit unListaForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, StdCtrls, Buttons;

type
  TFormLista = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Lista: TListView;
    ImageList1: TImageList;
    procedure ListaDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormLista: TFormLista;

implementation

{$R *.dfm}

procedure TFormLista.ListaDblClick(Sender: TObject);
begin
        ModalResult:=mrOk;
end;

end.
