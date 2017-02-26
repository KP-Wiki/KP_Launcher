unit globals;

interface

uses
  Windows, WinInet, UITypes,
  Vcl.Forms, Vcl.Dialogs;

const
  { PROD }
  KP_SERVER_ADDRESS    = 'http://www.knightsprovince.com';
  { DEV }
  //KP_SERVER_ADDRESS    = 'https://kp-wiki.org';

  KP_FILES_DIR         = '/clients/';
  KP_VERSION_FILE_NAME = 'version.txt';
  KP_ARCHIVE_PREFIX    = 'KnightsProvince-';
  KP_VERSION_FILE_PATH = KP_SERVER_ADDRESS + KP_FILES_DIR + KP_VERSION_FILE_NAME;
  KP_ARCHIVE_FILE      = KP_SERVER_ADDRESS + KP_FILES_DIR + KP_ARCHIVE_PREFIX;

function DownloadToFile(aUrl, TargetFileName: string): Boolean;
function DownloadToString(aUrl: string): string;

var
  fSessionHandle: HINTERNET;
  fServiceHandle: HINTERNET;

implementation

procedure OpenDownloadHandles(aUrl: string);
const
  AgentString = 'KnightsProvinceLauncher/1.0 (Win32; x86)';
begin
  fSessionHandle := InternetOpen(AgentString, INTERNET_OPEN_TYPE_PRECONFIG,
                                 nil, nil, 0);

   if fSessionHandle = nil then
   begin
      MessageDlg('Internet session initialization failed!', mtError, [mbOk], 0);
      Exit;
   end;

   fServiceHandle := InternetOpenUrl(fSessionHandle, PChar(aUrl), nil, 0,
                                     INTERNET_FLAG_DONT_CACHE or
                                     INTERNET_FLAG_PRAGMA_NOCACHE or
                                     INTERNET_FLAG_RELOAD, 0);
end;

function DownloadToFile(aUrl, TargetFileName: string): Boolean;
const
  BufferSize     = 4096;
  InfoBufferSize = 512;
var
  lpBuffer:              array[0..BufferSize + 1] of Byte;
  InfoBuffer:            array [0..InfoBufferSize] of Char;
  BufferLength, notUsed: DWORD;
  ResultFile:            File;
  CannotRead:            Boolean;
  UrlExists:             LongBool;
begin
  OpenDownloadHandles(aUrl);

  if fServiceHandle = nil then
  begin
    Result := False;
    MessageDlg('Internet session initialization failed!', mtError, [mbOk], 0);
    InternetCloseHandle(fSessionHandle);
    Exit;
  end else
  begin
    BufferLength := Length(InfoBuffer);
    notUsed      := 0;
    UrlExists    := HttpQueryInfo(fServiceHandle, HTTP_QUERY_STATUS_CODE,
                                  @InfoBuffer[0], BufferLength, notUsed);

    if (not UrlExists) or (InfoBuffer <> '200') then
    begin
      Result := False;
      MessageDlg('Url does not exists!', mtError, [mbOk], 0);
      InternetCloseHandle(fSessionHandle);
      InternetCloseHandle(fServiceHandle);
      Exit;
    end;
  end;

  CannotRead := False;

  try
    AssignFile(ResultFile, TargetFileName);
    {$i-}
    Rewrite(ResultFile, 1);
    {$i+}

    if IOResult <> 0 then
    begin
      MessageDlg('Cannot create local file!', mtError, [mbOk], 0);
      CannotRead := True;
    end else
    begin
      BufferLength := BufferSize;

      while (BufferLength > 0) do
      begin
        if not InternetReadFile(fServiceHandle, @lpBuffer, BufferSize,
                                BufferLength) then
        begin
          CannotRead := True;
          MessageDlg('Cannot read remote file!', mtError, [mbOk], 0);
          Break;
        end;

        if (BufferLength > 0) and (BufferLength <= BufferSize) then
          BlockWrite(ResultFile, lpBuffer, BufferLength);

        Application.ProcessMessages;
      end;
    end;
  finally
    InternetCloseHandle(fSessionHandle);
    InternetCloseHandle(fServiceHandle);
    CloseFile(ResultFile);
    Result := not CannotRead;
  end;
end;

function DownloadToString(aUrl: string): string;
const
  BufferSize     = 4096;
  InfoBufferSize = 512;
  AgentString    = 'KnightsProvinceLauncher';
var
  lpBuffer:              array[0..BufferSize + 1] of Byte;
  InfoBuffer:            array [0..InfoBufferSize] of Char;
  BufferLength, notUsed: DWORD;
  ResultString:          string;
  UrlExists:             LongBool;
begin
  OpenDownloadHandles(aUrl);

  if fServiceHandle = nil then
  begin
    Result := '';
    MessageDlg('Internet session initialization failed!', mtError, [mbOk], 0);
    InternetCloseHandle(fSessionHandle);
    Exit;
  end else
  begin
    BufferLength := Length(InfoBuffer);
    notUsed      := 0;
    UrlExists    := HttpQueryInfo(fServiceHandle, HTTP_QUERY_STATUS_CODE,
                                  @InfoBuffer[0], BufferLength, notUsed);

    if (not UrlExists) or (InfoBuffer <> '200') then
    begin
      Result := '';
      MessageDlg('Url does not exists!', mtError, [mbOk], 0);
      InternetCloseHandle(fSessionHandle);
      InternetCloseHandle(fServiceHandle);
      Exit;
    end;
  end;

  try
    BufferLength := BufferSize;

    while (BufferLength > 0) do
    begin
      if not InternetReadFile(fServiceHandle, @lpBuffer, BufferSize,
                              BufferLength) then
      begin
        ResultString := '';
        MessageDlg('Cannot read remote file!', mtError, [mbOk], 0);
        Break;
      end;

      if (BufferLength > 0) and (BufferLength <= BufferSize) then
        SetString(ResultString, PAnsiChar(@lpBuffer[0]), BufferLength);

      Application.ProcessMessages;
    end;
  finally
    InternetCloseHandle(fSessionHandle);
    InternetCloseHandle(fServiceHandle);
    Result := ResultString;
  end;
end;

end.
