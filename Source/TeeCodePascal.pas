{ TeeCode                                  }
{ by @davidberneda  davidberneda@gmail.com }
unit TeeCodePascal;

interface

uses
  Classes, TeeCode;

type
  TPascalCode=class(TCodeLanguage)
  private
    Destination : TData;
    Ident : String;
    Declaring  : Boolean;

    procedure ParametersOf(P:TParameters);
    function ParametersPass(AParams:TParameters):String;
  public
    function CodeOf(ACode:TBaseCode; AParams:TParameters=nil):String; override;
    function Emit(ACode:TBaseCode):String; override;
    class function ValueOf(AData:TData):String;
  end;

  TUses=class(TBaseCode)
  end;

  TProgram=class(TFunction)
  private
    FUses: TUses;
    procedure SetUses(const Value: TUses);
  published
    property UsesUnits:TUses read FUses write SetUses;
  end;

  TUnitSection=class(TBaseCode)
  private
    FUses: TUses;
    procedure SetUses(const Value: TUses);
  published
    property UsesUnits:TUses read FUses write SetUses;
  end;

  TInterface=class(TUnitSection)
  end;

  TImplementation=class(TUnitSection)
  end;

  TInitialization=class(TProcedure)
  end;

  TFinalization=class(TProcedure)
  end;

  TUnit=class(TData)
  private
    FFinal: TFinalization;
    FIntf: TInterface;
    FInit: TInitialization;
    FImpl: TImplementation;
    procedure SetFinalization(const Value: TFinalization);
    procedure SetImplementation(const Value: TImplementation);
    procedure SetInitialization(const Value: TInitialization);
    procedure SetInterface(const Value: TInterface);
  published
    property UnitInterface:TInterface read FIntf write SetInterface;
    property UnitImplementation:TImplementation read FImpl write SetImplementation;
    property UnitInitialization:TInitialization read FInit write SetInitialization;
    property UnitFinalization:TFinalization read FFinal write SetFinalization;
  end;

  TUseUnit=class(TBaseCode)
  private
    FUsedUnit: TUnit;
    procedure SetUsedUnit(const Value: TUnit);
  published
    property UsedUnit:TUnit read FUsedUnit write SetUsedUnit;
  end;

implementation

uses
  SysUtils;

function OperatorOf(AOperator:TOperator; ACaller:TData):String;
begin
  if AOperator is TLower then
     result:='<'
  else
  if AOperator is TLowerOrEqual then
     result:='<='
  else
  if AOperator is TGreater then
     result:='>'
  else
  if AOperator is TGreaterOrEqual then
     result:='>='
  else
  if AOperator is TEqual then
     result:='='
  else
  if AOperator is TDifferent then
     result:='<>'  // #$2260
  else
  if AOperator is TAdd then
     result:='+'
  else
  if AOperator is TSubtract then
     result:='-'
  else
  if AOperator is TMultiply then
     result:='*'
  else
  if AOperator is TDivide then
     if ACaller is TInteger then
        result:='div'
     else
        result:='/'
  else
  if AOperator is TModDivision then
     result:='mod'
  else
     result:=AOperator.ClassName;
end;

function SeekClass(AClass:TClass; ACode:TBaseCode):TBaseCode;
var t : Integer;
begin
  result:=nil;

  for t := 0 to ACode.Count-1 do
  if ACode[t].ClassType=AClass then
  begin
    result:=ACode[t];
    break;
  end;
end;

function ParameterClass(ACode:TBaseCode):String;
begin
  if ACode is TInteger then
     result:='Integer'
  else
  if ACode is TFloat then
     result:='Single'
  else
  if ACode is TString then
     result:='String'
  else
  if ACode is TBoolean then
     result:='Boolean'
  else
  if ACode is TCodeClass then
     result:=ACode.Name
  else
     result:='?';
end;

function FindParameters(AProc:TeeCode.TProcedure):TParameters; overload;
begin
  result:=AProc.Parameters;

  if not Assigned(result) then
     result:=SeekClass(TParameters,AProc) as TParameters;
end;

function FindParameters(AFunc:TFunction):TParameters; overload;
begin
  result:=AFunc.Parameters;

  if not Assigned(result) then
     result:=SeekClass(TParameters,AFunc) as TParameters;
