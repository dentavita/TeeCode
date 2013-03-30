{ TeeCode                                  }
{ by @davidberneda  davidberneda@gmail.com }
{ www.steema.com                           }
unit TeeCode;

interface

uses
  Classes, SysUtils;

type
  TBaseCode=class(TComponent)
  private
    FItems : TList;
    FParent : TBaseCode;
    FOnChange: TNotifyEvent;

    procedure Changed;
    function Get(Index: Integer): TBaseCode;
    function GetIndex: Integer;
    procedure SetIndex(const Value: Integer);
    procedure SetParent(const Value: TBaseCode);
  protected
    procedure Add(const Value:TBaseCode);
    procedure ChangeReference(var AComp:TComponent; const AValue:TComponent);
    function IsChildrenRecursive(ACode:TBaseCode):Boolean;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ReadState(Reader: TReader); override;
    procedure Remove(const Value:TBaseCode);
    procedure SetName(const NewName: TComponentName); override;
  public
    Destructor Destroy; override;

    function Count:Integer;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure SetParentComponent(Value: TComponent); override;

    property Index:Integer read GetIndex write SetIndex;
    property Items[Index:Integer]:TBaseCode read Get; default;
  published
    property Parent:TBaseCode read FParent write SetParent stored False;
    property OnChange:TNotifyEvent read FOnChange write FOnChange;
  end;

  TData=class(TBaseCode)
  private
    FConst: Boolean;
    procedure SetConstant(const Value: Boolean);
  published
    property Constant:Boolean read FConst write SetConstant default False;
  end;

  TCodeClass=class(TData)
  private
    FAncestor: TCodeClass;
    procedure SetAncestor(const Value: TCodeClass);
  published
    property Ancestor:TCodeClass read FAncestor write SetAncestor;
  end;

  TNumber=class(TData)
  end;

  TInteger=class(TNumber)
  private
    FValue : Integer;
    procedure SetValue(const AValue: Integer);
  public
    procedure Assign(Source:TPersistent); override;
  published
    property Value:Integer read FValue write SetValue;
  end;

  TFloat=class(TNumber)
  private
    FValue : Single;
    procedure SetValue(const AValue: Single);
  public
    procedure Assign(Source:TPersistent); override;
  published
    property Value:Single read FValue write SetValue;
  end;

  TString=class(TData)
  private
    FValue : String;
    procedure SetValue(const AValue: String);
  public
    procedure Assign(Source:TPersistent); override;
  published
    property Value:String read FValue write SetValue;
  end;

  TCode=class(TBaseCode)
  protected
    function ValidItem(AItem:TBaseCode):Boolean; virtual;
  public
    procedure Run; virtual;
  end;

  TArray=class(TData)
  private
    function Get(Index: Integer): TData;
    procedure Put(Index: Integer; const Value: TData);
  public
    property Items[Index:Integer]:TData read Get write Put; default;
  end;

  TParameters=class(TArray)
  private
    procedure Pop;
  end;

  TCodeParams=class(TCode)
  private
    FParams: TParameters;
    procedure SetParams(const Value: TParameters);
  public
    Constructor Create(AOwner:TComponent); override;
  published
    property Parameters:TParameters read FParams write SetParams;
  end;

  TProcedure=class(TCodeParams)
  private
    FOnRun: TNotifyEvent;
  public
    procedure Run; override;
  published
    property OnRun:TNotifyEvent read FOnRun write FOnRun;
  end;

  TCall=class(TCodeParams)
  private
    FCode: TBaseCode;
    procedure SetCode(const Value: TBaseCode);
  public
    procedure Run; override;
  published
    property Code:TBaseCode read FCode write SetCode;
  end;

  TExpression=class(TData)
  public
    function Value:TData; virtual;
  end;

  TExpressionParams=class(TExpression)
  private
    FParams: TParameters;
    procedure SetParams(const Value: TParameters);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Parameters:TParameters read FParams write SetParams;
  end;

  TFunction=class(TExpressionParams)
  private
    FResult: TData;
    FOnRun: TNotifyEvent;
    procedure SetResult(const Value: TData);
  public
    function Value:TData; override;
  published
    property Result:TData read FResult write SetResult;
    property OnRun:TNotifyEvent read FOnRun write FOnRun;
  end;

  TFunctionCall=class(TExpressionParams)
  private
    FFunction: TFunction;
    procedure SetFunction(const Value: TFunction);
  public
    function Value:TData; override;
  published
    property FunctionCode:TFunction read FFunction write SetFunction;
  end;

  TOperator=class(TExpression)
  private
    FLeft : TData;
    FRight : TData;
    procedure SetLeft(const Value: TData);
    procedure SetRight(const Value: TData);
  protected
    L, R : TData;
  public
    function Value:TData; override;
  published
    property Left:TData read FLeft write SetLeft;
    property Right:TData read FRight write SetRight;
  end;

  TAdd=class(TOperator)
  public
    function Value:TData; override;
  end;

  TSubtract=class(TOperator)
  public
    function Value:TData; override;
  end;

  TMultiply=class(TOperator)
  public
    function Value:TData; override;
  end;

  TDivide=class(TOperator)
  public
    function Value:TData; override;
  end;

  TModDivision=class(TOperator)
  public
    function Value:TData; override;
  end;

  TAssignment=class(TCode)
  private
    FVariable: TData;
    FValue: TData;
    procedure SetValue(const AValue: TData);
    procedure SetVariable(const AValue: TData);
  public
    procedure Reverse;
    procedure Run; override;
  published
    property Variable:TData read FVariable write SetVariable;
    property Value:TData read FValue write SetValue;
  end;

  TBoolean=class(TData)
  private
    FValue : Boolean;
    procedure SetValue(const AValue: Boolean);
  public
    procedure Assign(Source:TPersistent); override;
  published
    property Value:Boolean read FValue write SetValue;
  end;

  TBooleanOperator=class(TOperator)
  end;

  TLower=class(TBooleanOperator)
  public
    function Value:TData; override;
  end;

  TGreater=class(TBooleanOperator)
  public
    function Value:TData; override;
  end;

  TLowerOrEqual=class(TBooleanOperator)
  public
    function Value:TData; override;
  end;

  TGreaterOrEqual=class(TBooleanOperator)
  public
    function Value:TData; override;
  end;

  TEqual=class(TBooleanOperator)
  public
    function Value:TData; override;
  end;

  TDifferent=class(TEqual)
  public
    function Value:TData; override;
  end;

  TLogicOperator=class(TBooleanOperator)
  end;

  TAnd=class(TLogicOperator)
  public
    function Value:TData; override;
  end;

  TOr=class(TLogicOperator)
  public
    function Value:TData; override;
  end;

  TUnaryOperator=class(TExpression)
  private
    FOperand: TData;
    procedure SetOperand(const Value: TData);
  published
    property Operand:TData read FOperand write SetOperand;
  end;

  TNot=class(TUnaryOperator)
  public
    function Value:TData; override;
  end;

  TIncrement=class(TAssignment)
  public
    procedure Run; override;
  end;

  TConditionLoop=class(TCode)
  private
    FExpression : TExpression;
    procedure SetExpression(const Value: TExpression);
  published
    property Expression:TExpression read FExpression write SetExpression;
  end;

  TWhile=class(TConditionLoop)
  public
    procedure Run; override;
  end;

  TIf=class(TCode)
  private
    FElseDo: TCode;
    FExpression: TExpression;
    procedure SetElseDo(const Value: TCode);
    procedure SetExpression(const Value: TExpression);
  protected
    function ValidItem(AItem:TBaseCode):Boolean; override;
  public
    procedure Run; override;
  published
    property ElseDo:TCode read FElseDo write SetElseDo;
    property Expression:TExpression read FExpression write SetExpression;
  end;

  TFor=class(TCode)
  private
    FFrom: TNumber;
    FIterator: TNumber;
    FTo: TNumber;
    FStep: TNumber;
    procedure SetFrom(const Value: TNumber);
    procedure SetIterator(const Value: TNumber);
    procedure SetStep(const Value: TNumber);
    procedure SetTo(const Value: TNumber);
  public
    procedure Run; override;
  published
    property Iterator:TNumber read FIterator write SetIterator;
    property FromValue:TNumber read FFrom write SetFrom;
    property ToValue:TNumber read FTo write SetTo;
    property Step:TNumber read FStep write SetStep;
  end;

  TForEach=class(TCode)
  private
    FIterator: TData;
    FData: TArray;
    procedure SetData(const Value: TArray);
    procedure SetIterator(const Value: TData);
  public
    procedure Run; override;
  published
    property Data:TArray read FData write SetData;
    property Iterator:TData read FIterator write SetIterator;
  end;

  TRepeat=class(TConditionLoop)
  public
    procedure Run; override;
  end;

  TCopy=class(TExpression)
  private
    FData: TData;
    FValue: TData;
    procedure SetData(const Value: TData);
  public
    function Value:TData; override;
  published
    property Data:TData read FData write SetData;
  end;

  TProperty=class(TExpression)
  private
    FComp: TComponent;
    FPropName: String;
    procedure SetComp(const Value: TComponent);
    procedure SetPropName(const Value: String);
  public
    procedure Assign(Source:TPersistent); override;
    function Value:TData; override;
  published
    property Component:TComponent read FComp write SetComp;
    property PropertyName:String read FPropName write SetPropName;
  end;

  TComment=class(TBaseCode)
  private
    FText: String;
    procedure SetText(const Value: String);
  published
    property Text:String read FText write SetText;
  end;

  TTry=class(TCode)
  private
    FCatch: TCode;
    FFinally: TCode;
    procedure SetCatch(const Value: TCode);
    procedure SetFinally(const Value: TCode);
  public
    procedure Run; override;
  published
    property Catch:TCode read FCatch write SetCatch;
    property FinallyCode:TCode read FFinally write SetFinally;
  end;

  TRaise=class(TCode)
  private
    FMessage: String;
    procedure SetMessage(const Value: String);
  public
    procedure Run; override;
  published
    property Message:String read FMessage write SetMessage;
  end;

  CodeException=class(Exception);

  TCodeStyle=(csNormal, csReserved);

  PPosition=^TPosition;
  TPosition=record
    Start, Length : Integer;
    Code : TBaseCode;
    Style : TCodeStyle;
  end;

  TCodeLanguage=class(TComponent)
  private
    procedure Clear;
  protected
    FText : String;

    procedure AddPosition(P:PPosition);
    function NewPosition(ACode:TBaseCode):PPosition;
  public
    Formatting,
    Positions : TList;
    Running : Boolean;

    Destructor Destroy; override;

    procedure Add(const S:String);
    procedure AddAppend(const S: String);
    procedure AddNewLine;
    function AppendPosition(ACode:TBaseCode; const S:String):String;
    procedure AppendReserved(ACode:TBaseCode; const S:String);

    function CodeOf(ACode:TBaseCode; AParams:TParameters=nil):String; virtual; abstract;
    function Emit(ACode:TBaseCode):String; virtual;
    function FindCode(APos:Integer):TBaseCode;
    function FindPosition(ACode:TBaseCode; var P:TPosition):Boolean;
  end;

  TRunner=procedure(Sender:TCode);

