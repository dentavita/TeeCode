{ QuickSort sorting algorithm implemented with TeeCode components }
{ by @davidberneda  davidberneda@gmail.com                        }
unit QuickSort;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, TeeCode, StdCtrls, TeeCodeViewer,
  ComCtrls;

type
  TQuickSortCode = class(TForm)
    SubMain: TProcedure;
    i: TInteger;
    j: TInteger;
    x: TInteger;
    Assignment1: TAssignment;
    Assignment2: TAssignment;
    SubParameters: TParameters;
    r: TInteger;
    l: TInteger;
    Assignment3: TAssignment;
    Divide1: TDivide;
    Two: TInteger;
    Add1: TAdd;
    While1: TWhile;
    Lower1: TLower;
    While2: TWhile;
    Compare: TFunction;
    Result: TInteger;
    Parameters1: TParameters;
    Integer1: TInteger;
    Integer2: TInteger;
    Increment1: TIncrement;
    One: TInteger;
    MinusOne: TInteger;
    While3: TWhile;
    Increment2: TIncrement;
    If1: TIf;
    i_Lower_than_j: TLower;
    Constants: TArray;
    Variables: TArray;
    Swap: TProcedure;
    Parameters2: TParameters;
    swapI: TInteger;
    swapJ: TInteger;
    Lower2: TLower;
    Zero: TInteger;
    Lower3: TLower;
    QuickSort: TProcedure;
    CallSub: TCall;
    Parameters: TParameters;
    FromIndex: TInteger;
    ToIndex: TInteger;
    CallSwap: TCall;
    If2: TIf;
    i_equals_x: TEqual;
    x_assign_j: TAssignment;
    If_j_equals_x: TIf;
    j_equals_x: TEqual;
    x_assign_i: TAssignment;
    If3: TIf;
    LowerOrEqual1: TLowerOrEqual;
    Increment3: TIncrement;
    Increment4: TIncrement;
    If4: TIf;
    Lower4: TLower;
    Call1: TCall;
    If5: TIf;
    Lower5: TLower;
    Call2: TCall;
    CodeViewer1: TCodeViewer;
    ParametersCall1: TParameters;
    Copy1: TCopy;
    Copy2: TCopy;
    ParametersCall2: TParameters;
    Copy3: TCopy;
    Copy4: TCopy;
    ParametersCallSwap: TParameters;
    Copy5: TCopy;
    Copy6: TCopy;
    Parameters3: TParameters;
    CallCompare1: TFunctionCall;
    Copy7: TCopy;
    Copy8: TCopy;
    Parameters4: TParameters;
    CallCompare2: TFunctionCall;
    Copy9: TCopy;
    Copy10: TCopy;
    Comment1: TComment;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QuickSortCode: TQuickSortCode;

implementation

{$R *.dfm}

end.
