program Formularios;

uses
  Forms,
  unVentana in 'unVentana.pas' {Form1},
  unDBTxt in 'unDBTxt.pas',
  unTabla in 'unTabla.pas' {FormTabla},
  unListaForms in 'unListaForms.pas' {FormLista};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormTabla, FormTabla);
  Application.CreateForm(TFormLista, FormLista);
  Application.Run;
end.
