program EspruinoLED;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {FormTerminal};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormTerminal, FormTerminal);
  Application.Run;
end.

