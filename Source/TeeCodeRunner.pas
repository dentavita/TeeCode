unit TeeCodeRunner;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  TeeCodeViewer, Dialogs, Menus, Forms, StdCtrls,
  ComCtrls, Controls, ExtCtrls, TeeCode;

type
  TCodeRunner = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    CodeViewer: TCodeViewer;
    CodeTree: TTreeView;
    ComboBox1: TComboBox;
    LabelClass: TLabel;
    PopupWatches: TPopupMenu;
    Rename1: TMenuItem;
    BRun: TButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    PopupTree: TPopupMenu;
    Breakpoint1: TMenuItem;
    BStop: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Watches: TListBox;
    Breakpoints: TListBox;
    Panel5: TPanel;
    Label1: TLabel;
    EditValue: TEdit;
    PopupBreakpoints: TPopupMenu;
    Enabled1: TMenuItem;
    Delete1: TMenuItem;
    BStep: TButton;
    Value1: TMenuItem;
    Button1: TButton;
    FontDialog1: TFontDialog;
    TabSheet3: TTabSheet;
    ListBox1: TListBox;
    PageControl2: TPageControl;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    RunLog: TListBox;
    Palette: TListBox;
    N1: TMenuItem;
    Delete2: TMenuItem;
    Reverse1: TMenuItem;
    procedure Rename1Click(Sender: TObject);
    procedure BRunClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CodeTreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure WatchesClick(Sender: TObject);
    procedure Breakpoint1Click(Sender: TObject);
    procedure CodeTreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure PopupTreePopup(Sender: TObject);
    procedure BStopClick(Sender: TObject);
    procedure BreakpointsClick(Sender: TObject);
    procedure EditValueChange(Sender: TObject);
    procedure PopupBreakpointsPopup(Sender: TObject);
    procedure Enabled1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure BStepClick(Sender: TObject);
    procedure PopupWatchesPopup(Sender: TObject);
    procedure Value1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure CodeTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure CodeTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Reverse1Click(Sender: TObject);
    procedure CodeViewerKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CodeViewerClick(Sender: TObject);
  private
    { Private declarations }
    Code : TBaseCode;
    NextStep,
    DoContinue : Boolean;

    function CurrentWatch:TData;
    procedure DataChange(Sender: TObject);
    procedure FillPalette;
    function FindBreakpoint(ACode:TBaseCode):Boolean;
    procedure HighLightCode(ACode:TBaseCode; AColor:TColor; FirstLineOnly:Boolean);
    function NodeOfTreeCode(ACode:TBaseCode):TTreeNode;
    procedure OnRun(Sender: TObject);
  public
    { Public declarations }
    class procedure Edit(AOwner:TComponent; ACode:TBaseCode);
  end;

  TRunner=class(TComponent)
  private
    FCode: TBaseCode;
    DoContinue : Boolean;

    procedure SetCode(const Value: TBaseCode);
  public
    procedure Continue;
    procedure Edit;
    procedure Run;
    procedure Stop;
  published
    property Code:TBaseCode read FCode write SetCode;
  end;

implementation

{$R *.dfm}

uses
  TeeCodePascal, TeeCodeCPlusPlus;

const
  Key_Run=VK_F9;
  Key_Stop=VK_F2;
  Key_Step=VK_F7;

procedure FillVariables(AItems:TStrings; AComp:TComponent);
var
  t: Integer;
begin
  if not (AComp is TExpression) then
  if AComp is TData then
     if not (AComp is TArray) then
        if not TData(AComp).Constant then
           AItems.AddObject(AComp.Name, AComp);

  for t := 0 to AComp.ComponentCount-1 do
    if AComp.Components[t] is TBaseCode then
        FillVariables(AItems,AComp.Components[t]);

  if AComp is TBaseCode then
  for t := 0 to TBaseCode(AComp).Count-1 do
      FillVariables(AItems,TBaseCode(AComp)[t]);
end;

