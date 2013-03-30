{ TeeCode                                  }
{ by @davidberneda  davidberneda@gmail.com }
unit TeeCodeViewer;

interface

uses
  Windows, Messages, Classes, TeeCode,
  Controls, StdCtrls, ComCtrls;

type
  TLinkEvent=procedure(Sender:TObject; const Link:String) of object;

  TCodeViewer=class(TRichEdit)
  private
    FCode: TBaseCode;
    FLang: TCodeLanguage;
    FOnLink: TLinkEvent;

    procedure CNNotify(var Msg: TWMNotify); message CN_NOTIFY;
    procedure CodeChanged(Sender:TObject);
    procedure SetCode(const Value: TBaseCode);
    procedure SetLang(const Value: TCodeLanguage);
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetLink(AStart, AEnd: Integer; AEnabled:Boolean);
  public
    Constructor Create(AOwner:TComponent); override;
    Destructor Destroy; override;

    procedure Changed;
    function FirstVisibleLine:Integer;
    procedure SetSelectionLength(Value: Integer);
  published
    property Code:TBaseCode read FCode write SetCode;
    property Language:TCodeLanguage read FLang write SetLang;
    property Lines stored False;
    property OnLink:TLinkEvent read FOnLink write FOnLink;

    property OnClick;
  end;

implementation

uses
  RichEdit, Graphics, TeeCodePascal;

{ TCodeViewer }

procedure TCodeViewer.CodeChanged(Sender: TObject);
begin
  if (not (csLoading in ComponentState)) and
     Assigned(Language) and (not Language.Running) then
       Changed;
end;

constructor TCodeViewer.Create(AOwner: TComponent);
begin
  inherited;
  Font.Name:='Courier New';
  Font.Size:=10;
  ScrollBars:=ssBoth;
  ReadOnly:=True;
end;

destructor TCodeViewer.Destroy;
begin
  if Assigned(FLang) and (FLang.Owner=Self) then
     FLang.Free;

  inherited;
end;

function TCodeViewer.FirstVisibleLine: Integer;
begin
  result:=Perform(EM_GETFIRSTVISIBLELINE, 0, 0);
end;

procedure TCodeViewer.Loaded;
begin
  inherited;

  if Lines.Count=0 then
     Changed;
end;

procedure TCodeViewer.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation=opRemove then
     if AComponent=FCode then
        FCode:=nil
     else
     if AComponent=FLang then
        FLang:=nil;
end;

procedure TCodeViewer.Changed;

  procedure AddFormatting;
  var t : Integer;
  begin
    for t:= 0 to FLang.Formatting.Count-1 do
    with PPosition(FLang.Formatting[t])^ do
    begin
      SelStart:=Start;
      SetSelectionLength(Length);
      SelAttributes.Style:=[{$IFDEF VER230}TFontStyle.{$ENDIF}fsBold];
      SelAttributes.Color:=clNavy;
    end;
  end;

  procedure AddLinks;
  var t : Integer;
  begin
    for t := 0 to FLang.Positions.Count-1 do
      with PPosition(FLang.Positions[t])^ do
        SetLink(Start,Length,True);
  end;

begin
  Clear;

  Lines.BeginUpdate;

  if not Assigned(FLang) then
    FLang:=TPascalCode.Create(Self);

  if Assigned(FCode) then
  begin
    Text:=FLang.Emit(FCode);

    AddFormatting;
    //AddLinks;

    SelStart:=0;
    SetSelectionLength(0);
  end;

  Lines.EndUpdate;
end;

procedure TCodeViewer.SetCode(const Value: TBaseCode);
begin
  if FCode<>Value then
  begin
    if Assigned(FCode) then
    begin
      FCode.RemoveFreeNotification(Self);
      FCode.Free;
    end;

    FCode:=Value;

    if Assigned(FCode) then
    begin
      FCode.FreeNotification(Self);
      FCode.OnChange:=CodeChanged;
    end;

    if not (csLoading in ComponentState) then
       Changed;
  end;
end;

procedure TCodeViewer.SetLang(const Value: TCodeLanguage);
begin
  if FLang <> Value then
  begin
    if Assigned(FLang) then
       FLang.RemoveFreeNotification(Self);

    FLang:=Value;

    if Assigned(FLang) then
       FLang.FreeNotification(Self);

    Changed;
  end;
end;

procedure TCodeViewer.CreateWnd;
var m : {$IFDEF VER230}NativeInt{$ELSE}Word{$ENDIF};
begin
  inherited;

  m:=SendMessage(Handle, EM_GETEVENTMASK, 0, 0);
  SendMessage(Handle, EM_SETEVENTMASK, 0, m or ENM_LINK);
end;

{$IFNDEF VER220}
function SendStructMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; const LParam): LRESULT;
begin
  Result := SendMessage(Handle, Msg, WParam, Windows.LPARAM(@LParam));
end;

function SendGetStructMessage(Handle: HWND; Msg: UINT; WParam: WPARAM;
  var LParam; Unused: Boolean = False): LRESULT;
begin
  Result := SendMessage(Handle, Msg, WParam, Windows.LPARAM(@LParam));
end;
{$ENDIF}

procedure TCodeViewer.SetSelectionLength(Value: Integer);
var
  CharRange: TCharRange;
begin
  SendGetStructMessage(Handle, EM_EXGETSEL, 0, CharRange);
  CharRange.cpMax := CharRange.cpMin + Value;
  SendStructMessage(Handle, EM_EXSETSEL, 0, CharRange);
//  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TCodeViewer.SetLink(AStart, AEnd: Integer; AEnabled:Boolean);
var Format: CHARFORMAT2;
    OldRange, NewRange: CHARRANGE;
begin
  FillChar(Format, SizeOf(Format), 0);
  Format.cbSize := SizeOf(Format);
  Format.dwMask := CFM_LINK;

  if AEnabled then Format.dwEffects := CFE_LINK;

  NewRange.cpMin := AStart;
  NewRange.cpMax := AEnd;

  SendMessage(Handle, EM_EXGETSEL, 0, LPARAM(@OldRange));
  SendMessage(Handle, EM_EXSETSEL, 0, LPARAM(@NewRange));
  SendMessage(Handle, EM_SETCHARFORMAT, SCF_SELECTION,LPARAM(@Format));
  SendMessage(Handle, EM_EXSETSEL, 0, LPARAM(@OldRange));
end;

procedure TCodeViewer.CNNotify(var Msg: TWMNotify);
var
  p: TENLink;
begin
  if Assigned(FOnLink) and (Msg.NMHdr^.code = EN_LINK) then
  begin
   p := TENLink(Pointer(Msg.NMHdr)^);
   if (p.Msg = WM_LBUTTONDOWN) then
    try
     SendMessage(Handle, EM_EXSETSEL, 0, Longint(@(p.chrg)));
     FOnLink(Self,SelText);
    except
    end;
  end;

  inherited;
end;

end.
