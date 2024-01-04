unit OptionsManager;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

const
  INIFILE = 'options.ini';

type

  { TURLOption }

  TURLOption = class(TObject)
  private
    Fenabled: Boolean;
    FUrl: string;
  public
    property url: string read FUrl write FUrl;
    property enabled: Boolean read Fenabled write Fenabled;
  end;

  { TOptionsManager }

  TOptionsManager = class(TObject)
  private
    FAlertOnFail: Boolean;
    FCheckMethod: String;
    FIconTheme: Integer;
    FInterval: Integer;
    FUrls: TList;

    procedure ClearUrls;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadOptions;
    procedure SaveOptions;

    property AlertOnFail: Boolean read FAlertOnFail write FAlertOnFail;
    property URLs: TList read FUrls;
    property Interval: Integer read FInterval write FInterval;
    property IconTheme: Integer read FIconTheme write FIconTheme;
    property CheckMethod: String read FCheckMethod write FCheckMethod;
  end;

implementation

uses
  IniFiles;

{ TOptionsManager }

procedure TOptionsManager.ClearUrls;
var i: Integer;
    tempObj: TObject;
begin
  for i := 0 to FUrls.Count - 1 do
  begin
    tempObj := TObject(FUrls[i]);
    FreeAndNil(tempObj);
  end;
  FUrls.Clear;
end;

constructor TOptionsManager.Create;
begin
  inherited Create;

  FUrls := TList.Create;
end;

destructor TOptionsManager.Destroy;
begin
  ClearUrls();
  FreeAndNil(FUrls);

  inherited Destroy;
end;

procedure TOptionsManager.LoadOptions;
var ini: TIniFile;
    tempUrls: TStringList;
    i: Integer;
    option: TURLOption;
begin
  ini := nil;
  tempUrls := nil;
  try
    tempUrls := TStringList.Create;

    ini := TIniFile.Create(GetAppConfigDir(false) + INIFILE);

    FAlertOnFail := ini.ReadBool('Config', 'AlertOnFail', false);
    FInterval    := ini.ReadInteger('Config', 'Interval', 30);
    FIconTheme   := ini.ReadInteger('Config', 'IconTheme', 0);
    FCheckMethod := ini.ReadString('Config', 'CheckMethod', 'HEAD');

    ClearUrls();
    ini.ReadSectionValues('URLS', tempUrls);
    for i := 0 to tempUrls.Count - 1 do
    begin
      option := TURLOption.Create;
      option.url := tempUrls.Names[i];
      option.enabled := tempUrls.ValueFromIndex[i] = '1';

      FUrls.Add(option);
    end;
  finally
    FreeAndNil(ini);
    FreeAndNil(tempUrls);
  end;
end;

procedure TOptionsManager.SaveOptions;
var ini: TIniFile;
    i: Integer;
    option: TURLOption;
begin
  ini := nil;
  try
    ini := TIniFile.Create(GetAppConfigDir(false) + INIFILE);
    ini.WriteInteger('Config', 'Interval', FInterval);
    ini.WriteInteger('Config', 'IconTheme', FIconTheme);
    ini.WriteBool('Config', 'AlertOnFail', FAlertOnFail);
    ini.WriteString('Config', 'CheckMethod', FCheckMethod);

    ini.EraseSection('URLS');
    for i := 0 to FUrls.Count - 1 do
    begin
      option := TURLOption(FUrls[i]);
      if (option.enabled) then
        ini.WriteInteger('URLS', option.url, 1)
      else
        ini.WriteInteger('URLS', option.url, 0);
    end;
  finally
    FreeAndNil(ini);
  end;
end;

end.

