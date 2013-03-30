object QuickSortCode: TQuickSortCode
  Left = 298
  Top = 96
  Caption = 'QuickSort TeeCode'
  ClientHeight = 496
  ClientWidth = 608
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object CodeViewer1: TCodeViewer
    Left = 8
    Top = 8
    Width = 561
    Height = 480
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    Code = QuickSort
  end
  object Compare: TFunction
    Parameters = Parameters1
    Result = Result
    object Result: TInteger
      Value = 0
    end
    object Parameters1: TParameters
      object Integer1: TInteger
        Value = 0
      end
      object Integer2: TInteger
        Value = 0
      end
    end
  end
  object Constants: TArray
    Constant = True
    object One: TInteger
      Constant = True
      Value = 1
    end
    object Two: TInteger
      Constant = True
      Value = 2
    end
    object MinusOne: TInteger
      Constant = True
      Value = -1
    end
    object Zero: TInteger
      Constant = True
      Value = 0
    end
  end
  object Swap: TProcedure
    Parameters = Parameters2
    object Parameters2: TParameters
      object swapI: TInteger
        Value = 0
      end
      object swapJ: TInteger
        Value = 0
      end
    end
  end
  object QuickSort: TProcedure
    Parameters = Parameters
    object CallSub: TCall
      Parameters = Parameters
      Code = SubMain
    end
    object SubMain: TProcedure
      Parameters = SubParameters
      object Assignment1: TAssignment
        Variable = i
        Value = l
      end
      object Assignment2: TAssignment
        Variable = j
        Value = r
      end
      object Assignment3: TAssignment
        Variable = x
        Value = Divide1
        object Divide1: TDivide
          Left = Add1
          Right = Two
          object Add1: TAdd
            Left = i
            Right = j
          end
        end
      end
      object While1: TWhile
        Expression = Lower1
        object Lower1: TLower
          Left = i
          Right = j
        end
        object While2: TWhile
          Expression = Lower2
          object Increment1: TIncrement
            Variable = i
            Value = One
          end
          object Lower2: TLower
            Left = CallCompare1
            Right = Zero
            object CallCompare1: TFunctionCall
              Parameters = Parameters3
              FunctionCode = Compare
              object Parameters3: TParameters
                object Copy7: TCopy
                  Data = i
                end
                object Copy8: TCopy
                  Data = x
                end
              end
            end
          end
        end
        object While3: TWhile
          Expression = Lower3
          object Increment2: TIncrement
            Variable = j
            Value = MinusOne
          end
          object Lower3: TLower
            Left = CallCompare2
            Right = Zero
            object CallCompare2: TFunctionCall
              Parameters = Parameters4
              FunctionCode = Compare
              object Parameters4: TParameters
                object Copy9: TCopy
                  Data = x
                end
                object Copy10: TCopy
                  Data = j
                end
              end
            end
          end
        end
        object If1: TIf
          Expression = i_Lower_than_j
          object i_Lower_than_j: TLower
            Left = i
            Right = j
          end
          object CallSwap: TCall
            Parameters = ParametersCallSwap
            Code = Swap
            object ParametersCallSwap: TParameters
              object Copy5: TCopy
                Data = i
              end
              object Copy6: TCopy
                Data = j
              end
            end
          end
          object If2: TIf
            ElseDo = If_j_equals_x
            Expression = i_equals_x
            object i_equals_x: TEqual
              Left = i
              Right = x
            end
            object x_assign_j: TAssignment
              Variable = x
              Value = j
            end
            object If_j_equals_x: TIf
              Expression = j_equals_x
              object j_equals_x: TEqual
                Left = j
                Right = x
              end
              object x_assign_i: TAssignment
                Variable = x
                Value = i
              end
            end
          end
        end
        object If3: TIf
          Expression = LowerOrEqual1
          object LowerOrEqual1: TLowerOrEqual
            Left = i
            Right = j
          end
          object Increment3: TIncrement
            Variable = i
            Value = One
          end
          object Increment4: TIncrement
            Variable = j
            Value = MinusOne
          end
        end
      end
      object Variables: TArray
        object x: TInteger
          Value = 0
        end
        object j: TInteger
          Value = 0
        end
        object i: TInteger
          Value = 0
        end
      end
      object SubParameters: TParameters
        object l: TInteger
          Value = 0
        end
        object r: TInteger
          Value = 0
        end
      end
      object If4: TIf
        Expression = Lower4
        object Lower4: TLower
          Left = l
          Right = j
        end
        object Call1: TCall
          Parameters = ParametersCall1
          Code = SubMain
          object ParametersCall1: TParameters
            object Copy1: TCopy
              Data = l
            end
            object Copy2: TCopy
              Data = j
            end
          end
        end
      end
      object If5: TIf
        Expression = Lower5
        object Lower5: TLower
          Left = i
          Right = r
        end
        object Call2: TCall
          Parameters = ParametersCall2
          Code = SubMain
          object ParametersCall2: TParameters
            object Copy3: TCopy
              Data = i
            end
            object Copy4: TCopy
              Data = r
            end
          end
        end
      end
    end
    object Parameters: TParameters
      object FromIndex: TInteger
        Value = 0
      end
      object ToIndex: TInteger
        Value = 0
      end
    end
    object Comment1: TComment
      Text = 'Example'
    end
  end
end
