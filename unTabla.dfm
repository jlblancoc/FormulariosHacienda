object FormTabla: TFormTabla
  Left = 212
  Top = 238
  Width = 482
  Height = 268
  BorderStyle = bsSizeToolWin
  Caption = 'Definicion de formulario'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object sg: TStringGrid
    Left = 0
    Top = 0
    Width = 474
    Height = 241
    Align = alClient
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goAlwaysShowEditor, goThumbTracking]
    PopupMenu = PopupMenu1
    TabOrder = 0
    OnSelectCell = sgSelectCell
  end
  object PopupMenu1: TPopupMenu
    Left = 352
    Top = 112
    object Calcular1: TMenuItem
      Caption = 'Autocalcular posicion...'
      OnClick = Calcular1Click
    end
  end
end