procedure FillCodeTree(ATree:TTreeView; AComp:TComponent; ALanguage:TCodeLanguage);

  procedure AddNodes(AParent:TTreeNode; ACode:TBaseCode);
  var Node : TTreeNode;
        t  : Integer;
  begin
    Node:=ATree.Items.AddChildObject(AParent, ALanguage.CodeOf(ACode), ACode);

    for t := 0 to ACode.Count-1 do
        AddNodes(Node, ACode[t]);
  end;

var t : Integer;
begin
  if AComp is TBaseCode then
     AddNodes(nil,TBaseCode(AComp));

  for t := 0 to AComp.ComponentCount-1 do
    if AComp.Components[t] is TBaseCode then
       if not Assigned(TBaseCode(AComp.Components[t]).Parent) then
          FillCodeTree(ATree,AComp.Components[t], ALanguage);
end;

function TCodeRunner.FindBreakpoint(ACode:TBaseCode):Boolean;
begin
  result:=(ACode.Tag=0) and (Breakpoints.Items.IndexOfObject(ACode)<>-1);
end;

procedure TCodeRunner.CodeTreeCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if FindBreakpoint(TObject(Node.Data) as TBaseCode) then
     Sender.Canvas.Font.Color:=clRed
  else
     Sender.Canvas.Font.Color:=CodeTree.Font.Color;

  DefaultDraw:=True;
end;

procedure TCodeRunner.OnRun(Sender: TObject);
begin
  RunLog.Items.Add(CodeViewer.Language.CodeOf(TBaseCode(Sender)));

  if NextStep or FindBreakpoint(TBaseCode(Sender)) then
  begin
    BRun.Caption:='&Continue';
    BStop.Enabled:=True;

    HighLightCode(TBaseCode(Sender),clGreen,True);

    if NextStep then
    begin
      DoContinue:=False;
      CodeTree.Selected:=NodeOfTreeCode(TBaseCode(Sender));
    end;

    repeat
      Application.ProcessMessages;
    until DoContinue or Application.Terminated or Stopped;

    if not NextStep then
       BStop.Enabled:=False;

    CodeTree.Selected:=NodeOfTreeCode(TBaseCode(Sender));
    //CodeTreeChange(Self, NodeOfTreeCode(TBaseCode CodeTree.Selected);
  end;
end;

procedure TCodeRunner.PopupBreakpointsPopup(Sender: TObject);
begin
  Enabled1.Checked:=TBaseCode(Breakpoints.Items.Objects[Breakpoints.ItemIndex]).Tag=0;
end;

procedure TCodeRunner.PopupTreePopup(Sender: TObject);
begin
  Breakpoint1.Enabled:=(CodeTree.Selected<>nil) and
                       (TObject(CodeTree.Selected.Data) is TCode);

  if Breakpoint1.Enabled then
     Breakpoint1.Checked:=FindBreakpoint(CodeTree.Selected.Data)
  else
     Breakpoint1.Checked:=False;

  Reverse1.Visible:=(CodeTree.Selected<>nil) and
                    (TObject(CodeTree.Selected.Data) is TAssignment) and
                    (not (TAssignment(CodeTree.Selected.Data).Value is TExpression));
end;

procedure TCodeRunner.PopupWatchesPopup(Sender: TObject);
begin
  Rename1.Enabled:=Watches.ItemIndex<>-1;
  Value1.Enabled:=Rename1.Enabled;
end;

procedure TCodeRunner.Breakpoint1Click(Sender: TObject);
begin
  Breakpoint1.Checked:=not Breakpoint1.Checked;

  if Breakpoint1.Checked then
     Breakpoints.AddItem(CodeTree.Selected.Text, CodeTree.Selected.Data)
  else
     Breakpoints.Items.Delete(Breakpoints.Items.IndexOfObject(CodeTree.Selected.Data));

  CodeTree.Invalidate;
end;

