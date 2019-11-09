{************************************************************


************************************************************}
unit unDBTxt;

interface

uses Windows, Messages, SysUtils, Variants, Classes;

type
  TBDTxt = class
  private
    { Private declarations }
    slCampos : TStringList;
    slDatos  : Array of TStringList;    // Cada elemento es el valor de cada campo en cada registro:


  public
    { Public declarations }

    nRegistros,nCampos  : Integer;

    constructor Create( fil: AnsiString );
    destructor Destroy;

    procedure   LiberaDatos;

    procedure   BorrarRegistro(n: Integer);

    function    GetValor(nReg,nCam: Integer):AnsiString;
    function    GetValorInt(nReg,nCam, def: Integer): Integer;

    function    GetCampo(i: Integer):AnsiString;


    function    ArreglaTexto(s:AnsiString):AnsiString;

  end;


implementation

{************************************************************
                      CONSTRUCTOR
************************************************************}
constructor TBDTxt.Create( fil: AnsiString );
var
  slFil : TStringList;
  slAux : TStringList;

  st    : AnsiString;
  i,nReg,nCam,j   : Integer;
  buf   : array [0..10000] of char;
begin
        slFil:=TStringList.Create;
        slAux:=TStringList.Create;

        // Cargar tabla:
        slFil.LoadFromFile(fil);

        nReg:= slFil.Count - 1;

        slCampos:= TStringList.Create;

        // Extraer campos:
        ExtractStrings([char(9)],[' '],Strpcopy(buf,slFil.Strings[0]),slCampos);
        nCam:=slCampos.Count;

        // Poner variables:
        nRegistros:=nReg;
        nCampos:=nCam;

        // Dejar sitio para los campos:
        SetLength(slDatos,nCam);
        for i:=0 to nCam-1 do slDatos[i]:=TStringList.Create;

        // Guardar un registro:
        for i:=1 to nReg do
        begin
                st:=slFil.Strings[i];

                // Separa registro en sus campos:
                slAux.clear;
                ExtractStrings([char(9)],[],Strpcopy(buf,st),slAux);

                // Guardar en celdas:
                for j:=0 to nCam-1 do
                begin
                        st:='';

                        try
                         st:=slAux.Strings[j];
                        except on Exception do begin end;
                        end;

                        slDatos[j].Add( ArreglaTexto( st ) );
                end;
        end;


        // Liberar memoria:
        slAux.Destroy;
        slFil.Destroy;
end;

{************************************************************
                        DESTRUCTOR
************************************************************}
destructor TBDTxt.Destroy;
begin
        LiberaDatos;
        slCampos.Destroy;
end;



{************************************************************
        Libera memoria de los datos:
************************************************************}
procedure   TBDTxt.LiberaDatos;
var
 i,n    : Integer;
begin
        n:= Length( slDatos );

        for i:=0 to n-1 do slDatos[i].Destroy;
        
        SetLength( slDatos,0 );
end;


{************************************************************
        Coge el nombre de los campos (1=primero)
************************************************************}
function   TBDTxt.GetCampo(i: Integer): AnsiString;
begin
        result:= slCampos.strings[i-1];
end;

{************************************************************
        Coge el valor de un registro(1=primero)
************************************************************}
function TBDTxt.GetValor(nReg,nCam: Integer):AnsiString;
begin
        result:= slDatos[nCam-1].strings[nReg-1];
end;

{************************************************************
        Coge el valor de un registro(1=primero)
         En formato de numero entero, con valor por defecto
          si es un # no valido:
************************************************************}
function TBDTxt.GetValorInt(nReg,nCam, def: Integer): Integer;
var
        s       : AnsiString;
begin
        result:= def;

        try
                s:= trim( slDatos[nCam-1].strings[nReg-1] );

                if Length(s)>0 then result:= Strtoint( s );
        except
                on exception do
                begin
                end;
        end;
end;

{************************************************************
                Borra un registro(1=primero)
************************************************************}
procedure   TBDTxt.BorrarRegistro(n: Integer);
var   i : Integer;
begin
        for i:=0 to nCampos-1 do  slDatos[i].Delete(n-1);

        nRegistros:= slDatos[0].Count;
end;


{************************************************************
        Quita espacios de sobra y dobles comillas:
************************************************************}
function    TBDTxt.ArreglaTexto(s:AnsiString):AnsiString;
var
        sig     : Boolean;
        ini,n       : Integer;
begin
        s:=trim(s);
        while ( Pos('"',s) <>0 ) do Delete(s,Pos('"',s),1);

        // Quitar puntos:
        sig:=true;
        ini:=1;

        while ( sig )  do
        begin
                sig:=false;

                n:= Pos('.', Copy(s,ini,1000) );
                if ( n>1 ) then
                begin
                        if (not ( s[n-1] in ['0'..'9'] )) then
                        begin
                                // Vale, quitar:
                                sig:=true;
                                Delete(s, n+ini-1 ,1);

                                ini:= n+ini-1;
                        end;
                end;

        end;

        result:=s;
end;


end.
