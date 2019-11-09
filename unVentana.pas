unit unVentana;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,unDBTxt, Grids, ExtCtrls, Menus,math, ActnList,
  ComCtrls, ToolWin, ImgList,jpeg, FuncionParser, ShellApi;

const
        VERSION_PROGRAMA        = 'Formularios - version 2014 (Abr-2014)';

type
  TForm1 = class(TForm)
    OD: TOpenDialog;
    MainMenu1: TMainMenu;
    Formulario1: TMenuItem;
    Cargar1: TMenuItem;
    Salir1: TMenuItem;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ActionList1: TActionList;
    actAbrir: TAction;
    actGuardar: TAction;
    ToolButton2: TToolButton;
    N1: TMenuItem;
    Guardardatos1: TMenuItem;
    sd: TSaveDialog;
    actPrint: TAction;
    ToolButton3: TToolButton;
    Imprimirformulario1: TMenuItem;
    N2: TMenuItem;
    Imprimirformularioguardado1: TMenuItem;
    od2: TOpenDialog;
    ToolButton4: TToolButton;
    actCargar: TAction;
    Elegirformulario1: TMenuItem;
    Fondo: TImage;
    SDTxt: TSaveDialog;
    FuncionParser1: TFuncionParser;
    Avanzado1: TMenuItem;
    Abrirtabla1: TMenuItem;
    Guardartabla1: TMenuItem;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    Imprimirformulario3031: TMenuItem;
    sd_pdf: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure actAbrirExecute(Sender: TObject);
    procedure edKeyPress(Sender: TObject; var Key: Char);
    procedure actGuardarExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure Imprimirformularioguardado1Click(Sender: TObject);
    procedure actCargarExecute(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure FondoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToolButton7Click(Sender: TObject);
    procedure EnterEdit(Sender: TObject);
    procedure ExitEdit(Sender: TObject);
    procedure FuncionParser1PideVariable(Sender: TObject; Variable: String;
      var Valor: Extended; var Found: Boolean);
    procedure FuncionParser1ParserError(Sender: TObject;
      ParseError: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Imprimirformulario3031Click(Sender: TObject);
  private
    { Private declarations }

    sMiDir      : AnsiString;   // Directorio programa

    // Para el formulario:
    lstLabels   : Array of TLabel;
    lstEdits    : Array of TWinControl;



    procedure   BorrarArrays;
    procedure   CargaModelo( sFil : ansiString );
    procedure   ImprimirDesdeFicheroGuardado(fichero : AnsiString);


    procedure   RecalcularTodo;

    // Generador de campos:
    function    CogeCampo(nCamp : Integer): AnsiString;

  public
    { Public declarations }
    dbForm : TBDTxt;

    procedure AjustarDecimalesEnTEdit( edit : TWinControl );

  end;

var
  Form1: TForm1;

implementation

uses unTabla, unListaForms;


{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
        sMiDir:= ExtractFilePath( Application.ExeName );
        OD.InitialDir:=sMiDir+'modelos';
        SD.InitialDir:=sMiDir+'docs';
        od2.InitialDir:=sMiDir+'docs';

        application.HintPause:=0;
        application.HintShortPause:=0;


        form1.caption:=VERSION_PROGRAMA;

        DecimalSeparator:=',';
end;


procedure   TForm1.BorrarArrays;
var
 i,n    : Integer;
begin
        // Labels:
        n:= Length( lstLabels );

        for i:=0 to n-1 do lstLabels[i].Destroy;
        SetLength( lstLabels,0 );

        n:= Length( lstEdits );
        // Edits:
        for i:=0 to n-1 do lstEdits[i].Destroy;
        SetLength( lstEdits,0 );

end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
        BorrarArrays;
end;

procedure TForm1.Salir1Click(Sender: TObject);
begin
        Application.Terminate;
end;

procedure TForm1.actAbrirExecute(Sender: TObject);
var
        fil     : AnsiString;
        mode    :  AnsiString;
begin
//        OD.FileName:='*.txt';
//        if not OD.Execute then exit;


        if FormLista.showModal <> mrOk then exit;

        if nil=FormLista.Lista.ItemFocused then exit;


        mode:=FormLista.Lista.ItemFocused.Caption;
        fil:= sMiDir+'modelos\'+ mode +'.txt';

        try

         CargaModelo( fil );

        except on exception do
                begin
                end;
        end;


        // Para ajustar los "0,00"
        RecalcularTodo;

end;


procedure TForm1.AjustarDecimalesEnTEdit( edit : TWinControl );
var
        s,validacion                  : AnsiString;
        pos_coma                : Integer;
begin
        validacion:=dbForm.GetValor( edit.tag, 6);

                // Si es numerico y validacion="euros" dejar 2 decimales o ponerlos si no hay:
                if (validacion='euros') then
                begin
                        s := trim(TEdit(edit).text);
                        pos_coma:= Pos(',', s);

                        // Si no hay parte entera o nada, poner '0,00':
                        if (pos_coma=1)or(s='') then
                                s:='0'+s;

                        if (pos_coma=0) then
                        begin
                                s:=s+',00';
                                pos_coma:= Pos(',', s);
                        end;

                        // Si hay mas de 2 decimales, truncar:
                        while (length(s)-pos_coma>2 ) do
                                delete( s, length(s),1 );

                        // Si hay menos de 2 decimales, añadir ceros:
                        while (length(s)-pos_coma<2 ) do
                                s:=s+'0';


                        // Poner texto nuevo:
                        TEdit(edit).text:=s;
                end;
end;


// Procesa teclas en edits:
procedure TForm1.edKeyPress(Sender: TObject; var Key: Char);
var
        tipo   : AnsiString;
begin
        tipo:=dbForm.GetValor( TWinControl(sender).tag, 4);

        // Lleno -> Intro
        if ( Sender is TEdit)and(key in ['a'..'z']+['A'..'Z']+['0'..'9']+[',','.']) then
        begin
                if (tipo='N')or(tipo='Num') then
                begin
                        if key='.' then key:=',';
                end;

         if (  Length(TEdit(sender).text)+1 >= TEdit(sender).MaxLength ) then
                begin
                        TEdit(sender).text:=TEdit(sender).text+key;
                        key:=char(13);
                end;
        end;

        // INTRO: Siguiente:
        if (Key= char(13)) then
        try
                AjustarDecimalesEnTEdit( TEdit(Sender) );

          ActiveControl:=lstEdits[TEdit(sender).tag];
        except on Exception do begin end;
        end;

        if (tipo='Num') then
                if not (key in ['0'..'9']+[char(8),char(9)]) then Key:=char(0);


end;

procedure TForm1.actGuardarExecute(Sender: TObject);
var
        fil     : TextFile;
        i,n     : Integer;
begin   //
        SD.Tag:=0;
        if (not Sd.Execute) then exit;
        SD.Tag:=1;

        // Guardar:
        AssignFile(fil,sd.filename);

        ReWrite(fil);

        // Numero de campos:
        n:= Length( lstEdits );

        for i:=1 to n do
                Write(fil,CogeCampo(i));

        CloseFile( fil );
end;


// Formatea los campos segun las especificaciones:
function    TForm1.CogeCampo(nCamp : Integer): AnsiString;
var
        s       : AnsiString;
        tipo    : AnsiString;
        cont    : AnsiString;
        validacion : ansistring;
        longitud: Integer;
        i       : Integer;
        negativo: Boolean;
begin
        // Cargar definicion de campo:
        tipo:=dbForm.GetValor(nCamp,4);
        longitud:=StrToInt(dbForm.GetValor(nCamp,3));
        validacion:= dbForm.GetValor( nCamp, 6);

        // Ultimo campo?
        if ( Pos('CRLF',dbForm.GetValor(nCamp,5))<>0 ) then
        begin
                s:='';
                s:=s+char(13);s:=s+char(10);
                Result:=s;
                exit;
        end;

        // X/N o blanco?
        if ( lstEdits[nCamp-1] is TCheckBox ) then
        begin
                Result:=' ';
                cont:= Trim(dbForm.GetValor(nCamp,6));

                // sacar la X,N o lo que sea:
                cont:= copy( cont, 1,1);
                
                if TCheckBox(lstEdits[nCamp-1]).Checked then Result:=cont;
                exit;
        end;

        // Cargar el texto del control:
        s:= TEdit( lstEdits[nCamp-1] ).Text;

        // Si es de euros "0,00", quitar la ",":
        if validacion='euros' then
        begin
                AjustarDecimalesEnTEdit( Twincontrol( lstEdits[nCamp-1] ) );
                s:=TEdit(lstEdits[nCamp-1]).text;
                if pos(',',s)>0 then delete(s, pos(',',s),1);
        end;


        // A,An? -> Rellenar con espacios:
        if (tipo='A') or (tipo='An') then
        begin
                s:=trim(s);
                while (Length(s)<longitud) do s:=s+' ';
                Result:=s;
                exit;
         end;

        // Si el tipo es "Num" o "N", quitar la "," decimal
        if (tipo='Num')or(tipo='N') then
        begin
                s:=trim(s);
                if pos(',',s)>0 then
                        Delete(s, pos(',',s),1);
        end;

        // Num? -> Rellenar con 0 a la izq:
        if (tipo='Num') then
        begin
                s:=trim(s);
                while (Length(s)<longitud) do s:='0'+s;
                Result:=s;
                exit;
         end;

        // N? -> Rellenar con 0 a la izq o N000
        if (tipo='N') then
        begin
                s:=trim(s);

                i:=0;
                try
                 i:=StrToInt(s);
                except on Exception do begin end;
                end; 

                negativo:=i<0;

                s:=IntToStr(abs(i));
                while (Length(s)<longitud) do s:='0'+s;

                if (negativo) then s[1]:='N';

                Result:=s;
                exit;
         end;



        Result:=s;
end;


procedure TForm1.ImprimirDesdeFicheroGuardado(fichero : AnsiString);
var
        buf     : array [0..1000] of char;
        buf2    : array [0..1000] of char;
        cmd    : AnsiString;
        res     : Integer;
        generado_ok : Boolean;

        slErr   : TStringList;
begin
        res:=MessageDlg('¿Imprimir copia para declarante?',mtConfirmation,mbYesNoCancel, 0);
        if res=mrCancel then exit;
        CopyFile(StrPCopy(buf,fichero),StrpCopy(buf2,sMiDir+'mipf\fich'),false);

        sd_pdf.FileName := ChangeFileExt(fichero, '.pdf');
        if not sd_pdf.Execute() then exit;

        cmd:='/E:fich /R:errores.txt /P:"'+sd_pdf.FileName+'"';

        if res=mrYes then cmd:=cmd+' /C:S';
        if res=mrNo  then cmd:=cmd+' /C:N';

        ChDir(sMiDir+'mipf');

        res := ShellExecute(0,nil,StrPCopy(buf2,'mipfpdf.bat'),StrPCopy(buf,cmd),nil,SW_SHOWNORMAL );

        if (res<32) then
        begin
         ShowMessage('ERROR al ejecutar MIPF!! ('+IntToStr(res)+')');
         exit;
        end;

        generado_ok:=true;

        Sleep(700);

        // Mostrar errores:
        slErr:= TStringList.Create;

        try
                slErr.LoadFromFile( sMiDir+'mipf\errores.txt' );
                if (slerr.Count>0) then
                begin
                        generado_ok := false;        
                        ShowMessage( slErr.Text );
                end;
                slErr.Destroy;
        except On Exception do begin end;
        end;


        if mrOK=MessageDlg('¿Abrir el PDF recien generado?',mtConfirmation,mbOKCancel, 0) then
        begin
                res := ShellExecute(0,'open',StrPCopy(buf2,sd_pdf.FileName),nil,nil,SW_SHOWNORMAL );
                if (res<32) then
                begin
                        ShowMessage('¡Error al abrir PDF!');
                end;
        end;

end;

procedure TForm1.actPrintExecute(Sender: TObject);
begin   //
        actGuardarExecute(self);

        // SD.Tag es 0 si cancelar
        if (sd.Tag=0) then exit;

        ImprimirDesdeFicheroGuardado(sd.FileName);
end;

procedure TForm1.Imprimirformularioguardado1Click(Sender: TObject);
var
        buf     : array [0..1000] of char;
        buf2     : array [0..1000] of char;
        cmd     : AnsiString;
        res     : Integer;

        slErr   : TStringList;
        
begin   //
        if not od2.Execute then exit;

        ImprimirDesdeFicheroGuardado(od2.FileName);
end;

procedure TForm1.actCargarExecute(Sender: TObject);
var
        dat     : AnsiString;
        modelo,fMod  : AnsiString;
        campo   : AnsiString;
        validacion      : AnsiString;
        i,lon     : Integer;
        fil     : TextFile;

        negativo        : boolean;
begin
        if not od2.Execute then exit;

        // Cargar datos:
        AssignFile( fil,od2.Filename );
        Reset(fil);
        Read(fil,dat);
        CloseFile(fil);

        // Ver modelo:
        if (Copy(dat,1,2)= '<T') then
        begin
                modelo:= Copy(dat,3,3);
        end
        else
        begin
                modelo:= Copy(dat,1,3);
        end;

        // Cargar plantilla:
        fMod:=sMiDir+'modelos\'+modelo+'.txt';

        if (not FileExists(fMod)) then
        begin
                ShowMessage( 'ERROR. No se encuentra plantilla para modelo de formulario!!');
                exit;
        end;

        CargaModelo( fMod );


        // Cargar datos al formulario ------------------------------

        for i:=0 to dbForm.nRegistros-1 do
        begin
                lon:= Strtoint( dbForm.GetValor(i+1,3) );
                validacion:= dbForm.GetValor(i+1,6);

                campo:=Copy( dat,Strtoint( dbForm.GetValor(i+1,2) ),lon );

                if (lstEdits[i] is TEdit) then
                begin
                        // Formatear campo:
                        campo:=trim(campo);

                        // Es numerico??
                        if ('N' = dbForm.GetValor( i+1 ,4) ) then
                        begin
                                negativo:=false;
                                // Quitar el "N" de negativo:
                                if (copy(campo,1,1)='N') then
                                begin
                                        negativo:=true;
                                        delete(campo,1,1);
                                end;

                                // quitar ceros a la izquierda:
                                while ( copy(trim(campo),1,1)='0') do
                                        delete(campo,1,1);

                                if (negativo) then campo:='-'+campo;

                        end;


                        // Si es de euros "0,00", poner la coma:
                        if validacion='euros' then
                                insert(',',campo,length(campo)-1);

                        TEdit( lstEdits[i] ).Text:= campo;
                                                

                        TEdit( lstEdits[i] ).CharCase:= ecUpperCase;                        
                end;

                if (lstEdits[i] is TCheckBox) then
                        TCheckBox( lstEdits[i] ).Checked:= ( campo<>' ' );

        end; // Para cada campo:

        for i:=1 to 10 do
                RecalcularTodo;

end;

{************************************************

                CARGA MODELO
                
************************************************}
procedure TForm1.CargaModelo( sFil : ansiString );
var
        j,i       : Integer;
        offy,Ay       : Integer;
        cont       : AnsiString;
        anchoLetra      : Integer;

        fil_img     : AnsiString;
        tiene_fondo : Boolean;

        p       : TPoint;
begin
        try
         if dbForm<>nil then
                 dbForm.Destroy;
        except on Exception do
                begin
                end;
        end;

        VertScrollBar.Position:=0;
        HorzScrollBar.Position:=0;

        dbForm:= TBDTxt.Create( sFil );

        { Los campos son:
        1.Nº
        2.Posic.  con respecto a 0  en hex.
        3.Long.  
        4.Tipo.
        5.Descripci¢n
        6.validaci¢n
        7.contenido

        // Solo si tiene imagen de fondo:
        8.X
        9.Y
        10. FORMULA

        }

        // Tiene fondo?

        fil_img:= ChangeFileExt(sFil, '.bmp');
        tiene_fondo:= FileExists( fil_img );

        if tiene_fondo then
        begin
                fondo.Visible:=true;

                fondo.Picture.LoadFromFile( fil_img );
        end   else
         fondo.Visible:=false;


        // El ultimo registro siempre es de total ?
        if Pos('Total',dbForm.GetValor( dbForm.nRegistros,1 ) ) > 0 then
                dbform.BorrarRegistro( dbForm.nRegistros );

        // Borrar arrays actuales de controles:
        BorrarArrays;

        SetLength( lstEdits , dbform.nRegistros );

        // Crear formulario -----------------------------------------------

        // Altura de cada registro:
        Ay:= (8+Canvas.TextHeight('W'))*2;

        if not tiene_fondo then
        begin
                SetLength( lstLabels , dbform.nRegistros );
                for i:=1 to dbform.nRegistros do
                begin
                        // Crear etiqueta:
                        lstLabels[i-1]:= TLabel.Create(self);
                        lstLabels[i-1].Left:=10;
                        lstLabels[i-1].Top:=i*Ay+30;
                        lstLabels[i-1].Caption:= dbform.GetValor(i,5);
                        lstLabels[i-1].Parent:=self;

                end; // Fin de cada registro

                offy:=lstLabels[0].height+3;
        end else
        begin
                SetLength( lstLabels , 0 );
                offy:=20;
        end;

        anchoLetra:= Canvas.TextWidth('O ');

        for i:=1 to dbform.nRegistros do
        begin
                // Coger contenido de campo:
                cont:= Trim(dbForm.GetValor(i,6));

                // Crear edit o lo que sea:
                if ( Pos('X o en blanco',cont)<>0 )or(Pos('N o en blanco',cont)<>0) then
                begin
                        // Es un TCheckBox
                        lstEdits[i-1]:= TCheckBox.Create(self);
                        TCheckBox(lstEdits[i-1]).width:= 16;

                end else
                begin
                        // Es un TEdit
                        lstEdits[i-1]:= TEdit.Create(self);

                        // Logitud campo:
                        try
                                TEdit(lstEdits[i-1]).MaxLength:= StrtoInt( dbform.GetValor(i,3) );
                        except on Exception do
                                begin
                                end;
                        end;

                        TEdit(lstEdits[i-1]).width:= max(20, Round( 0.9*anchoLetra*TEdit(lstEdits[i-1]).MaxLength ) );


                        // Ver si es campo en blanco:
                        if (Pos('En blanco',dbform.GetValor(i,6)) <>0) or
                           (Pos('CRLF',dbForm.GetValor(i,5))<>0 ) then
                        begin
                            TEdit(lstEdits[i-1]).Visible:=false;
                        end;

                        cont:= Trim(dbForm.GetValor(i,7));
                        j:=Pos('Constante',dbform.GetValor(i,7));
                        if (j <>0) then
                        begin
                            TEdit(lstEdits[i-1]).text:= dbForm.ArreglaTexto( Copy(cont,j+9,100) );
                            TEdit(lstEdits[i-1]).Enabled:=false;
                        end;
//                         else TEdit(lstEdits[i-1]).Text:= dbform.GetValor(i,7) ;

                        TEdit(lstEdits[i-1]).OnKeyPress:= edKeyPress;
                end;

                lstEdits[i-1].Tag:= i;

                // Colocar en su sitio:
                if not tiene_fondo then
                begin
                        lstEdits[i-1].Left:= 40; //maxX;
                        lstEdits[i-1].Top:=i*Ay+30+ offy;
                end else
                begin
                        // Colocar en su sitio segun coordenadas:
                        p.X:= dbForm.GetValorInt(i,8,950);
                        p.Y:= dbForm.GetValorInt(i,9, 20* i);

                        lstEdits[i-1].Left:= p.x ;
                        lstEdits[i-1].Top:= p.y;

                        if lstEdits[i-1] is TEdit then
                        begin
                                TEdit(lstEdits[i-1]).Hint:= dbform.GetValor(i,5);
                                TEdit(lstEdits[i-1]).showHint:=true;

                                // Numeros alineados a la derecha:
{                                if ('N' = dbForm.GetValor( i ,4) ) then
                                        TEdit(lstEdits[i-1]).Ali}


                                TEdit(lstEdits[i-1]).OnEnter:= EnterEdit;
                                TEdit(lstEdits[i-1]).OnExit:= ExitEdit;
                        end else
                         if lstEdits[i-1] is TCheckBox then
                         begin
                                TCheckBox(lstEdits[i-1]).Hint:= dbform.GetValor(i,5);
                                TCheckBox(lstEdits[i-1]).showHint:=true;
                         end;


                end;

                lstEdits[i-1].Parent:=self;

        end; // Fin de cada registro

        // El ultimo no se ve, es CRLF:
//        lstEdits[ High(lstEdits) ].Width:=0;

        if High(lstLabels)>0 then
                lstLabels[ High(lstLabels) ].Width:=0;

end;


procedure TForm1.ToolButton5Click(Sender: TObject);
var
        i,j : Integer;
begin
        if FormTabla.visible= false then
        begin
                FormTabla.Show;

                // Cargar todo en la tabla:
                formtabla.sg.colCount:= dbForm.nCampos;
                formtabla.sg.RowCount:= dbForm.nRegistros+1;

                for i:=1 to dbForm.nCampos do
                begin
                 formtabla.sg.Cells[i-1,0]:= dbFOrm.GetCampo( i );

                 for j:=1 to dbForm.nRegistros do
                 begin
                        formtabla.sg.Cells[i-1,j]:= dbform.GetValor( j,i );
                 end;
                 
                end;



        end;

end;

procedure TForm1.FondoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 p      : TPoint;
begin
        p.X:=x;
        p.Y:=y;

        p:=fondo.ClientToParent( p );

        p.x:= p.x + HorzScrollBar.Position;
        p.y:= p.Y + VertScrollBar.Position;

        if FormTabla.Visible then
        begin
                formtabla.sg.Cells[7,formtabla.sg.Row] := inttostr(p.x);
                formtabla.sg.Cells[8,formtabla.sg.Row] := inttostr(p.y);

                lstEdits[ formtabla.sg.Row-1 ].Left:= p.x - HorzScrollBar.Position;;
                lstEdits[ formtabla.sg.Row-1 ].Top:= p.y - VertScrollBar.Position;;


        end;

end;

procedure TForm1.ToolButton7Click(Sender: TObject);
var
        f       : TextFile;
        str     : AnsiString;
        i,j     : Integer;
begin
        if (not SDTxt.Execute) then exit;

        AssignFile( f, sdTxt.FileName );
        Rewrite( f );

        // Lista de campos:
        str:='';
        for i:= 1 to dbForm.nCampos do
                str:=str+ dbForm.GetCampo( i ) + #9;

        WriteLn(f,str);

        // Valores:
        for i:= 1 to dbForm.nRegistros do
        begin
                str:='';
                for j:= 1 to dbForm.nCampos do
                        str:=str+ '"'+FormTabla.sg.Cells[ j-1 , i ]  + '"'+ #9;

                WriteLn(f,str);
        end;


        CloseFile( f );
end;

procedure TForm1.EnterEdit(Sender: TObject);
begin
        //
        Tedit(sender).Color:= clYellow;

end;

procedure TForm1.ExitEdit(Sender: TObject);
var
        i: Integer;
begin
        //
        Tedit(sender).Color:= clWhite;

        AjustarDecimalesEnTEdit( TWinControl( sender ) );

        for i:=1 to 10 do
                RecalcularTodo;

end;

procedure TForm1.RecalcularTodo;
var
        i       : Integer;
        formula : AnsiString;

        begin
        // Recalcular todos los campos que tengan formula:
        for i:=1 to dbForm.nRegistros do
        begin
                // Campo nº10= FORMULA
                formula:=dbForm.GetValor( i, 10 );

                if Length(formula)>0 then
                begin
                        try
                                // Recalcular:
                                FuncionParser1.Funcion:=formula;
                                FuncionParser1.Parse;

                                TEdit(lstEdits[ i-1 ]).Text:= Format('%0.02f',[
                                        FuncionParser1.ParseValor ] );

                        except
                                on Exception do begin end;
                        end;

                end;
                
                // Aunq no haya formula, ajustar todos los decimales
                AjustarDecimalesEnTEdit( TWinControl( lstEdits[ i-1 ] ) );
        end;

end;

procedure TForm1.FuncionParser1PideVariable(Sender: TObject;
  Variable: String; var Valor: Extended; var Found: Boolean);
var
        nCamp   : Integer;
begin
        if Copy(Variable,1,1)='C' then
        begin
                // Coger valor de campo de edit:
                nCamp:= Strtoint( copy(Variable, 2, 10) );

                Valor:=0;
                try
                        if ( Length(TEdit( lstEdits[nCamp-1] ).Text)>0 ) then
                                Valor:= StrToFloat( TEdit( lstEdits[nCamp-1] ).Text );
                except
                        on Exception do begin end;
                end;

                Found:=true;
        end;


        if Copy(Variable,1,1)='P' then
        begin
                // Coger valor de campo de edit:
                nCamp:= Strtoint( copy(Variable, 2, 10) );

                Valor:=0;
                try
                        if ( Length(TEdit( lstEdits[nCamp-1] ).Text)>0 ) then
                                Valor:= StrToFloat( TEdit( lstEdits[nCamp-1] ).Text );

                        if (Valor<0) then Valor:=0;
                except
                        on Exception do begin end;
                end;

                Found:=true;
        end;


end;

procedure TForm1.FuncionParser1ParserError(Sender: TObject;
  ParseError: Integer);
var
    Msg : string;
  begin
    case ParseError of
      1 : Msg := 'Desbordamiento de Pila.';
      2 : Msg := 'Valor Fuera de Rango.';
      3 : Msg := 'Esperaba una Expresión.';
      4 : Msg := 'Esperaba un Operador.';
      5 : Msg := 'Esperaba Parentesis que Abre "(".';
      6 : Msg := 'Esperaba Parentesis que Cierra ")".';
    end; { case }

    ShowMessage(msg);

end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
        self.VertScrollBar.Position:=self.VertScrollBar.Position+ 40;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
        self.VertScrollBar.Position:=self.VertScrollBar.Position- 40;
end;

procedure TForm1.Imprimirformulario3031Click(Sender: TObject);
var
        buf     : array [0..2000] of char;
        buf2    : array [0..2000] of char;
        url     : array [0..2000] of char;
        cmd,trgFile     : AnsiString;
        res     : Integer;
begin   //
        if not od2.Execute then exit;

        // Copiar el fichero a su destino fijo:
        trgFile:='c:\aeat\formularios_print.txt';

        if not DirectoryExists('c:\aeat\') then
        begin
                if not CreateDirectory('c:\aeat\',nil) then
                begin
                        ShowMessage('Error al crear directorio c:\aeat\');
                        exit;
                end;
        end;

        if not CopyFile(StrPCopy(buf,od2.FileName),StrpCopy(buf2,trgFile),false) then
        begin
                ShowMessage('Error al copiar fichero a: '+trgFile);
                exit;
        end;

        StrPCopy(url,'https://www5.aeat.es/es13/h/ie93030b.html?FIC=C:\aeat\formularios_print.txt');
        ShellExecute(Handle,'open',url,nil,nil,SW_SHOWNORMAL);

end;

end.
