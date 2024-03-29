import std/[
  algorithm,
  bitops,
  deques,
  json,
  math,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



proc ordinal(row, col: int): int =
  proc accu(s, n: int): int =
    (s + s + n - 1) * n div 2
  1 + accu(1, row - 1) + accu(row + 1, col - 1)

when defined(test):
  block:
    const indices = @[
      @[1, 3, 6, 10, 15, 21],
      @[2, 5, 9, 14, 20],
      @[4, 8, 13, 19],
      @[7, 12, 18],
      @[11, 17],
      @[16]
    ]
    for r, row in indices:
      for c, i in row:
        doAssert ordinal(r + 1, c + 1) == i

const MOD = 33554393

type
  mint* = distinct int64

proc `*`*(x, y: mint): mint {.inline.} = ((x.int64 mod MOD) * (y.int64 mod MOD) mod MOD).mint

proc `^`*(x, y: mint): mint =
  result = 1.mint
  var
    x = x
    y = y.int64
  while y > 0:
    if (y and 1) != 0: result = result * x
    x = x * x
    y = y shr 1

when defined(test):
  block:
    doAssert (20151125.mint * 252533.mint).int == 31916031
    doAssert (20151125.mint * (252533.mint ^ 2.mint)).int == 18749137

proc calc(row, col: int): int =
  let i = ordinal(row, col)
  (20151125.mint * (252533.mint ^ (i - 1).mint)).int

when defined(test):
  block:
    const m = @[
      @[20151125, 18749137, 17289845, 30943339, 10071777, 33511524],
      @[31916031, 21629792, 16929656, 7726640, 15514188, 4041754],
      @[16080970, 8057251, 1601130, 7981243, 11661866, 16474243],
      @[24592653, 32451966, 21345942, 9380097, 10600672, 31527494],
      @[77061, 17552253, 28094349, 6899651, 9250759, 31663883],
      @[33071741, 6796745, 25397450, 24659492, 1534922, 27995004],
    ]
    for r, row in m:
      for c, v in row:
        doAssert calc(r + 1, c + 1) == v

proc parse(input: string): (int, int) =
  var matches: array[2, string]
  if input.find(re"row (\d+), column (\d+)", matches) != -1:
    (matches[0].parseInt, matches[1].parseInt)
  else:
    raise newException(ValueError, "parse error: " & input)

when defined(test):
  block:
    doAssert parse("To continue, please consult the code grid in the manual.  Enter the code at row 2947, column 3029.") == (2947, 3029)

proc part1(input: string): int =
  let (row, col) = input.parse
  calc(row, col)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