end;

procedure TPascalCode.ParametersOf(P:TParameters);
var t: Integer;
begin
  if Assigned(p) and (p.Count>0) then
  begin
    AddAppend('(');

    for t := 0 to p.Count-1 do
    begin
      if t=0 then
         AppendPosition(p[0],p[0].Name)
      else
      if p[t].ClassType=p[t-1].ClassType then
      begin
        AddAppend(', ');
        AppendPosition(p[t],p[t].Name);
      end
      else
      begin
        AddAppend(': '+ParameterClass(p[t-1])+'; ');
        AppendPosition(p[t],p[t].Name);
      end;
    end;

    AddAppend(': '+ParameterClass(p[p.Count-1])+')');
  end;
end;

function DataCount(ACode:TBaseCode; DontAdd:TData=nil):Integer;
var t : Integer;
begin
  result:=0;

  for t := 0 to ACode.Count-1 do
  if ACode[t]<>DontAdd then
  if (ACode[t] is TData) and (not (ACode[t] is TParameters)) then
     if ACode[t] is TArray then
        Inc(result, DataCount(ACode[t]))
     else
        Inc(result);
end;

class function TPascalCode.ValueOf(AData:TData):String;
begin
  if AData is TExpression then
    result:=ValueOf(TExpression(AData).Value)
  else
  if AData is TInteger then
    result:=IntToStr(TInteger(AData).Value)
  else
  if AData is TFloat then
    result:=FloatToStr(TFloat(AData).Value)
  else
  if AData is TString then
    result:=''''+TString(AData).Value+''''
  else
  if Assigned(AData) then
    result:=AData.Name
  else
    result:='?';
end;

type
  TCodeAccess=class(TCode);

{ TPascalCode }

function TPascalCode.CodeOf(ACode:TBaseCode; AParams:TParameters=nil):String;
var tmp, tmpRight : String;
begin
  if ACode is TIncrement then
  begin
    result:=TIncrement(ACode).Variable.Name+' := '+
            TIncrement(ACode).Variable.Name;

    tmpRight:=CodeOf(TIncrement(ACode).Value);

    if Copy(tmpRight,1,1)='-' then
       result:=result+' - '+Copy(tmpRight,2,Length(tmpRight))
    else
       result:=result+' + '+tmpRight;
  end
  else
  if ACode is TAssignment then
  begin
    if Assigned(TAssignment(ACode).Variable) then
       result:=TAssignment(ACode).Variable.Name+' := '
    else
       result:='? := ';

    if Running then
       result:=result+ValueOf(TAssignment(ACode).Value)
    else
    begin
      Destination:=TAssignment(ACode).Variable;
      result:=result+CodeOf(TAssignment(ACode).Value);
      Destination:=nil;
    end;
  end
  else
  if ACode is TOperator then
  begin
    result:='( '+CodeOf(TOperator(ACode).Left)+' ';

    tmp:=OperatorOf(TOperator(ACode), Destination);
    tmpRight:=CodeOf(TOperator(ACode).Right)+' )';

    if (tmp='+') and (Copy(tmpRight,1,1)='-') then
       tmp:='';

    result:=result+tmp+' '+tmpRight;
  end
  else
  if ACode is TCall then
    result:=CodeOf(TCall(ACode).Code, TCall(ACode).Parameters)
  else
  if ACode is TFunctionCall then
     result:=CodeOf(TFunctionCall(ACode).FunctionCode, TFunctionCall(ACode).Parameters)
  else
  if ACode is TFunction then
  begin
    if Assigned(AParams) then
       result:=ACode.Name+ParametersPass(AParams)
    else
       result:=ACode.Name+ParametersPass(TFunction(ACode).Parameters);
  end
  else
  if ACode is TeeCode.TProcedure then
  begin
    if Assigned(AParams) then
       result:=ACode.Name+ParametersPass(AParams)
    else
       result:=ACode.Name+ParametersPass(TeeCode.TProcedure(ACode).Parameters);
  end
  else
  if ACode is TCopy then
     if Assigned(TCopy(ACode).Data) then
        result:=TCopy(ACode).Data.Name
     else
        result:='?'
  else
  if (ACode is TData) and (Running or TData(ACode).Constant) then
    result:=ValueOf(TData(ACode))
  else
  if Assigned(ACode) then
     if ACode.Parent is TCodeClass then
        result:=ACode.Name+': '+ACode.ClassName
     else
        result:=ACode.Name
  else
    result:='?';