function TCodeRunner.NodeOfTreeCode(ACode:TBaseCode):TTreeNode;
var t : Integer;
begin
  result:=nil;

  if Assigned(ACode) then
  for t := 0 to CodeTree.Items.Count-1 do
    if CodeTree.Items[t].Data=ACode then
    begin
      result:=CodeTree.Items[t];
      break;
    end;
end;

procedure TCodeRunner.BreakpointsClick(Sender: TObject);
begin
  CodeTree.Selected:=NodeOfTreeCode(TBaseCode(Breakpoints.Items.Objects[Breakpoints.ItemIndex]));
end;

procedure TCodeRunner.BRunClick(Sender: TObject);
begin
  if BRun.Caption='&Run' then
  begin
    BRun.Caption:='&Stop';
    RunLog.Clear;
    Runner:=OnRun;

    DoContinue:=False;
    Stopped:=False;

    CodeViewer.Language.Running:=True;
    (Code as TCode).Run;
    CodeViewer.Language.Running:=False;
    Stopped:=True;
    BRun.Caption:='&Run';
  end
  else
  if BRun.Caption='&Continue' then
  begin
    DoContinue:=True;
    BStop.Enabled:=False;
  end
  else
  begin
    Stopped:=True;
    DoContinue:=False;
    BRun.Caption:='&Run';
  end;
end;

procedure TCodeRunner.BStopClick(Sender: TObject);
begin
  Stopped:=True;
  BStop.Enabled:=False;
end;

procedure TCodeRunner.Button1Click(Sender: TObject);
begin
  FontDialog1.Font:=CodeViewer.Font;

  if FontDialog1.Execute then
  begin
    CodeViewer.Font:=FontDialog1.Font;
    {
    with CodeViewer.DefAttributes do
    begin
      Name:=FontDialog1.Font.Name;
      Size:=FontDialog1.Font.Size;
    end;
    }
  end;
end;

procedure TCodeRunner.HighLightCode(ACode:TBaseCode; AColor:TColor;
                                    FirstLineOnly:Boolean);
var P : TPosition;
    t : Integer;
    Old : TPoint;
    OldStart, OldLength : Integer;
    FirstLine, SecondLine : Integer;
