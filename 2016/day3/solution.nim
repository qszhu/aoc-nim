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



proc possibleTriangle(a, b, c: int): bool =
  let a = @[a, b, c].sorted
  a[0] + a[1] > a[2]

when defined(test):
  block:
    doAssert not possibleTriangle(5, 10, 25)

proc parseLine(line: string): (int, int, int) =
  if line =~ re"\s*(\d+)\s+(\d+)\s+(\d+)":
    let m = matches[0 .. 2].mapIt(it.parseInt)
    (m[0], m[1], m[2])
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert parseLine("  330  143  338") == (330, 143, 338)

proc part1(input: string): int =
  for line in input.split("\n"):
    let (a, b, c) = parseLine(line)
    if possibleTriangle(a, b, c):
      result += 1

proc part2(input: string): int =
  let lines = input.split("\n")
  for i in countup(0, lines.len - 1, 3):
    let (a1, a2, a3) = parseLine(lines[i])
    let (b1, b2, b3) = parseLine(lines[i + 1])
    let (c1, c2, c3) = parseLine(lines[i + 2])
    if possibleTriangle(a1, b1, c1): result += 1
    if possibleTriangle(a2, b2, c2): result += 1
    if possibleTriangle(a3, b3, c3): result += 1

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