var
  One : TInteger=nil;
  Runner : TNotifyEvent=nil;
  Stopped : Boolean=False;
  TeeCodes : TList;

procedure RegisterTeeCodes(const ACodes:Array of TComponentClass);
function UniqueName(Owner,Instance:TComponent):String;

const
  Codes:Array[0..34] of TComponentClass=(
                  TProcedure, TInteger, TFloat, TString,
                  TAssignment, TParameters, TAdd, TSubtract, TDivide,
                  TMultiply, TLower, TGreater, TLowerOrEqual, TGreaterOrEqual,
                  TEqual, TNot, TWhile, TFunction, TIncrement, TIf,
                  TRepeat, TFor, TForEach, TArray, TDifferent, TCall,
                  TFunctionCall, TCopy, TAnd, TOr, TProperty, TCodeClass,
                  TComment, TTry, TRaise);

implementation

{$IFDEF VER200}
{$DEFINE D10UP}
{$ENDIF}
{$IFDEF VER210}
{$DEFINE D10UP}
{$ENDIF}
{$IFDEF VER220}
{$DEFINE D10UP}
{$ENDIF}
{$IFDEF VER230}
{$DEFINE D10UP}
{$ENDIF}

uses
  Math, TypInfo;

procedure RegisterTeeCodes(const ACodes:Array of TComponentClass);
var t : Integer;
begin
  for t := Low(ACodes) to High(ACodes) do
      TeeCodes.Add(ACodes[t]);
