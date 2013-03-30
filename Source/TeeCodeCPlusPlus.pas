{ TeeCode                                  }
{ by @davidberneda  davidberneda@gmail.com }
unit TeeCodeCPlusPlus;

interface

uses
  Classes, TeeCode;

type
  TCPlusPlusCode=class(TCodeLanguage)
  private
    Destination : TData;
    Ident : String;

    function ParametersPass(AParams:TParameters):String;
  public
    function CodeOf(ACode:TBaseCode; AParams:TParameters=nil):String; override;
    function Emit(ACode:TBaseCode):String; override;
    class function ValueOf(AData:TData):String;
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
     result:='=='
  else
  if AOperator is TDifferent then
     result:='!='
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
        result:='/'
     else
        result:='\'
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
     result:='int'
  else
  if ACode is TFloat then
     result:='float'
  else
  if ACode is TString then
     result:='string'
  else
     result:='?';
end;

function ParametersOf(AProc:TeeCode.TProcedure):String;
var p : TParameters;
  t: Integer;
begin
  p:=AProc.Parameters;

  if not Assigned(p) then
     p:=SeekClass(TParameters,AProc) as TParameters;

  if Assigned(p) and (p.Count>0) then
  begin
    result:='(';

    for t := 0 to p.Count-1 do
    begin
      if t>0 then
         result:=result+', ';

      result:=result+ParameterClass(p[t])+' '+p[t].Name;
    end;

    result:=result+')';
  end
  else
     result:='';
end;

function DataCount(ACode:TBaseCode):Integer;
var t : Integer;
begin
  result:=0;

  for t := 0 to ACode.Count-1 do
  if (ACode[t] is TData) and (not (ACode[t] is TParameters)) then
     if ACode[t] is TArray then
        Inc(result, DataCount(ACode[t]))
     else
        Inc(result);
end;

class function TCPlusPlusCode.ValueOf(AData:TData):String;
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
    result:='"'+TString(AData).Value+'"'
  else
  if Assigned(AData) then
    result:=AData.Name
  else
    result:='?';
end;

type
  TCodeAccess=class(TCode);

{ TCPlusPlusCode }

function TCPlusPlusCode.CodeOf(ACode:TBaseCode; AParams:TParameters=nil):String;
begin
  if ACode is TIncrement then
     result:=TIncrement(ACode).Variable.Name+' += '+
              CodeOf(TIncrement(ACode).Value)
  else
  if ACode is TAssignment then
  begin
    if Assigned(TAssignment(ACode).Variable) then
       result:=TAssignment(ACode).Variable.Name+' = '
    else
       result:='? = ';

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
     result:='( '+CodeOf(TOperator(ACode).Left)+' '+
             OperatorOf(TOperator(ACode), Destination)+' '+
             CodeOf(TOperator(ACode).Right)+' )'
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
    result:=TCopy(ACode).Data.Name
  else
  if ACode is TRepeat then
    result:='do '+CodeOf(TWhile(ACode).Expression)
  else
  if (ACode is TData) and (Running or TData(ACode).Constant) then
    result:=ValueOf(TData(ACode))
  else
  if Assigned(ACode) then
    result:=ACode.Name
  else
    result:='?';
end;

function TCPlusPlusCode.ParametersPass(AParams:TParameters):String;
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

function TCPlusPlusCode.Emit(ACode: TBaseCode):String;

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

    procedure EmitItems(ACode:TBaseCode);
    var
      t: Integer;
    begin
      Ident:=Ident+'  ';

      for t := 0 to ACode.Count-1 do
        if (ACode[t] is TeeCode.TProcedure) or (ACode[t] is TFunction) then
        else
        if TCodeAccess(ACode).ValidItem(ACode[t]) then
            DoEmit(ACode[t]);

      Ident:=Copy(Ident,1,Length(Ident)-2);
    end;

    procedure TryAddVariables(ACode:TBaseCode);

      procedure EmitVariables(ACode:TBaseCode);
      var t : Integer;
      begin
        for t := 0 to ACode.Count-1 do
        if not (ACode[t] is TParameters) then
          if (ACode[t] is TData) then
             if (ACode[t] is TArray) or (ACode[t] is TOperator) then
                EmitVariables(ACode[t])
             else
                Add(Ident+'  '+ParameterClass(ACode[t])+' '+ACode[t].Name+';')
          else
  //        if not (ACode[t] is TOperator) then
             EmitVariables(ACode[t])
      end;

    var c : Integer;
    begin
      c:=DataCount(ACode);

      if c>0 then
         EmitVariables(ACode);
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
          DoEmit(ACode[t]);
          Add('');
        end;
    end;

  var
    c, t: Integer;
    P: PPosition;
  begin
    P:=NewPosition(ACode);

    if ACode is TeeCode.TProcedure then
    begin
      TryAddProceduresFunctions(ACode);

      AddAppend(Ident);
      AppendReserved(ACode,'void');
      AddAppend(' '+ACode.Name+ParametersOf(TeeCode.TProcedure(ACode)));
      AddNewLine;

      Add(Ident+'{');

      TryAddVariables(ACode);
      EmitItems(ACode);

      Add(Ident+'}');
    end
    else
    if ACode is TWhile then
    begin
      AddAppend(Ident);
      AppendReserved(ACode,'while');
      AddAppend(' '+CodeOf(TWhile(ACode).Expression));

      AddNewLine;

      c:=CountValidItems(ACode);

      if c>1 then
         Add(Ident+'{');

      EmitItems(ACode);

      if c>1 then
         Add(Ident+'}');
    end
    else
    if ACode is TIf then
    begin
      AddAppend(Ident);
      AppendReserved(ACode,'if');
      AddAppend(' '+CodeOf(TIf(ACode).Expression));
      AddNewLine;

      c:=CountValidItems(ACode);

      if c>1 then
         Add(Ident+'{');

      EmitItems(ACode);

      if Assigned(TIf(ACode).ElseDo) then
      begin
        if c>1 then
           Add(Ident+'}');

        Add(Ident+'else');
        DoEmit(TIf(ACode).ElseDo);
      end
      else
      if c>1 then
         Add(Ident+'}');
    end
    else
    if ACode is TArray then
    begin
      for t := 0 to ACode.Count-1 do
          if ACode[t] is TData then
             Add(ACode[t].Name+' = '+CodeOf(ACode[t])+';');
    end
    else
       Add(Ident+CodeOf(ACode)+';');

    AddPosition(P)
  end;

begin
  inherited Emit(ACode);
  DoEmit(ACode);
  result:=FText;
end;

end.
