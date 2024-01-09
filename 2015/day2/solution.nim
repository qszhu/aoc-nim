import std/[
  algorithm,
  sequtils,
  strutils,
]



type Box = seq[int]

proc parse(input: string): seq[Box] =
  proc parseBox(line: string): Box =
    line.split('x').mapIt(it.parseInt).sorted
  input.split("\n").mapIt(it.parseBox)

proc part1(input: string): int =
  let boxes = input.parse
  for b in boxes:
    let (a, b, c) = (b[0], b[1], b[2])
    result += 3 * a * b + 2 * a * c + 2 * b * c

when defined(test):
  doAssert part1("2x3x4") == 58
  doAssert part1("1x1x10") == 43

proc part2(input: string): int =
  let boxes = input.parse
  for b in boxes:
    let (a, b, c) = (b[0], b[1], b[2])
    result += 2 * (a + b) + a * b * c

when defined(test):
  doAssert part2("2x3x4") == 34
  doAssert part2("1x1x10") == 14

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