end;

{ TCode }

procedure TCode.Run;
var
  t: Integer;
begin
  if Assigned(Runner) then
     Runner(Self);

  if Assigned(FItems) then
    for t:= 0 to Count-1 do
    begin
      if Stopped then
         break;

      if ValidItem(Items[t]) then
         TCode(FItems[t]).Run;
    end;
end;

function TCode.ValidItem(AItem:TBaseCode):Boolean;
begin
  result:=AItem is TCode;
end;

{ TBaseCode }

procedure TBaseCode.Add(const Value: TBaseCode);
begin
  if not Assigned(FItems) then
     FItems:=TList.Create;

  FItems.Add(Value);
  Value.FParent:=Self;

  Changed;
end;

procedure TBaseCode.Changed;
begin
  if not (csDestroying in ComponentState) then
  begin
    if Assigned(Parent) then
       Parent.Changed;

    if Assigned(FOnChange) then
       FOnChange(Self);
  end;
end;

procedure TBaseCode.ChangeReference(var AComp: TComponent;
  const AValue: TComponent);
begin
  if AComp<>AValue then
  begin
    if Assigned(AComp) then
       AComp.RemoveFreeNotification(Self);

    AComp:=AValue;

    if Assigned(AComp) then
       AComp.FreeNotification(Self);

    Changed;
  end;
end;

function TBaseCode.Count: Integer;
begin
  if Assigned(FItems) then
     result:=FItems.Count
  else
     result:=0;
end;

destructor TBaseCode.Destroy;
begin
  Parent:=nil;
  FItems.Free;
  inherited;
end;

function TBaseCode.Get(Index: Integer): TBaseCode;
begin
  result:=FItems[Index];
end;

procedure TBaseCode.GetChildren(Proc: TGetChildProc; Root: TComponent);
var t : Integer;
begin
  inherited;

  if Assigned(FItems) then
  for t := 0 to FItems.Count - 1 do
      Proc(FItems[t]);
end;

function TBaseCode.GetIndex: Integer;
begin
  if Assigned(Parent) then
     result:=Parent.FItems.IndexOf(Self)
  else
     result:=-1;
end;

function TBaseCode.GetParentComponent: TComponent;
begin
  result:=FParent;
end;

function TBaseCode.HasParent: Boolean;
begin
  result:=Assigned(FParent);
end;

procedure TBaseCode.ReadState(Reader: TReader);
begin
  if Reader.Parent is TBaseCode then
     Parent := TBaseCode(Reader.Parent);

  inherited;
end;

procedure TBaseCode.Remove(const Value: TBaseCode);
begin
  FItems.Remove(Value);
  Changed;
end;

