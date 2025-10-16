# stack-based parser
import std/[strutils, tables]

type
  stackElement = object
    seStr: string = ""
    seChr: char = '#'
    seInt: int = -1
    seFloat: float = -1.0

func seType(element: stackElement): string =
  if element.seStr != "":
    result = "string"
  elif element.seChr != '#':
    result = "chr"
  elif element.seInt != -1:
    result = "int"
  elif element.seFloat != -1.0:
    result = "float"
  else:
    result = "empty"
  return result

func seStr(element: stackElement): string =
  return element.seStr

func seChr(element: stackElement): char =
  return element.seChr

func seInt(element: stackElement): int =
  return element.seInt

func seFloat(element: stackElement): float =
  return element.seFloat

var 
  dStack: seq[stackElement]
  curType: string

proc isChr(inputStr: string): bool =
  if inputStr.len == 1:
    var element = dStack.pop
    element.seChr = element.seStr[0]
    element.seStr = ""
    dStack.add(element)
    return true
  return false

proc parseForm(): stackElement =
  var 
    element: stackElement = dStack.pop
    lastChar: char = element.seStr[element.seStr.high]
    remainInt: int = try: parseInt(element.seStr[0 ..< element.seStr.high]) except: -1
    remainFloat: float = try: parseFloat(element.seStr[0 ..< element.seStr.high]) except: -1.0

  if lastChar in ['/', '*', '+', '-']:
    element.seChr = lastChar
    if remainInt != -1:
      element.seFloat = toFloat(remainInt)
      element.seStr = ""
    elif remainFloat != -1.0:
      element.seFloat = toFloat(remainInt)
      element.seStr = ""
    else:
      element.seStr = element.seStr[0 ..< element.seStr.high]
  else:
    element.seChr = '='
  echo element
  return element

proc stackAdd(): float =
  var
    arg1: float = dStack.pop.seFloat
    arg2: float = dStack.pop.seFloat
  if arg1 == -1.0 or arg2 == -1.0:
    return -1.0
  return arg1 + arg2

proc stackSub(): float =
  var
    arg1: float = dStack.pop.seFloat
    arg2: float = dStack.pop.seFloat
  if arg1 == -1.0 or arg2 == -1.0:
    return -1.0
  return arg1 - arg2 

proc stackDiv(): float =
  var
    arg1: float = dStack.pop.seFloat
    arg2: float = dStack.pop.seFloat
  echo arg1
  echo arg2
  if arg1 == -1.0 or arg2 == -1.0:
    return -1.0
  return arg1 / arg2

proc stackMul(): float =
  var
    arg1: float = dStack.pop.seFloat
    arg2: float = dStack.pop.seFloat
  if arg1 == -1.0 or arg2 == -1.0:
    return -1.0
  return arg1 * arg2

proc stackExc(excElement: stackElement): stackElement =
  var underElem = dStack.pop
  dStack.add(excElement)
  return underElem

proc parseFormula*(formula: openArray[string], valueTable: Table[string, float]): float =
  for fElement in formula:
    dStack.add(stackElement(seStr: fElement))
  echo dStack
  while true:
    if len(dStack) > 0:
      curType = seType(dStack[dStack.high])
    else:
      curType = "empty"

    if len(dStack) < 2:
      result = dStack.pop.seFloat
      break

    case curType:      
      of "string":
        var stackStr: string = seStr(dStack[dStack.high])
        if isChr(stackStr): break
        var tempElem: stackElement = parseForm()
        if tempElem.seStr != "":
          tempElem.seFloat = valueTable[tempElem.seStr]
          tempElem.seStr = ""
        dStack.add(tempElem)

      of "chr":
        var stackChr: char = seChr(dStack[dStack.high])
        case stackChr:
          of '/':
            dStack.add(stackElement(seFloat: stackDiv(), seChr: '='))
            echo dStack
          of '*':
            dStack.add(stackElement(seFloat: stackMul(), seChr: '='))
            echo dStack
          of '+':
            dStack.add(stackElement(seFloat: stackAdd(), seChr: '='))
            echo dStack
          of '-':
            dStack.add(stackElement(seFloat: stackSub(), seChr: '='))
            echo dStack
          of '=':
            dStack.add(stackExc(dStack.pop))
            echo dStack
          else: break

      of "int":
        var 
          stackInt: int = seInt(dStack[dStack.high])
          tempElem = dStack.pop
        tempElem.seFloat = toFloat(tempElem.seInt)
        tempElem.seInt = -1
        dStack.add(tempElem)

      of "float":
        var stackFloat: float = seFloat(dStack[dStack.high])
        
      of "empty":
        result = dStack.pop.seFloat
        break
  return result

# Example usage below
#var 
#  example_input = ["2*", "oranges/", "state"]
#  valTable: Table[string, float]
#valTable["state"] = 0.6
#valTable["oranges"] = 1.6
#echo parseFormula(example_input, valTable)