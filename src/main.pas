unit main;

interface

uses
  // Windows/System
  Windows, Messages, SysUtils, Variants, Classes, ShellAPI, IOUtils, UITypes,
  // VCL
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  // Cindy
  cySkinButton,
  // Cutom
  updater, globals;

type
  TLauncherForm = class(TForm)
    btnClose: TcySkinButton;
    btnLaunchKP: TButton;
    btnVisitSite: TButton;
    btnReportBug: TButton;
    imgHeader: TImage;
    procedure btnCloseClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
                            Shift: TShiftState; X, Y: Integer);
    procedure btnLaunchKPClick(Sender: TObject);
    procedure btnVisitSiteClick(Sender: TObject);
    procedure btnReportBugClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure launchUpdater(aCurrentVersion, aNewVersion: string);
    procedure openURL(aURL: string);
  public
    { Public declarations }
  end;

var
  LauncherForm: TLauncherForm;

implementation

{$R *.dfm}

procedure TLauncherForm.FormCreate(Sender: TObject);
var
  newVersion: string;
  oldVersion: string;
begin
  newVersion := DownloadToString(KP_VERSION_FILE_PATH);
  oldVersion := TFile.ReadAllText(ExtractFilePath(Application.ExeName) + KP_VERSION_FILE_NAME);

  if (newVersion <> '') and (AnsiCompareText(newVersion, oldVersion) <> 0) then
    launchUpdater(oldVersion, newVersion);
end;

procedure TLauncherForm.launchUpdater(aCurrentVersion, aNewVersion: string);
var
  UpdateForm: TUpdateForm;
begin
  UpdateForm := TUpdateForm.Create(nil, aCurrentVersion, aNewVersion);

  try
    UpdateForm.ShowModal;
  finally
    FreeAndNil(UpdateForm);
  end;
end;

procedure TLauncherForm.openURL(aURL: string);
begin
  ShellExecute(Handle, PWideChar('open'), PWideChar(aURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TLauncherForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TLauncherForm.btnLaunchKPClick(Sender: TObject);
var
  exePath: string;
begin
  exePath := ExtractFilePath(Application.ExeName) + 'KnightsProvince.exe';
  ShellExecute(Handle, nil, PWideChar(exePath), nil, nil, SW_SHOWNORMAL);
  Application.Terminate;
end;

procedure TLauncherForm.btnVisitSiteClick(Sender: TObject);
begin
  openURL('http://www.knightsprovince.com');
end;

procedure TLauncherForm.btnReportBugClick(Sender: TObject);
begin
  openURL('https://github.com/Kromster80/knights_province/issues');
end;

procedure TLauncherForm.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.