procedure TBaseCode.SetIndex(const Value: Integer);
begin
  if Assigned(Parent) then
  begin
    Parent.FItems[Index]:=Parent.FItems[Value];
    Parent.FItems[Value]:=Self;
  end;
end;

procedure TBaseCode.SetName(const NewName: TComponentName);
var tmp : TComponentName;
begin
  tmp:=Name;
  inherited;
  if tmp<>Name then
     Changed;
end;

function TBaseCode.IsChildrenRecursive(ACode:TBaseCode):Boolean;
var t : Integer;
begin
  if (Count>0) and (FItems.IndexOf(ACode)<>-1) then
     result:=True
  else
  begin
    result:=False;

    for t := 0 to Count-1 do
    if Items[t].IsChildrenRecursive(ACode) then
    begin
      result:=True;
      break;
    end;
  end;
end;

procedure TBaseCode.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if (Operation=opRemove) and (AComponent=FParent) then
     FParent:=nil;
end;

procedure TBaseCode.SetParent(const Value: TBaseCode);
begin
  if (Self<>Value) and (Parent<>Value) and (not IsChildrenRecursive(Value)) then
  begin
    if Assigned(FParent) then
    begin
      FParent.RemoveFreeNotification(Self);
      FParent.Remove(Self);
    end;

    if Assigned(Value) then
    begin
      Value.Add(Self);
      FParent.FreeNotification(Self);
    end
    else
       FParent:=nil;
  end;
end;

procedure TBaseCode.SetParentComponent(Value: TComponent);
begin
  if (FParent <> Value) and (Value is TBaseCode) then
    SetParent(TBaseCode(Value));
end;

{ TAssignment }

procedure TAssignment.Reverse;
var tmp : TData;
begin
  tmp:=FValue;
  FValue:=FVariable;
  FVariable:=tmp;
  Changed;
end;

procedure TAssignment.Run;
begin
  inherited;

  if Assigned(Variable) then
     Variable.Assign(Value)
  else
     raise CodeException.Create('Assignment Variable not set. '+Name);
end;

procedure TAssignment.SetValue(const AValue: TData);
begin
  if FValue<>AValue then
  begin
    FValue:=AValue;
    Changed;
  end;
end;

procedure TAssignment.SetVariable(const AValue: TData);
begin
  if FVariable<>AValue then
  begin
    FVariable:=AValue;
    Changed;
  end;
end;

{ TInteger }

procedure TInteger.Assign(Source: TPersistent);
begin
  if not Assigned(Source) then
     Value:=0
  else
  if Source is TInteger then
     Value:=TInteger(Source).Value
  else
  if Source is TFloat then
     Value:=Round(TFloat(Source).Value)
  else
  if Source is TString then
     Value:=StrToInt(TString(Source).Value)
  else
  if Source is TExpression then
     Assign(TExpression(Source).Value)
  else
     inherited;
end;

procedure TInteger.SetValue(const AValue: Integer);
begin
  if FValue<>AValue then
  begin
    FValue:=AValue;
    Changed;
  end;
end;

{ TDivide }

function TDivide.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TInteger.Create(Self);
       TInteger(result).Value:=TInteger(L).Value div TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TInteger(L).Value / TFloat(R).Value;
     end
  else
  if L is TFloat then
     if R is TInteger then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value / TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value / TFloat(R).Value;
     end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TFloat }

procedure TFloat.Assign(Source: TPersistent);
begin
  if not Assigned(Source) then
     Value:=0
  else
  if Source is TFloat then
     Value:=TFloat(Source).Value
  else
  if Source is TInteger then
     Value:=TInteger(Source).Value
  else
  if Source is TString then
     Value:=StrToFloat(TString(Source).Value)
  else
     inherited;
end;

procedure TFloat.SetValue(const AValue: Single);
begin
  if FValue<>AValue then
  begin
    FValue:=AValue;
    Changed;
  end;
end;

{ TString }

procedure TString.Assign(Source: TPersistent);
begin
  if not Assigned(Source) then
     Value:=''
  else
  if Source is TFloat then
     Value:=FloatToStr(TFloat(Source).Value)
  else
  if Source is TInteger then
     Value:=IntToStr(TInteger(Source).Value)
  else
  if Source is TString then
     Value:=TString(Source).Value
  else
     inherited;
end;

procedure TString.SetValue(const AValue: String);
begin
  if FValue<>AValue then
  begin
    FValue:=AValue;
    Changed;
  end;
end;

{ TAdd }

function TAdd.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TInteger.Create(Self);
       TInteger(result).Value:=TInteger(L).Value+TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TInteger(L).Value+TFloat(R).Value;
     end
  else
  if L is TFloat then
     if R is TInteger then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value+TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value+TFloat(R).Value;
     end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TOperator }

procedure TOperator.SetLeft(const Value: TData);
begin
  if FLeft<>Value then
  begin
    FLeft:=Value;
    Changed;
  end;
end;

procedure TOperator.SetRight(const Value: TData);
begin
  if FRight<>Value then
  begin
    FRight:=Value;
    Changed;
  end;
end;

