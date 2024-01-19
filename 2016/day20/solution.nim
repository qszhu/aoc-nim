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
  Range = (int, int)

proc parseLine(line: string): Range =
  if line =~ re"(\d+)-(\d+)":
    (matches[0].parseInt, matches[1].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert parseLine("5-8") == (5, 8)

proc lowestAllowed(ranges: seq[Range]): int =
  let ranges = ranges.sortedByIt(it[0])
  var r = -1
  for (a, b) in ranges:
    if r + 1 < a: break
    r = r.max b
  r + 1

proc part1(input: string): int =
  let ranges = input.split("\n").mapIt(it.parseLine)
  lowestAllowed(ranges)

when defined(test):
  let input = """
5-8
0-2
4-7
""".strip
  block:
    doAssert part1(input) == 3

proc countAllowed(ranges: seq[Range], hi: int): int =
  let ranges = ranges.sortedByIt(it[0])
  var r = -1
  for (a, b) in ranges:
    result += max(0, a - r - 1)
    r = r.max b
  result += max(0, hi - r)

proc part2(input: string, hi: int): int =
  let ranges = input.split("\n").mapIt(it.parseLine)
  countAllowed(ranges, hi)

when defined(test):
  block:
    doAssert part2(input, 9) == 2

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input, int32.high)
