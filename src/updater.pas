unit updater;

interface

uses
  // Windows/System
  Windows, Messages, SysUtils, Variants, Classes, Zip, UITypes,
  // VCL
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage,
  Vcl.StdCtrls,
  // Cindy
  cySkinButton,
  // Custom
  globals;

type
  TUpdateForm = class(TForm)
    btnClose: TcySkinButton;
    btnUpdate: TButton;
    btnIgnore: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblCurrentVersion: TLabel;
    lblNewVersion: TLabel;
    Label4: TLabel;
    lblStatus: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
  private
    fZipFileName: string;
    fNewVersion:  string;
    function downloadArchive: Boolean;
  public
    constructor Create(aOwner: TComponent; aCurrentVersion,
                       aNewVersion: string); reintroduce;
  end;

var
  UpdateForm: TUpdateForm;

implementation

{$R *.dfm}

constructor TUpdateForm.Create(aOwner: TComponent; aCurrentVersion,
                               aNewVersion: string);
begin
  inherited Create(aOwner);

  fNewVersion := aNewVersion;

  lblCurrentVersion.Caption := aCurrentVersion;
  lblNewVersion.Caption     := fNewVersion;
end;

function TUpdateForm.downloadArchive: Boolean;
begin
  fZipFileName := ExtractFilePath(Application.ExeName) + KP_ARCHIVE_PREFIX +
                                  fNewVersion + '.zip';

  if not DownloadToFile(KP_ARCHIVE_FILE + fNewVersion + '.zip', fZipFileName) then
  begin
    MessageDlg('Unable to download the update, please try again later!',
               mtError, [mbOk], 0);

    Result := False;

    Exit;
  end;

  Result := True;
end;

procedure TUpdateForm.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrClose;
  Close;
end;

procedure TUpdateForm.btnUpdateClick(Sender: TObject);
var
  currentSelf, newSelf: string;
begin
  lblStatus.Caption := 'Downloading update';
  btnClose.Enabled  := False;
  btnUpdate.Enabled := False;
  btnIgnore.Enabled := False;

  if not downloadArchive then
  begin
    ModalResult := mrAbort;
    Close;
  end else
  begin
    currentSelf := Application.ExeName;
    newSelf     := ChangeFileExt(currentSelf, '.bak');

    if FileExists(newSelf) then
      DeleteFile(newSelf);

    RenameFile(currentSelf, newSelf);

    try
      lblStatus.Caption := 'Applying update';
      TZipFile.ExtractZipFile(fZipFileName, ExtractFilePath(Application.ExeName));
    finally
      DeleteFile(fZipFileName);
    end;
  end;

  ModalResult := mrOk;
  Close;
end;

end.