function TOperator.Value: TData;
begin
  result:=inherited Value;

  if FLeft is TExpression then
     L:=TExpression(FLeft).Value
  else
     L:=FLeft;

  if FRight is TExpression then
     R:=TExpression(FRight).Value
  else
     R:=FRight;
end;

{ TSubtract }

function TSubtract.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TInteger.Create(Self);
       TInteger(result).Value:=TInteger(L).Value-TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TInteger(L).Value-TFloat(R).Value;
     end
  else
  if L is TFloat then
     if R is TInteger then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value-TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value-TFloat(R).Value;
     end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TMultiply }

function TMultiply.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TInteger.Create(Self);
       TInteger(result).Value:=TInteger(L).Value * TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TInteger(L).Value * TFloat(R).Value;
     end
  else
  if L is TFloat then
     if R is TInteger then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value * TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TFloat.Create(Self);
       TFloat(result).Value:=TFloat(L).Value * TFloat(R).Value;
     end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TWhile }

procedure TWhile.Run;
begin
  while (not Stopped) and (Expression.Value as TBoolean).Value do
        inherited;
end;

{ TBoolean }

procedure TBoolean.Assign(Source: TPersistent);
begin
  if not Assigned(Source) then
     Value:=False
  else
  if Source is TBoolean then
     Value:=TBoolean(Source).Value
  else
  if Source is TExpression then
     Value:=TBoolean(TExpression(Source).Value).Value
  else
     inherited;
end;

procedure TBoolean.SetValue(const AValue: Boolean);
begin
  if FValue<>AValue then
  begin
    FValue:=AValue;
    Changed;
  end;
end;

{ TLower }

function TLower.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TInteger(L).Value < TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TInteger(L).Value < TFloat(R).Value;
     end
  else
  if L is TFloat then
     if R is TInteger then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TFloat(L).Value < TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TFloat(L).Value < TFloat(R).Value;
     end;

//  if L<>FLeft then L.Free;
//  if R<>FRight then R.Free;
end;

{ TGreater }

function TGreater.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TInteger(L).Value > TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TInteger(L).Value > TFloat(R).Value;
     end
  else
  if L is TFloat then
     if R is TInteger then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TFloat(L).Value > TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TFloat(L).Value > TFloat(R).Value;
     end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TLowerOrEqual }

function TLowerOrEqual.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TInteger(L).Value <= TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TInteger(L).Value <= TFloat(R).Value;
     end
  else
  if L is TFloat then
     if R is TInteger then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TFloat(L).Value <= TInteger(R).Value;
     end
     else
     if R is TFloat then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TFloat(L).Value <= TFloat(R).Value;
     end;


  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TGreaterOrEqual }

function TGreaterOrEqual.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TBoolean.Create(Self);
       TBoolean(result).Value:=TInteger(L).Value >= TInteger(R).Value;
     end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TEqual }

function TEqual.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
  begin
    if R is TInteger then
    begin
      result:=TBoolean.Create(Self);
      TBoolean(result).Value:=TInteger(L).Value = TInteger(R).Value;
    end;
  end
  else
  if L is TFloat then
  begin
    if R is TFloat then
    begin
      result:=TBoolean.Create(Self);
      TBoolean(result).Value:=TFloat(L).Value = TFloat(R).Value; // Epsilon
    end;
  end
  else
  if L is TString then
  begin
    if R is TString then
    begin
      result:=TBoolean.Create(Self);
      TBoolean(result).Value:=TString(L).Value = TString(R).Value;
    end;
  end
  else
  if L is TBoolean then
  begin
    if R is TBoolean then
    begin
      result:=TBoolean.Create(Self);
      TBoolean(result).Value:=TBoolean(L).Value = TBoolean(R).Value;
    end;
  end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TNot }

function TNot.Value: TData;
var A : TData;
begin
  result:=inherited Value;

  if FOperand is TExpression then
     A:=TExpression(FOperand).Value
  else
     A:=FOperand;

  if A is TBoolean then
  begin
    result:=TBoolean.Create(Self);
    TBoolean(result).Value:=not TBoolean(A).Value;
  end;

  if A<>FOperand then A.Free;
end;

function UniqueName(Owner,Instance:TComponent):String;
var t : Integer;
    Prefix : String;
begin
  t:=0;

  Prefix:=Copy(Instance.ClassName,2,Length(Instance.ClassName));

  repeat
    Inc(t);
    result:=Prefix+IntToStr(t);
  until not Assigned(Owner.FindComponent(result));
end;

procedure CheckParams(AComp:TBaseCode; var AParams:TParameters);
begin
  if csDesigning in AComp.ComponentState then
     if (not Assigned(AComp.Owner)) or
        (not (csLoading in AComp.Owner.ComponentState)) then
     begin
       AParams:=TParameters.Create(AComp.Owner);
       AParams.Parent:=AComp;
       AParams.Name:=UniqueName(AComp.Owner,AParams);
     end;
end;

{ TFunction }

procedure TFunction.SetResult(const Value: TData);
begin
  if FResult<>Value then
  begin
    FResult:=Value;
    Changed;
  end;
end;

function TFunction.Value: TData;
begin
  inherited Value;
  if Assigned(FOnRun) then
     FOnRun(Self);

  result:=FResult;
end;

{ TIncrement }