begin
  FirstLine:=CodeViewer.FirstVisibleLine;

  Old:=CodeViewer.CaretPos;
  OldStart:=CodeViewer.SelStart;
  OldLength:=CodeViewer.SelLength;

  CodeViewer.Perform(WM_SETREDRAW, 0, 0);
  CodeViewer.SelectAll;
  CodeViewer.SelAttributes.Color:=clBlack;

  if Assigned(ACode) and CodeViewer.Language.FindPosition(ACode,P) then
  begin
    CodeViewer.SelStart:=P.Start;

    if FirstLineOnly then
    begin
      t:=0;
      while (P.Start+t < Length(CodeViewer.Text)) and
            (CodeViewer.Text[P.Start+t]<>#12) do
         Inc(t);

      CodeViewer.SetSelectionLength(t);
    end
    else
       CodeViewer.SetSelectionLength(P.Length);

    CodeViewer.SelAttributes.Color:=AColor;
  end;

  CodeViewer.SelStart:=OldStart;
  CodeViewer.SetSelectionLength(OldLength);
  CodeViewer.CaretPos:=Old;

  SecondLine:=CodeViewer.FirstVisibleLine;
  CodeViewer.Perform(EM_LINESCROLL,0,FirstLine-SecondLine);
  CodeViewer.Perform(WM_SETREDRAW, 1, 0);
  CodeViewer.Invalidate;
end;

function DataAsText(AData:TData):String;
begin
  if AData is TInteger then
     result:=IntToStr(TInteger(AData).Value)
  else
  if AData is TString then
     result:=TString(AData).Value
  else
  if AData is TFloat then
     result:=FloatToStr(TFloat(AData).Value)
  else
  if AData is TBoolean then
     result:=BoolToStr(TBoolean(AData).Value)
  else
     result:='';
end;

procedure TCodeRunner.CodeTreeChange(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node) then
  begin
    LabelClass.Caption:=TBaseCode(Node.Data).ClassName;

    HighLightCode(TBaseCode(Node.Data), clBlue, False);

    EditValue.Enabled:=TBaseCode(Node.Data) is TData;

    if EditValue.Enabled then
       EditValue.Text:=DataAsText(TData(Node.Data))
    else
       EditValue.Text:='';
  end
  else
  begin
    LabelClass.Caption:='';
    HighLightCode(nil,clBlack,False);
    EditValue.Enabled:=False;
    EditValue.Text:='';
  end;
end;

procedure TCodeRunner.ComboBox1Change(Sender: TObject);
begin
  case ComboBox1.ItemIndex of
    1: CodeViewer.Language:=TCPlusPlusCode.Create(Self);
    2: ;
    3: ;
  else
    CodeViewer.Language:=TPascalCode.Create(Self);
  end;
end;

procedure TCodeRunner.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=Key_Run then
     BRun.Click
  else
  if (Key=Key_Stop) and (ssCtrl in Shift) then
     BStop.Click
  else
  if Key=Key_Step then
     BStep.Click
end;

procedure TCodeRunner.FormShow(Sender: TObject);
begin
  FillPalette;

  BRun.Enabled:=Code is TCode;
  BStep.Enabled:=BRun.Enabled;

  CodeViewer.Code:=Code;

  FillVariables(Watches.Items, Code);
  Watches.Sorted:=True;

  FillCodeTree(CodeTree, Code, CodeViewer.Language);

  if CodeTree.Items.Count>0 then
     CodeTree.Items[0].Expanded:=True;

  CodeViewer.SetFocus;
end;

function TCodeRunner.CurrentWatch:TData;
begin
  result:=Watches.Items.Objects[Watches.ItemIndex] as TData;
end;

procedure TCodeRunner.Rename1Click(Sender: TObject);
var d : TData;
    s : String;
begin
  d:=CurrentWatch;

  s:=d.Name;

  if InputQuery('Rename','New name',s) then
  begin
    d.Name:=s;
    Watches.Items[Watches.ItemIndex]:=s;
  end;
end;

procedure TCodeRunner.Reverse1Click(Sender: TObject);
var a : TAssignment;
begin
  a:=TAssignment(CodeTree.Selected.Data);
  a.Reverse;
  CodeTree.Selected.Text:=CodeViewer.Language.CodeOf(a);
end;

procedure TCodeRunner.BStepClick(Sender: TObject);
begin
  NextStep:=True;

  if Stopped then
     DoContinue:=True
  else
     BRun.Click;
end;

procedure ChangeData(ACode:TBaseCode; const S:String);
begin
  if ACode is TInteger then
     TInteger(ACode).Value:=StrToIntDef(S,TInteger(ACode).Value)
  else
  if ACode is TString then
     TString(ACode).Value:=S
  else
  if ACode is TFloat then
     TFloat(ACode).Value:=StrToFloatDef(S,TFloat(ACode).Value)
  else
  if ACode is TBoolean then
     TBoolean(ACode).Value:=StrToBoolDef(S,TBoolean(ACode).Value);
end;

procedure TCodeRunner.Value1Click(Sender: TObject);
var S : String;
    Data : TData;
begin
  Data:=CurrentWatch;
  S:=DataAsText(Data);

  if InputQuery('Change Value','New Value',S) then
     ChangeData(Data,S);
end;

class procedure TCodeRunner.Edit(AOwner: TComponent; ACode: TBaseCode);
begin
  with TCodeRunner.Create(AOwner) do
  try
    Code:=ACode;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TCodeRunner.EditValueChange(Sender: TObject);
begin
  ChangeData(TBaseCode(CodeTree.Selected.Data),EditValue.Text);
end;

procedure TCodeRunner.Enabled1Click(Sender: TObject);
var b : TBaseCode;
begin
  Enabled1.Checked:=not Enabled1.Checked;
  b:=TBaseCode(Breakpoints.Items.Objects[Breakpoints.ItemIndex]);

  if Enabled1.Checked then b.Tag:=0 else b.Tag:=1;

  CodeTree.Invalidate;
end;

procedure TCodeRunner.WatchesClick(Sender: TObject);
var d : TData;
begin
  d:=CurrentWatch;

  d.OnChange:=DataChange;
  DataChange(d);
end;

procedure TCodeRunner.DataChange(Sender: TObject);
var t : Integer;
begin
  t:=Watches.Items.IndexOfObject(Sender);

  if t<>-1 then
     Watches.Items[t]:=(Sender as TData).Name+' = '+TPascalCode.ValueOf((Sender as TData));
end;

procedure TCodeRunner.Delete1Click(Sender: TObject);
begin
  TBaseCode(Breakpoints.Items.Objects[Breakpoints.ItemIndex]).Tag:=0;
  Breakpoints.Items.Delete(Breakpoints.ItemIndex);
  CodeTree.Invalidate;
end;

{ TRunner }

procedure TRunner.Continue;
begin
  DoContinue:=True;
end;

procedure TRunner.Edit;
begin
  TCodeRunner.Edit(Self,FCode);
end;

procedure TRunner.Run;
begin
  if FCode is TCode then
  begin
    Stopped:=False;
    try
      TCode(FCode).Run;
    finally
      Stopped:=True;
    end;
  end;
end;

procedure TRunner.SetCode(const Value: TBaseCode);
begin
  if FCode<>Value then
  begin
    FCode:=Value;
  end;
end;

procedure TRunner.Stop;
begin
  Stopped:=True;
end;

procedure TCodeRunner.FillPalette;
var t : Integer;
    s : String;
begin
  Palette.Items.Clear;

  Palette.Sorted:=False;
  Palette.Items.BeginUpdate;

  for t:=0 to TeeCodes.Count-1 do
  begin
    s:=TComponentClass(TeeCodes[t]).ClassName;
    s:=Copy(s,2,Length(s));
    Palette.Items.AddObject(s, TeeCodes[t]);
  end;

  Palette.Items.EndUpdate;

  Palette.Sorted:=True;
end;

procedure TCodeRunner.CodeTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=(Source=CodeTree) or ((Source=Palette) and (Palette.ItemIndex<>-1));
end;

procedure TCodeRunner.CodeViewerClick(Sender: TObject);
var tmpNode : TTreeNode;
begin
  tmpNode:=NodeOfTreeCode(CodeViewer.Language.FindCode(CodeViewer.SelStart));

  if Assigned(tmpNode) then
     CodeTree.Selected:=tmpNode;
end;

procedure TCodeRunner.CodeViewerKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CodeViewerClick(Self);
end;

procedure TCodeRunner.CodeTreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var c : TComponentClass;
    b : TBaseCode;
    n : TTreeNode;
begin
  if Source=Palette then
  begin
    c:=TComponentClass(Palette.Items.Objects[Palette.ItemIndex]);

    b:=TBaseCode(c.Create(Code.Owner));
    b.Name:=UniqueName(b.Owner,b);
    n:=CodeTree.GetNodeAt(X,Y);

    if Assigned(n) then
       b.Parent:=TObject(n.Data) as TBaseCode
    else
       CodeViewer.Changed;

    n:=CodeTree.Items.AddChildObject(n, CodeViewer.Language.CodeOf(b), b);

    CodeTree.Selected:=n;
  end
  else
  if Source=CodeTree then
  begin
    n:=CodeTree.GetNodeAt(X,Y);

    CodeTree.Selected.MoveTo(n,naAddChild);

    b:=TObject(CodeTree.Selected.Data) as TBaseCode;

    if Assigned(n) then
       b.Parent:=TObject(n.Data) as TBaseCode
    else
       b.Parent:=nil;
  end;
end;

end.
