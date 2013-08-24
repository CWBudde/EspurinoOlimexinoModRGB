unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, CPort, CPortEsc, GR32, GR32_Image;

type
  TFormTerminal = class(TForm)
    ComPort: TComPort;
    Update: TTimer;
    PaintBox32: TPaintBox32;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure UpdateTimer(Sender: TObject);
    procedure PaintBox32PaintBuffer(Sender: TObject);
    procedure PaintBox32MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox32MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    FColor: TColor32;
    procedure SetColor(const Value: TColor32);
  public
    property Color: TColor32 read FColor write SetColor;
  end;

var
  FormTerminal: TFormTerminal;

implementation

{$R *.dfm}

uses
  Inifiles, ActiveX, ComObj, Variants;

function LocateComPort: string;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  oEnum: IEnumvariant;
  str: string;
  iValue: LongWord;
  ParenPos: array [0 .. 1] of Integer;
begin;
  Result := '';
  try
    CoInitialize(nil);
    try
      FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
      FWMIService := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2',
        WbemUser, WbemPassword);
      FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM Win32_SerialPort',
        'WQL', wbemFlagForwardOnly);
      oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, FWbemObject, iValue) = 0 do
      begin
        str := string(FWbemObject.Name);
        if Pos('STMicroelectronics Virtual COM Port', str) > 0 then
        begin
          // 'STMicroelectronics Virtual COM Port (COM??)'
          ParenPos[0] := Pos('(COM', str);
          if ParenPos[0] > 0 then
          begin
            ParenPos[1] := Pos(')', str);
            Exit(Copy(str, ParenPos[0] + 1, ParenPos[1] - ParenPos[0] - 1));
          end;
        end;
        FWbemObject := Unassigned;
      end;
    finally
      CoUninitialize;
    end;
  except
  end;
end;

procedure TFormTerminal.FormShow(Sender: TObject);
var
  Str: string;
  DetectionForm: TForm;
begin

  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do
  try
    Str := ReadString('Main', 'COM Port', '');
    FColor := TColor32(ReadInteger('Main', 'Color', Integer(clRed32)));
  finally
    Free;
  end;

  if Str = '' then
  begin
    DetectionForm := TForm.Create(nil);
    with DetectionForm do
    try
      BorderStyle := bsDialog;
      BorderIcons := [];
      Position := poMainFormCenter;
      with TLabel.Create(DetectionForm) do
      begin
        Parent := DetectionForm;
        Left := 8;
        Height := 8;
        Caption := 'Detecting COM Port...';
      end;
      Height := 40;
      Width := 150;
      Show;

      Application.ProcessMessages;
      Str := LocateComPort;
    finally
      FreeAndNil(DetectionForm);
    end;
  end;

  if Length(Str) > 0 then
    ComPort.Port := Str;

  try
    ComPort.Open;
    ComPort.WriteStr('echo(false);' + #13#10);
    ComPort.WriteStr('reset();' + #13#10);
    ComPort.WriteStr('I2C2.setup();' + #13#10);
    ComPort.WriteStr('I2C2.writeTo(0x48, [0x05, 0xA0, 0x01]);' + #13#10);
    Update.Enabled := True;
  except
    MessageDlg(Format('Error opening %s', [ComPort.Port]), mtWarning,
      [mbOK], 0);
    DeleteFile(ChangeFileExt(Application.ExeName, '.ini'));
  end;
end;

procedure TFormTerminal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ComPort.Close;
  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do
  try
    WriteString('Main', 'COM Port', ComPort.Port);
    WriteInteger('Main', 'Color', FColor);
  finally
    Free;
  end;
end;

procedure TFormTerminal.PaintBox32MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Color := PaintBox32.Buffer.PixelS[X, Y];
end;

procedure TFormTerminal.PaintBox32MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if (ssLeft in Shift) and PtInRect(PaintBox32.ClientRect, GR32.Point(X, Y)) then
    Color := PaintBox32.Buffer.PixelS[X, Y];
end;

procedure TFormTerminal.PaintBox32PaintBuffer(Sender: TObject);
var
  o, x, y: Integer;
  wr, hr: Single;
begin
  o := Round(0.2 * PaintBox32.Width);
  wr := 1 / (PaintBox32.Width - 2 * o);
  hr := 1 / PaintBox32.Height;

  for y := 0 to PaintBox32.Height - 1 do
  begin
    for x := 0 to o - 1 do
      PaintBox32.Buffer.Pixel[x, y] := HSLtoRGB(0, x / o, 1 - y * hr);
    for x := 0 to PaintBox32.Width - 2 * o - 1 do
      PaintBox32.Buffer.Pixel[o + x, y] := HSLtoRGB(x * wr, 1, 1 - y * hr);
    for x := 0 to o - 1 do
      PaintBox32.Buffer.Pixel[PaintBox32.Width - 1 - x, y] := HSLtoRGB(x / o, x / o, 1 - y * hr);
  end;
end;

procedure TFormTerminal.SetColor(const Value: TColor32);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Update.Enabled := True;
  end;
end;

procedure TFormTerminal.UpdateTimer(Sender: TObject);
var
  R, G, B: Byte;
begin
  Color32ToRGB(FColor, R, G, B);
  if ComPort.Connected then
    ComPort.WriteStr('I2C2.writeTo(0x48, [0x05, 0xA0, 0x03, ' +
      IntToStr(G) + ', ' + IntToStr(R) + ', ' + IntToStr(B) + ']);' + #13#10);
  Update.Enabled := False;
end;

procedure TFormTerminal.ComPortRxChar(Sender: TObject; Count: Integer);
var
  Str: String;
begin
  ComPort.ReadStr(Str, Count);
  OutputDebugString(PWideChar(Str));
end;

end.
