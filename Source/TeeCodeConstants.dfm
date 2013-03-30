object Constants: TConstants
  Left = 0
  Top = 0
  Caption = 'Constants'
  ClientHeight = 202
  ClientWidth = 447
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
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
  object Tick: TFunction
    Result = Integer1
    OnRun = TickRun
    object Integer1: TInteger
      Value = 0
    end
  end
  object Sin: TFunction
    Parameters = ParametersSin
    Result = SinResult
    OnRun = SinRun
    object ParametersSin: TParameters
      object SinAngle: TFloat
      end
    end
    object SinResult: TFloat
    end
  end
  object Runner1: TRunner
    Code = Sin
    Left = 216
    Top = 104
  end
end
