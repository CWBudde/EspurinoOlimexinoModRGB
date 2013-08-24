object FormTerminal: TFormTerminal
  Left = 0
  Top = 0
  Caption = 'Espruino with OLIMEXINO-STM32 & MOD-RGB'
  ClientHeight = 264
  ClientWidth = 412
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox32: TPaintBox32
    Left = 0
    Top = 0
    Width = 412
    Height = 264
    Align = alClient
    TabOrder = 0
    OnMouseDown = PaintBox32MouseDown
    OnMouseMove = PaintBox32MouseMove
    OnPaintBuffer = PaintBox32PaintBuffer
  end
  object ComPort: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    DiscardNull = True
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrEnable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnRxChar = ComPortRxChar
    Left = 16
    Top = 16
  end
  object Update: TTimer
    Enabled = False
    Interval = 30
    OnTimer = UpdateTimer
    Left = 72
    Top = 16
  end
end
