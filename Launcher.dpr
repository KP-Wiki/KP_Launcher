program Launcher;

uses
  Vcl.Forms,
  main in 'src\main.pas' {LauncherForm},
  updater in 'src\updater.pas' {UpdateForm},
  globals in 'src\globals.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TLauncherForm, LauncherForm);
  Application.CreateForm(TUpdateForm, UpdateForm);
  Application.Run;
end.
