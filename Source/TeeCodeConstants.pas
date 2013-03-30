unit TeeCodeConstants;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, TeeCode, TeeCodeRunner;

type
  TConstants = class(TForm)
    Constants: TArray;
    One: TInteger;
    Two: TInteger;
    MinusOne: TInteger;
    Zero: TInteger;
    Tick: TFunction;
    Integer1: TInteger;
    ParametersSin: TParameters;
    Sin: TFunction;
    SinAngle: TFloat;
    SinResult: TFloat;
    Runner1: TRunner;
    procedure TickRun(Sender: TObject);
    procedure SinRun(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Constants: TConstants;

implementation

{$R *.dfm}

procedure TConstants.SinRun(Sender: TObject);
begin
  TFloat(Sin.Result).Value:=System.Sin(SinAngle.Value);
end;

procedure TConstants.TickRun(Sender: TObject);
begin
  Integer1.Value:=GetTickCount;
end;

end.
