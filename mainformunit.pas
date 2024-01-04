unit MainFormUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Menus, OptionsManager;

type

  { TMainForm }

  TMainForm = class(TForm)
    ImageList1: TImageList;
    ServerStatus: TImageList;
    ListView1: TListView;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Separator2: TMenuItem;
    Separator1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    TrayIcon1: TTrayIcon;

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    function IsDarkTheme: boolean;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    remainingTime: Integer;
    starting: Boolean;
    procedure RefreshList;
    procedure CheckUrls;
  public
    options: TOptionsManager;
  end;

const
  ICON_CHECKING = 0;
  ICON_PASS = 1;
  ICON_FAIL = 2;

var
  MainForm: TMainForm;

implementation

uses
  ConfigFormUnit,
  fphttpclient,
  opensslsockets;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  MainForm.Show;
end;

procedure TMainForm.RefreshList;
var i: Integer;
    item: TListItem;
    option: TURLOption;
begin
  ListView1.BeginUpdate;

  ListView1.Clear;
  for i := 0 to options.URLs.Count - 1 do
  begin
    option := TURLOption(options.URLs[i]);

    item := ListView1.Items.Add;
    if (option.enabled) then
      item.Caption := 'Yes'
    else
      item.Caption := 'No';

    item.Checked := option.enabled;
    item.SubItems.Add(option.url);
    item.SubItems.Add('Pending');
  end;

  ListView1.EndUpdate;
end;

procedure TMainForm.CheckUrls;
var
  http: TFPHTTPClient;
  SS : TRawByteStringStream;
  i : Integer;
  iconOffset: Integer;
  allPass: Boolean;
  hintText: String;
  fails: String;
begin
  //check urls respond
  http := nil;
  SS := nil;
  allPass := true;
  try
    //set tray icon to yellow
    iconOffset := 0;
    if ((options.IconTheme = 0) and IsDarkTheme) or
        (options.IconTheme = 1) then
    begin
      iconOffset := 3;
    end;

    ServerStatus.GetIcon( ICON_CHECKING + iconOffset, TrayIcon1.Icon );

    SS:=TRawByteStringStream.Create;

    http := TFPHTTPClient.Create(nil);
    http.AllowRedirect := True;
    hintText := 'Last check status - ' + DateTimeToStr(Date+Time) + #13#10;
    fails := '';
    for i := 0 to ListView1.Items.Count - 1 do
    begin
      ListView1.Items[i].SubItems[1] := 'Updating...';
      Application.ProcessMessages;
      if (ListView1.Items[i].Checked) then
      begin
        try
          http.HTTPMethod(options.CheckMethod, ListView1.Items[i].SubItems[0], SS, [200,301,302]);
          ListView1.Items[i].SubItems[1] := http.ResponseStatusText;
        except
          ListView1.Items[i].SubItems[1] := 'Error';
          allPass := False;
          hintText := hintText + '❌ ' + ListView1.Items[i].SubItems[0] + #13#10; //(U+274C)
          fails := fails + ListView1.Items[i].SubItems[0] + #13#10;
        end;
      end;
    end;

    TrayIcon1.Hint := hintText;

    if (allPass) then
    begin
      ServerStatus.GetIcon( ICON_PASS + iconOffset, TrayIcon1.Icon );
    end
    else
    begin
      ServerStatus.GetIcon( ICON_FAIL + iconOffset, TrayIcon1.Icon );
      if (options.AlertOnFail) then
      begin
        TrayIcon1.BalloonHint := 'The following urls failed: ' + #13#10 + fails;
        TrayIcon1.ShowBalloonHint();
      end;
    end;
  finally
    FreeAndNil(http);
    FreeAndNil(SS);
  end;
end;

procedure TMainForm.ToolButton2Click(Sender: TObject);
var url: String;
    option: TURLOption;
    item: TListItem;
begin
  url := '';
  if InputQuery('Add URL', 'Enter a URL', false, url) then
  begin
    option := TURLOption.Create;
    option.url := url;
    option.enabled := True;
    options.URLs.Add(option);

    //Add new item
    item := ListView1.Items.Add;
    item.Checked := True;
    item.Caption := 'Yes';
    item.SubItems.Add( url );
    item.SubItems.Add( 'Pending' );

    options.SaveOptions();
  end;
end;

procedure TMainForm.ToolButton3Click(Sender: TObject);
var
  urlItem: TObject;
begin
  if (ListView1.Selected <> nil) then
  begin
    //release the object
    urlItem := TObject(options.URLs[ListView1.ItemIndex]);
    FreeAndNil(urlItem);
    //delete from the list
    options.URLs.Delete( ListView1.ItemIndex );
    //delete from the listView
    ListView1.Items.Delete( ListView1.ItemIndex );
  end;
  options.SaveOptions();
end;

procedure TMainForm.ToolButton5Click(Sender: TObject);
begin
  ConfigForm.ShowModal;
  options.LoadOptions();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  starting := True;

  options := TOptionsManager.Create;
  options.LoadOptions();

  remainingTime := options.Interval;
  RefreshList();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(options);
end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
begin
  MainForm.Show();
end;

procedure TMainForm.MenuItem2Click(Sender: TObject);
begin
  CheckUrls;
end;

procedure TMainForm.MenuItem3Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  //this method should be called every 1 minute
  Dec(remainingTime);
  if (remainingTime = 0) then
  begin
    remainingTime := options.Interval;
    CheckUrls();
  end;
end;

procedure TMainForm.ToolButton1Click(Sender: TObject);
begin
  CheckUrls();
end;

function TMainForm.IsDarkTheme: boolean;
const
  cMax = $A0;
var
  N: TColor;
begin
  N:= ColorToRGB(clWindow);
  Result:= (Red(N)<cMax) and (Green(N)<cMax) and (Blue(N)<cMax);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  MainForm.Hide;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if (starting) then
  begin
    starting := False;
    //if we have any urls setup then start minimized
    if (options.URLs.Count > 0) then
    begin
      MainForm.Hide();
      CheckUrls();
    end;
  end;
end;

procedure TMainForm.FormWindowStateChange(Sender: TObject);
begin
  if MainForm.WindowState = wsMinimized then
    MainForm.Hide;
end;

end.

