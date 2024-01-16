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



type
  InstType = enum
    Rect
    RotateRow
    RotateColumn

  Inst = (InstType, int, int)

proc parseLine(line: string): Inst =
  if line =~ re"rect (\d+)x(\d+)":
    (InstType.Rect, matches[0].parseInt, matches[1].parseInt)
  elif line =~ re"rotate row y=(\d+) by (\d+)":
    (InstType.RotateRow, matches[0].parseInt, matches[1].parseInt)
  elif line =~ re"rotate column x=(\d+) by (\d+)":
    (InstType.RotateColumn, matches[0].parseInt, matches[1].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert parseLine("rect 3x2") == (InstType.Rect, 3, 2)
    doAssert parseLine("rotate column x=1 by 1") == (InstType.RotateColumn, 1, 1)
    doAssert parseLine("rotate row y=0 by 4") == (InstType.RotateRow, 0, 4)

type
  Screen = seq[seq[bool]]

proc newScreen(rows, cols: int): Screen {.inline.} =
  newSeqWith(rows, newSeq[bool](cols))

proc rows(self: Screen): int {.inline.} =
  self.len

proc cols(self: Screen): int {.inline.} =
  self[0].len

proc `$`(self: Screen): string {.inline.} =
  self.map(row => row.mapIt(if it: "#" else: ".").join).join("\n")

when defined(test):
  block:
    doAssert $newScreen(3, 7) == """
.......
.......
.......
""".strip

proc rect(self: Screen, a, b: int): Screen =
  result = self
  for r in 0 ..< b:
    for c in 0 ..< a:
      result[r][c] = true

proc rotateColumn(self: Screen, a, b: int): Screen =
  result = self
  for r in 0 ..< self.rows:
    result[r][a] = self[(r - b + self.rows) mod self.rows][a]

proc rotateRow(self: Screen, a, b: int): Screen =
  result = self
  for c in 0 ..< self.cols:
    result[a][c] = self[a][(c - b + self.cols) mod self.cols]

proc countLit(self: Screen): int =
  self.map(row => row.countIt(it)).sum

when defined(test):
  block:
    var s = newScreen(3, 7)
    s = s.rect(3, 2)
    doAssert $s == """
###....
###....
.......
""".strip
    s = s.rotateColumn(1, 1)
    doAssert $s == """
#.#....
###....
.#.....
""".strip
    s = s.rotateRow(0, 4)
    doAssert $s == """
....#.#
###....
.#.....
""".strip
    s = s.rotateColumn(1, 1)
    doAssert $s == """
.#..#.#
#.#....
.#.....
""".strip
    doAssert s.countLit == 6

proc part1(input: string): int =
  var s = newScreen(6, 50)
  for line in input.split("\n"):
    let (t, a, b) = parseLine(line)
    case t:
    of InstType.Rect:
      s = s.rect(a, b)
    of InstType.RotateRow:
      s = s.rotateRow(a, b)
    of InstType.RotateColumn:
      s = s.rotateColumn(a, b)
  echo $s
  s.countLit

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
