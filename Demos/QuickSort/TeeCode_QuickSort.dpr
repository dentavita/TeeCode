program TeeCode_QuickSort;

uses
  Forms,
  Unit_Test_QuickSort in 'Unit_Test_QuickSort.pas' {Form64},
  QuickSort in 'QuickSort.pas' {QuickSortCode};

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF VER180}
  Application.MainFormOnTaskbar := True;
  {$ENDIF}
  Application.CreateForm(TForm64, Form64);
  Application.CreateForm(TQuickSortCode, QuickSortCode);
  Application.Run;
end.