procedure TIncrement.Run;
var V : TData;
begin
  if Assigned(Runner) then
     Runner(Self);

  if Value is TExpression then
     V:=TExpression(Value).Value
  else
     V:=Value;

  if FVariable is TInteger then
     if V is TInteger then
        TInteger(FVariable).Value:=TInteger(FVariable).Value+TInteger(V).Value
     else
     if V is TFloat then
        TInteger(FVariable).Value:=Round(TInteger(FVariable).Value+TFloat(V).Value)
  else
  if FVariable is TFloat then
     if V is TInteger then
        TFloat(FVariable).Value:=TFloat(FVariable).Value+TInteger(V).Value
     else
     if V is TFloat then
        TFloat(FVariable).Value:=TFloat(FVariable).Value+TFloat(V).Value
end;

{ TIf }

procedure TIf.Run;
begin
  if (FExpression.Value as TBoolean).Value then
     inherited
  else
  if Assigned(FElseDo) then
     FElseDo.Run;
end;

procedure TIf.SetElseDo(const Value: TCode);
begin
  if FElseDo<>Value then
  begin
    FElseDo:=Value;
    Changed;
  end;
end;

procedure TIf.SetExpression(const Value: TExpression);
begin
  if FExpression<>Value then
  begin
    FExpression:=Value;
    Changed;
  end;
end;

function TIf.ValidItem(AItem: TBaseCode): Boolean;
begin
  result:=inherited ValidItem(AItem) and (AItem<>FElseDo);
end;

{ TFor }

procedure TFor.Run;
var S : TInteger;
begin
  TInteger(Iterator).Value:=TInteger(FromValue).Value;

  if Assigned(FStep) then
     S:=TInteger(FStep)
  else
     S:=One;

  while (not Stopped) and
        (TInteger(Iterator).Value <= TInteger(ToValue).Value) do
  begin
    inherited;

    TInteger(Iterator).Value:=TInteger(Iterator).Value + TInteger(S).Value;
  end;
end;

procedure TFor.SetFrom(const Value: TNumber);
begin
  if FFrom<>Value then
  begin
    FFrom:=Value;
    Changed;
  end;
end;

procedure TFor.SetIterator(const Value: TNumber);
begin
  if FIterator<>Value then
  begin
    FIterator:=Value;
    Changed;
  end;
end;

procedure TFor.SetStep(const Value: TNumber);
begin
  if FStep<>Value then
  begin
    FStep:=Value;
    Changed;
  end;
end;

procedure TFor.SetTo(const Value: TNumber);
begin
  if FTo<>Value then
  begin
    FTo:=Value;
    Changed;
  end;
end;

{ TForEach }

procedure TForEach.Run;
var t : Integer;
begin
  for t:=0 to Data.Count-1 do
  begin
    Iterator:=Data[t];
    inherited;

    if Stopped then
       break;
  end;
end;

procedure TForEach.SetData(const Value: TArray);
begin
  if FData<>Value then
  begin
    FData:=Value;
    Changed;
  end;
end;

procedure TForEach.SetIterator(const Value: TData);
begin
  if FIterator<>Value then
  begin
    FIterator:=Value;
    Changed;
  end;
end;

{ TRepeat }

procedure TRepeat.Run;
begin
  repeat
    inherited;
  until Stopped or (Expression.Value as TBoolean).Value;
end;

{ TArray }

function TArray.Get(Index: Integer): TData;
begin
  result:=FItems[Index];
end;

procedure TArray.Put(Index: Integer; const Value: TData);
begin
  while Index>Count-1 do
     Add(nil);

  FItems[Index]:=Value;
  Changed;
end;

{ TDifferent }

function TDifferent.Value: TData;
begin
  result:=inherited Value;
  TBoolean(result).Value:=not TBoolean(result).Value;
end;

{ TModDivision }

function TModDivision.Value: TData;
begin
  result:=inherited Value;

  if L is TInteger then
     if R is TInteger then
     begin
       result:=TInteger.Create(Self);
       TInteger(result).Value:=TInteger(L).Value mod TInteger(R).Value;
     end;

  if L<>FLeft then L.Free;
  if R<>FRight then R.Free;
end;

{ TProcedure }

procedure TProcedure.Run;
begin
  inherited;
  if Assigned(FOnRun) then
     FOnRun(Self);
end;

procedure AssignParams(AParams,FParams:TParameters);
var
  t: Integer;
begin
  for t := 0 to Min(FParams.Count, AParams.Count)-1 do
      AParams[t].Assign(FParams[t]);
end;

{ TCall }

procedure TCall.Run;
begin
//  inherited;

  //  Parameters Push
  if Assigned(FParams) then
  begin
    if (FCode is TProcedure) and Assigned(TProcedure(FCode).FParams) then
       AssignParams(TProcedure(FCode).FParams,FParams)
    else
    if (FCode is TFunction) and Assigned(TFunction(FCode).FParams) then
       AssignParams(TFunction(FCode).FParams,FParams)
  end;

  if FCode is TCode then
     TCode(FCode).Run
  else
  if FCode is TExpression then
     TExpression(FCode).Value;

  Parameters.Pop;
end;

