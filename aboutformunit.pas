unit AboutFormUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    LinkUrl: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure LinkUrlClick(Sender: TObject);
  private

  public

  end;

implementation

uses
  lclintf;

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.LinkUrlClick(Sender: TObject);
begin
  OpenURL(LinkUrl.Caption);
end;

procedure TAboutForm.Button1Click(Sender: TObject);
begin
  Close();
end;

end.

