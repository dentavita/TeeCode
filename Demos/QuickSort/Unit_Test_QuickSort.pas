unit Unit_Test_QuickSort;

interface

// This example uses a QuickSort algorithm made with TeeCode components
// to sort items in a ListBox.

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, TeeCode, TeeCodeRunner;

type
  TForm64 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    Runner1: TRunner;
    Label1: TLabel;
    Button3: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure CompareRun(Sender: TObject);
    procedure SwapRun(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form64: TForm64;

implementation

{$R *.dfm}

uses
  QuickSort, TeeCodeConstants;

procedure TForm64.Button1Click(Sender: TObject);
begin
  if Button1.Caption='&Run' then
  begin
    Button1.Caption:='PAUSE';

    Runner1.Run;

    Button1.Caption:='&Run';
  end
  else
  begin
    TeeCode.Stopped:=True;
    Button1.Caption:='&Run';
  end;
end;

procedure TForm64.Button2Click(Sender: TObject);
begin
  Runner1.Edit;
end;

procedure TForm64.CompareRun(Sender: TObject);
var a,b,
    tmp : Integer;
begin
  a:=QuickSortCode.Integer1.Value;
  b:=QuickSortCode.Integer2.Value;

  with ListBox1 do
    if Items[a]<Items[b] then
       tmp:=-1
    else
    if Items[a]>Items[b] then
       tmp:=+1
    else
       tmp:=0;

  TInteger(QuickSortCode.Compare.Result).Value:=tmp;
end;

procedure TForm64.SwapRun(Sender: TObject);
var a,b : Integer;
    tmp : String;
begin
  a:=QuickSortCode.swapI.Value;
  b:=QuickSortCode.swapJ.Value;

  with ListBox1 do
  begin
    tmp:=Items[a];
    Items[a]:=Items[b];
    Items[b]:=tmp;
  end;

  Application.ProcessMessages;
end;

// Add some random strings to listbox.
// These will be the strings to sort alphabetically.
procedure TForm64.FormCreate(Sender: TObject);
begin
  Button3Click(Self); // Add random items
end;

procedure TForm64.FormShow(Sender: TObject);
begin
  QuickSortCode.FromIndex.Value:=0;
  QuickSortCode.ToIndex.Value:=ListBox1.Count-1;

  QuickSortCode.Compare.OnRun:=CompareRun;
  QuickSortCode.Swap.OnRun:=SwapRun;
end;

procedure TForm64.Button3Click(Sender: TObject);
var
  t: Integer;
begin
  ListBox1.Clear;
  
  for t := 0 to 9 do
    ListBox1.Items.Add(Chr(Ord('A')+Random(26)));
end;

end.
