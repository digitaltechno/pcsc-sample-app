unit UTag;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Reader;

type
  TFTagDisplay = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
  public
    procedure OnTagID(Sender:TObject);
  end;

var
  FTagDisplay: TFTagDisplay;

implementation

{$R *.dfm}

{ TForm1 }

procedure TFTagDisplay.OnTagID(Sender: TObject);
begin
    with TReaderObject(Sender) do
    begin
        Label2.Caption:='Tag From '+ReaderName;
        Label1.Caption:=UID;
    end;
end;

end.
