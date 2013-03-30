{ TeeCode                                  }
{ by @davidberneda  davidberneda@gmail.com }
unit TeeCodeRegister;

interface

procedure Register;

implementation

uses
  Classes, TeeCode, TreeIntf, DesignIntf, DesignEditors,
  TeeCodeViewer, TeeCodeRunner;

{$R TeeCodeIcons.res}

type
  TCodeSprig=class(TComponentSprig)
  public
    function ItemIndex: Integer; override;
    function DragOverTo(AParent: TSprig): Boolean; override;
    function DragDropTo(AParent: TSprig): Boolean; override;
    class function PaletteOverTo(AParent: TSprig; AClass: TClass): Boolean; override;
//    class function ParentProperty: string; override;
    function SortByIndex: Boolean; override;
  end;

  TRunnerEditor=class(TComponentEditor)
  protected
    Function Runner:TRunner;
  public
    procedure Edit; override;
    procedure ExecuteVerb( Index : Integer ); override;
    function GetVerbCount : Integer; override;
    function GetVerb( Index : Integer ) : string; override;
  end;

  TAssignmentEditor=class(TComponentEditor)
  protected
    Function Assignment:TAssignment;
  public
    procedure ExecuteVerb( Index : Integer ); override;
    function GetVerbCount : Integer; override;
    function GetVerb( Index : Integer ) : string; override;
  end;

procedure Register;
begin
  RegisterNoIcon(Codes);

  RegisterComponents('TeeCode', Codes);
  RegisterComponents('TeeCode', [TCodeViewer,TRunner]);

  RegisterComponentEditor(TRunner,TRunnerEditor);
  RegisterComponentEditor(TAssignment,TAssignmentEditor);

  RegisterSprigType(TBaseCode, TCodeSprig);
end;

{ TCodeSprig }

function TCodeSprig.DragDropTo(AParent: TSprig): Boolean;
begin
  AParent.Add(Self);
  (Item as TBaseCode).Parent:=AParent.Item as TBaseCode;
  result:=True;
end;

function TCodeSprig.DragOverTo(AParent: TSprig): Boolean;
begin
  result:=inherited DragOverTo(AParent) or (AParent is TCodeSprig);
end;

function TCodeSprig.ItemIndex: Integer;
begin
  result:=(Item as TBaseCode).Index;
end;

class function TCodeSprig.PaletteOverTo(AParent: TSprig;
  AClass: TClass): Boolean;
begin
  Result := (AParent is TCodeSprig) or inherited PaletteOverTo(AParent, AClass);
end;

{
class function TCodeSprig.ParentProperty: string;
begin
  result:='Parent';
end;
}

function TCodeSprig.SortByIndex: Boolean;
begin
  Result := True;
end;

{ TRunnerEditor }

procedure TRunnerEditor.Edit;
begin
  if Assigned(Runner.Code) then
  begin
    TCodeRunner.Edit(nil,Runner.Code);
    Designer.Modified;
  end;
end;

procedure TRunnerEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: Edit;
  else
    inherited;
  end;
end;

function TRunnerEditor.GetVerb(Index: Integer): string;
begin
  Case Index of
    0: result:='&Edit...';
  else
    result:='';
  end;
end;

function TRunnerEditor.GetVerbCount: Integer;
begin
  result:=inherited GetVerbCount + 1;
end;

function TRunnerEditor.Runner: TRunner;
begin
  result:=TRunner(Component);
end;

{ TAssignmentEditor }

function TAssignmentEditor.Assignment: TAssignment;
begin
  result:=TAssignment(Component);
end;

procedure TAssignmentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: if not (Assignment.Value is TExpression) then
       begin
         Assignment.Reverse;
         Designer.Modified;
       end;
  else
    inherited;
  end;
end;

function TAssignmentEditor.GetVerb(Index: Integer): string;
begin
  Case Index of
    0: result:='&Reverse';
  else
    result:='';
  end;
end;

function TAssignmentEditor.GetVerbCount: Integer;
begin
  result:=inherited GetVerbCount + 1;
end;

end.