procedure TCall.SetCode(const Value: TBaseCode);
begin
  if FCode<>Value then
  begin
    FCode:=Value;
    Changed;
  end;
end;

{ TCopy }

type
  TDataClass=class of TData;

procedure TCopy.SetData(const Value: TData);
begin
  if FData<>Value then
  begin
    FData:=Value;
    Changed;
  end;
end;

function TCopy.Value: TData;
begin
  inherited Value;
  FValue.Free;
  FValue:=TDataClass(FData.ClassType).Create(Self);
  FValue.Assign(FData);
  result:=FValue;
end;

{ TAnd }

function TAnd.Value: TData;
begin
  result:=inherited Value;

  if (L is TBoolean) and (R is TBoolean) then
  begin
    result:=TBoolean.Create(Self);
    TBoolean(result).Value:=TBoolean(L).Value and TBoolean(R).Value;
  end;
end;

{ TOr }

function TOr.Value: TData;
begin
  result:=inherited Value;

  if (L is TBoolean) and (R is TBoolean) then
  begin
    result:=TBoolean.Create(Self);
    TBoolean(result).Value:=TBoolean(L).Value or TBoolean(R).Value;
  end;
end;

{ TParameters }

procedure TParameters.Pop;
var t : Integer;
begin
  for t := 0 to Count-1 do
  if Items[t] is TCopy then
     with TCopy(Items[t]) do
          FData.Assign(FValue);
end;

{ TData }

procedure TData.SetConstant(const Value: Boolean);
begin
  if FConst<>Value then
  begin
    FConst:=Value;
    Changed;
  end;
end;

{ TCodeParams }

constructor TCodeParams.Create(AOwner: TComponent);
begin
  inherited;
  CheckParams(Self,FParams);
end;

procedure TCodeParams.SetParams(const Value: TParameters);
begin
  if FParams<>Value then
  begin
    FParams:=Value;
    Changed;
  end;
end;

{ TUnaryOperator }

procedure TUnaryOperator.SetOperand(const Value: TData);
begin
  if FOperand<>Value then
  begin
    FOperand:=Value;
    Changed;
  end;
end;

{ TConditionLoop }

procedure TConditionLoop.SetExpression(const Value: TExpression);
begin
  if FExpression<>Value then
  begin
    FExpression:=Value;
    Changed;
  end;
end;

{ TExpression }

// TODO: Move to TBaseCode.Run
function TExpression.Value: TData;
var t : Integer;
begin
  for t := 0 to Count-1 do
  begin
    if Stopped then
       break;

    if Items[t] is TCode then  // ValidItem
       TCode(Items[t]).Run;
  end;

  result:=nil;
end;

{ TCodeLanguage }

procedure TCodeLanguage.Add(const S: String);
begin
  FText:=FText+S+{$IFDEF D10UP}#12{$ELSE}#13#10{$ENDIF};
end;

procedure TCodeLanguage.AddAppend(const S: String);
begin
  FText:=FText+S;
end;

procedure TCodeLanguage.AddNewLine;
begin
  FText:=FText+{$IFDEF D10UP}#12{$ELSE}#13#10{$ENDIF};
end;

procedure TCodeLanguage.AppendReserved(ACode:TBaseCode; const S:String);
var P : PPosition;
begin
  P:=NewPosition(ACode);
  P.Start:=Length(FText);
  AddAppend(S);
  P.Length:=Length(S);
  P.Style:=csReserved;

  Formatting.Add(P);
end;

procedure TCodeLanguage.AddPosition(P: PPosition);
begin
  P.Length:=Length(FText)-P.Start;
  Positions.Add(P);
end;

function TCodeLanguage.AppendPosition(ACode: TBaseCode;
  const S: String): String;
var P : PPosition;
begin
  result:=S;
  P:=NewPosition(ACode);
  AddAppend(S);
  AddPosition(P);
end;

procedure TCodeLanguage.Clear;

  procedure ClearList(AList:TList);
  var t : Integer;
  begin
    if Assigned(AList) then
    begin
      for t:=0 to AList.Count-1 do
          Dispose(PPosition(AList.Items[t]));

      AList.Clear;
    end;
  end;

begin
  ClearList(Positions);
  ClearList(Formatting);
end;

destructor TCodeLanguage.Destroy;
begin
  Clear;
  Positions.Free;
  Formatting.Free;

  inherited;
end;

function TCodeLanguage.Emit(ACode: TBaseCode):String;
begin
  FText:='';
  result:=FText;

  Clear;

  if not Assigned(Positions) then
     Positions:=TList.Create;

  if not Assigned(Formatting) then
     Formatting:=TList.Create;
end;

function TCodeLanguage.FindCode(APos: Integer): TBaseCode;
var t : Integer;
    P : PPosition;
begin
  result:=nil;

  if Assigned(Positions) then
  for t := 0 to Positions.Count-1 do
  begin
    P:=PPosition(Positions[t]);

    if (P.Start<=APos) and
       ((P.Start+P.Length)>APos) then
    begin
      result:=P.Code;
      break;
    end;
  end;
end;

function TCodeLanguage.FindPosition(ACode: TBaseCode;
  var P: TPosition): Boolean;