end;

function TPascalCode.ParametersPass(AParams:TParameters):String;
var t: Integer;
begin
  if Assigned(AParams) and (AParams.Count>0) then
  begin
    result:='(';

    for t := 0 to AParams.Count-1 do
    begin
      result:=result+CodeOf(AParams[t]);

      if t<AParams.Count-1 then
         result:=result+', ';
    end;


    result:=result+')';
  end
  else
     result:='';
end;

function TPascalCode.Emit(ACode: TBaseCode):String;

  procedure DoEmit(ACode:TBaseCode);

    function CountValidItems(ACode:TBaseCode):Integer;
    var t : Integer;
    begin
      result:=0;

      for t := 0 to ACode.Count-1 do
        if (ACode[t] is TeeCode.TProcedure) or (ACode[t] is TFunction) then
        else
        if TCodeAccess(ACode).ValidItem(ACode[t]) then
            Inc(result);
    end;

    procedure EmitDeclarations(ACode:TCodeClass);

      procedure EmitDeclaration(ACode:TBaseCode);
      begin
        Declaring:=True;
        DoEmit(ACode);
        Declaring:=False;
      end;

    var
      t: Integer;
    begin
      Ident:=Ident+'  ';

      for t := 0 to ACode.Count-1 do
        if (ACode[t] is TeeCode.TProcedure) or (ACode[t] is TFunction) then
           EmitDeclaration(ACode[t])
        else
        if ACode[t] is TData then
            DoEmit(ACode[t]);

      Ident:=Copy(Ident,1,Length(Ident)-2);
    end;

    procedure EmitItems(ACode:TBaseCode);
    var
      t: Integer;
    begin
      Ident:=Ident+'  ';

      for t := 0 to ACode.Count-1 do
        if (ACode[t] is TeeCode.TProcedure) or (ACode[t] is TFunction) then
        else
        if ACode[t] is TComment then
            DoEmit(ACode[t])
        else
        if (ACode is TCode) and TCodeAccess(ACode).ValidItem(ACode[t]) then
            DoEmit(ACode[t]);

      Ident:=Copy(Ident,1,Length(Ident)-2);
    end;

    procedure TryAddVariables(ACode:TBaseCode; DontAdd:TData=nil);

      procedure EmitVariables(ACode:TBaseCode);
      var t : Integer;
      begin
        for t := 0 to ACode.Count-1 do
        if ACode[t]<>DontAdd then
        if not (ACode[t] is TParameters) then
          if (ACode[t] is TData) and (not (ACode[t] is TFunctionCall)) then
             if (ACode[t] is TArray) or (ACode[t] is TOperator) then
                EmitVariables(ACode[t])
             else
                Add(Ident+'  '+ACode[t].Name+': '+ParameterClass(ACode[t])+';')
          else
  //        if not (ACode[t] is TOperator) then
             EmitVariables(ACode[t])
      end;

    var c : Integer;
    begin
      c:=DataCount(ACode,DontAdd);

      if c>0 then
      begin
        AddAppend(Ident);
        AppendReserved(ACode,'var');
        AddNewLine;
        EmitVariables(ACode);
      end;
    end;

    procedure EmitIdent(ACode:TBaseCode);
    begin
      Ident:=Ident+'  ';
      DoEmit(ACode);
      Ident:=Copy(Ident,1,Length(Ident)-2);
    end;

    procedure TryAddProceduresFunctions(ACode:TBaseCode);
    var t : Integer;
    begin
      for t := 0 to ACode.Count-1 do
        if (ACode[t] is TeeCode.TProcedure) or (ACode[t] is TFunction) then
        begin
          Add('');
          EmitIdent(ACode[t]);
          Add('');
        end;
    end;

    procedure EmitData(ACode:TBaseCode);
    var P: PPosition;
    begin
      P:=NewPosition(ACode);
      Add(ACode.Name+' = '+CodeOf(ACode)+';');
      AddPosition(P);
    end;

    procedure AddLineReserved(ACode:TBaseCode; const S:String);
    begin
      AddAppend(Ident);
      AppendReserved(ACode,S);
      AddNewLine;
    end;

    procedure EmitProcFunc(ACode:TBaseCode);
    begin
      TryAddProceduresFunctions(ACode);

      if ACode is TFunction then
         TryAddVariables(ACode,TFunction(ACode).Result)
      else
         TryAddVariables(ACode);

      AddLineReserved(ACode,'begin');
      EmitItems(ACode);

      if ACode is TProgram then
         AddLineReserved(ACode,'end.')
      else
         AddLineReserved(ACode,'end;');
    end;

    procedure EmitUses(AUses:TUses);
    var t, l : Integer;
        s : String;
    begin
      if Assigned(AUses) and (AUses.Count>0) then
      begin
        AppendReserved(ACode,'uses');
        AddNewLine;

        l:=0;

        for t := 0 to AUses.Count-1 do
        if AUses[t] is TUseUnit then
        begin
          s:=TUseUnit(AUses[t]).UsedUnit.Name;
          AddAppend(s);

          if t<AUses.Count-1 then
             AddAppend(', ');

          Inc(l,Length(s));

          if l>80 then
             AddNewLine;
        end;

        AppendReserved(AUses,';');
        AddNewLine;
      end;
    end;

    procedure EmitSection(ASection:TUnitSection);
    begin
      if Assigned(ASection) then
      begin
        EmitUses(ASection.UsesUnits);
        EmitItems(ASection);
      end;
    end;

  var
    c, t: Integer;
    P,ParamsPos : PPosition;
    params : TParameters;
  begin
    AddAppend(Ident);

    P:=NewPosition(ACode);

    if ACode is TProgram then
    begin
      AppendReserved(ACode,'program');
      AddAppend(' '+ACode.Name);
      AppendReserved(ACode,';');
      AddNewLine;

      EmitUses(TProgram(ACode).UsesUnits);
      EmitProcFunc(ACode);
    end
    else
    if ACode is TUnit then
    begin
      AppendReserved(ACode,'unit');
      AddAppend(' '+ACode.Name);
      AppendReserved(ACode,';');
      AddNewLine;

      AppendReserved(ACode,'interface');
      AddNewLine;
      EmitSection(TUnit(ACode).UnitInterface);

      AppendReserved(ACode,'implementation');
      AddNewLine;
      EmitSection(TUnit(ACode).UnitImplementation);

      DoEmit(TUnit(ACode).UnitInitialization);
      DoEmit(TUnit(ACode).UnitFinalization);
    end
    else
    if ACode is TInitialization then
    begin
      AppendReserved(ACode,'initialization');
      AddNewLine;
      EmitItems(ACode);
    end
    else
    if ACode is TFinalization then
    begin
      AppendReserved(ACode,'finalization');
      AddNewLine;
      EmitItems(ACode);
    end
    else
    if ACode is TeeCode.TProcedure then
    begin
      AppendReserved(ACode,'procedure');
      AddAppend(' ');

      if (not Declaring) and (ACode.Parent is TCodeClass) then
         AddAppend(ACode.Parent.Name+'.');

      AddAppend(ACode.Name);

      params:=FindParameters(TeeCode.TProcedure(ACode));

      ParamsPos:=NewPosition(params);
      ParametersOf(params);
      AddPosition(ParamsPos);

      AppendReserved(ACode,';');
      AddNewLine;

      if not Declaring then
         EmitProcFunc(ACode);
    end
    else
    if ACode is TFunction then
    begin
      AppendReserved(ACode,'function');
      AddAppend(' ');

      if (not Declaring) and (ACode.Parent is TCodeClass) then
         AddAppend(ACode.Parent.Name+'.');

      AddAppend(ACode.Name);

      params:=FindParameters(TFunction(ACode));

      ParamsPos:=NewPosition(params);
      ParametersOf(params);
      AddPosition(ParamsPos);

      if Assigned(TFunction(ACode).Result) then
         AddAppend(': '+ParameterClass(TFunction(ACode).Result))
      else
         AddAppend(': ?');

      AppendReserved(ACode,';');
      AddNewLine;

      if not Declaring then
         EmitProcFunc(ACode);
    end
    else
    if ACode is TWhile then
    begin
      AppendReserved(ACode,'while');
      AddAppend(' ');
      AppendPosition(TWhile(ACode).Expression,CodeOf(TWhile(ACode).Expression));
      AddAppend(' ');
      AppendReserved(ACode,'do');
      AddNewLine;

      c:=CountValidItems(ACode);

      if c>1 then
         AddLineReserved(ACode,'begin');

      EmitItems(ACode);

      if c>1 then
         AddLineReserved(ACode,'end;');

      AddNewLine;
    end
    else
    if ACode is TIf then
    begin
      AppendReserved(ACode,'if');
      AddAppend(' ');
      AppendPosition(TIf(ACode).Expression,CodeOf(TIf(ACode).Expression));
      AddAppend(' ');
      AppendReserved(ACode,'then');
      AddNewLine;

      c:=CountValidItems(ACode);

      if c>1 then
         AddLineReserved(ACode,'begin');

      EmitItems(ACode);

      if Assigned(TIf(ACode).ElseDo) then
      begin
        if c>1 then
           AddLineReserved(ACode,'end')
        else
        begin
          // Remove last ";"
          if Copy(FText,Length(FText),1)=';' then
             Delete(FText,Length(FText)-1,1);
        end;

        AddLineReserved(ACode,'else');
        DoEmit(TIf(ACode).ElseDo);
      end
      else
      if c>1 then
         AddLineReserved(ACode,'end;');

      AddNewLine;
    end
    else
    if ACode is TArray then
    begin
      for t := 0 to ACode.Count-1 do
          if ACode[t] is TData then
             EmitData(ACode[t]);
    end
    else
    if ACode is TCodeClass then
    begin
      AddAppend(ACode.Name+' = ');
      AppendReserved(ACode,'class');

      if Assigned(TCodeClass(ACode).Ancestor) then
         AddAppend('('+TCodeClass(ACode).Ancestor.Name+')');

      AddNewLine;
      EmitDeclarations(TCodeClass(ACode));
      AddLineReserved(ACode,'end;');
    end
    else
    if ACode is TComment then
       Add('// '+TComment(ACode).Text)
    else
    if ACode is TTry then
    begin
      AppendReserved(ACode,'try');
      AddNewLine;
      EmitItems(ACode);

      AppendReserved(ACode,'except');
      AddNewLine;

      if Assigned(TTry(ACode).Catch) then
         EmitIdent(TTry(ACode).Catch);

      AppendReserved(ACode,'finally');
      AddNewLine;

      if Assigned(TTry(ACode).FinallyCode) then
         EmitIdent(TTry(ACode).FinallyCode);

      AppendReserved(ACode,'end;');
      AddNewLine;
    end
    else
    if ACode is TRaise then
    begin
      AppendReserved(ACode,'raise');
      AddAppend(' Exception.Create('''+TRaise(ACode).Message+''');');
      AddNewLine;
    end
    else
    begin
      AddAppend(CodeOf(ACode));
      AppendReserved(ACode,';');
      AddNewLine;
    end;

    AddPosition(P);
  end;

begin
  inherited Emit(ACode);
  DoEmit(ACode);
  result:=FText;
end;

{ TUnit }

procedure TUnit.SetFinalization(const Value: TFinalization);
begin
  ChangeReference(TComponent(FFinal),Value);
end;

procedure TUnit.SetImplementation(const Value: TImplementation);
begin
  ChangeReference(TComponent(FImpl),Value);
end;

procedure TUnit.SetInitialization(const Value: TInitialization);
begin
  ChangeReference(TComponent(FInit),Value);
end;

procedure TUnit.SetInterface(const Value: TInterface);
begin
  ChangeReference(TComponent(FIntf),Value);
end;

{ TProgram }

procedure TProgram.SetUses(const Value: TUses);
begin
  ChangeReference(TComponent(FUses),Value);
end;

{ TUnitSection }

procedure TUnitSection.SetUses(const Value: TUses);
begin
  ChangeReference(TComponent(FUses),Value);
end;

{ TUseUnit }

procedure TUseUnit.SetUsedUnit(const Value: TUnit);
begin
  ChangeReference(TComponent(FUsedUnit),Value);
end;

initialization
  RegisterTeeCodes([TProgram,TUnit,TInterface,TImplementation,TInitialization,
                    TFinalization,TUseUnit,TUses]);
end.
