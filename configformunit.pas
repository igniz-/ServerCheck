unit ConfigFormUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx,
  OptionsManager;

type

  { TConfigForm }

  TConfigForm = class(TForm)
    Button1: TButton;
    alertOnFail: TCheckBox;
    iconTheme: TComboBox;
    checkMethod: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    minsInterval: TSpinEditEx;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    optionsManager: TOptionsManager;
  public

  end;

var
  ConfigForm: TConfigForm;

implementation

{$R *.lfm}

{ TConfigForm }

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  optionsManager := TOptionsManager.Create;
  optionsManager.LoadOptions();
end;

procedure TConfigForm.Button1Click(Sender: TObject);
begin
  optionsManager.Interval    := minsInterval.Value;
  optionsManager.AlertOnFail := alertOnFail.Checked;
  optionsManager.IconTheme   := iconTheme.ItemIndex;
  optionsManager.CheckMethod := checkMethod.Items[checkMethod.ItemIndex];

  optionsManager.SaveOptions();
  Close;
end;

procedure TConfigForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(optionsManager);
end;

procedure TConfigForm.FormShow(Sender: TObject);
begin
  minsInterval.Value  := optionsManager.Interval;
  alertOnFail.Checked := optionsManager.AlertOnFail;
  iconTheme.ItemIndex := optionsManager.IconTheme;
  checkMethod.ItemIndex := checkMethod.Items.IndexOf( optionsManager.CheckMethod );
end;

end.