var t : Integer;
begin
  result:=False;

  if Assigned(Positions) then
  for t := 0 to Positions.Count-1 do
     if PPosition(Positions[t]).Code=ACode then
     begin
       P:=PPosition(Positions[t])^;
       result:=True;
     end;
end;

function TCodeLanguage.NewPosition(ACode: TBaseCode): PPosition;
begin
  New(result);
  result.Start:=Length(FText);
  result.Code:=ACode;
end;

{ TGetProperty }

procedure TProperty.Assign(Source: TPersistent);

  function AsInteger:Integer;
  begin
    if Source is TInteger then
       result:=TInteger(Source).Value
    else
    if Source is TFloat then
       result:=Round(TFloat(Source).Value)
    else
    if Source is TString then
       result:=StrToInt(TString(Source).Value)
    else
       result:=0;
  end;

  function AsFloat:Single;
  begin
    if Source is TInteger then
       result:=TInteger(Source).Value
    else
    if Source is TFloat then
       result:=TFloat(Source).Value
    else
    if Source is TString then
       result:=StrToFloat(TString(Source).Value)
    else
       result:=0;
  end;

  function AsString:String;
  begin
    if Source is TInteger then
       result:=IntToStr(TInteger(Source).Value)
    else
    if Source is TFloat then
       result:=FloatToStr(TFloat(Source).Value)
    else
    if Source is TString then
       result:=TString(Source).Value
    else
       result:='';
  end;

begin
  if Source is TExpression then
     Assign(TExpression(Source).Value)
  else
  case PropType(FComp,FPropName) of
    tkInteger: SetOrdProp(FComp,FPropName,AsInteger);
    tkFloat: SetFloatProp(FComp,FPropName,AsFloat);
    {$IFDEF D10UP}
    tkUString,
    {$ENDIF}
    tkLString,
    tkString: SetStrProp(FComp,FPropName,AsString);
  else
    inherited;
  end;
end;

procedure TProperty.SetComp(const Value: TComponent);
begin
  ChangeReference(FComp,Value);
end;

procedure TProperty.SetPropName(const Value: String);
begin
  if FPropName<>Value then
  begin
    FPropName:=Value;
    Changed;
  end;
end;

function TProperty.Value: TData;
begin
  result:=inherited Value;

  case PropType(FComp,FPropName) of
    tkInteger : begin
                  result:=TInteger.Create(Self);
                  TInteger(result).Value:=GetOrdProp(FComp,FPropName);
                end;
    tkFloat : begin
                result:=TFloat.Create(Self);
                TFloat(result).Value:=GetFloatProp(FComp,FPropName);
              end;
   {$IFDEF D10UP}
   tkUString,
   {$ENDIF}
   tkLString,
   tkString : begin
                result:=TString.Create(Self);
                TString(result).Value:=GetStrProp(FComp,FPropName);
              end;
  end;
end;

{ TCodeClass }

procedure TCodeClass.SetAncestor(const Value: TCodeClass);
begin
  if FAncestor<>Value then
  begin
    if Value=Self then
       raise Exception.Create('Class cannot be ancestor of itself');

    FAncestor:=Value;
    Changed;
  end;
end;

{ TExpressionParams }

constructor TExpressionParams.Create(AOwner: TComponent);
begin
  inherited;
  CheckParams(Self,FParams);
end;

procedure TExpressionParams.SetParams(const Value: TParameters);
begin
  if FParams<>Value then
  begin
    FParams:=Value;
    Changed;
  end;
end;

{ TFunctionCall }

procedure TFunctionCall.SetFunction(const Value: TFunction);
begin
  if FFunction<>Value then
  begin
    FFunction:=Value;
    Changed;
  end;
end;

function TFunctionCall.Value: TData;
begin
  inherited Value;
  AssignParams(FunctionCode.FParams,FParams);
  result:=FunctionCode.Value;
end;

{ TComment }

procedure TComment.SetText(const Value: String);
begin
  if FText<>Value then
  begin
    FText:=Value;
    Changed;
  end;
end;

{ TTry }

procedure TTry.Run;

  procedure DoTry;
  begin
    if Assigned(FFinally) then
    begin
      try
        inherited;
      finally
        FFinally.Run;
      end;
    end
    else
      inherited;
  end;

begin
  if Assigned(FCatch) then
  begin
    try
      DoTry;
    except
      on E:Exception do
         FCatch.Run;
    end;
  end
  else
    DoTry;
end;

procedure TTry.SetCatch(const Value: TCode);
begin
  ChangeReference(TComponent(FCatch),Value);
end;

procedure TTry.SetFinally(const Value: TCode);
begin
  ChangeReference(TComponent(FFinally),Value);
end;

{ TRaise }

procedure TRaise.Run;
begin
  inherited;
  raise Exception.Create(FMessage);
end;

procedure TRaise.SetMessage(const Value: String);
begin
  if FMessage<>Value then
  begin
    FMessage:=Value;
    Changed;
  end;
end;

initialization
  One:=TInteger.Create(nil);
  One.Value:=1;
  TeeCodes:=TList.Create;
  RegisterTeeCodes(Codes);
finalization
  TeeCodes.Free;
  One.Free;
end.
