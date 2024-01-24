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



proc checkSum(line: string): int =
  let a = line.split(re"\s+").mapIt(it.parseInt)
  a.max - a.min

when defined(test):
  let input = """
5 1 9 5
7 5 3
2 4 6 8
""".strip
  block:
    let lines = input.split("\n")
    doAssert lines[0].checksum == 8
    doAssert lines[1].checksum == 4
    doAssert lines[2].checksum == 6

proc part1(input: string): int =
  input.split("\n").mapIt(it.checkSum).sum

when defined(test):
  block:
    doAssert part1(input) == 18

proc checkSum2(line: string): int =
  let a = line.split(re"\s+").mapIt(it.parseInt)
  for i, x in a:
    for j, y in a:
      if i == j: continue
      if x mod y == 0:
        return x div y

when defined(test):
  let input2 = """
5 9 2 8
9 4 7 3
3 8 6 5
""".strip
  block:
    let lines = input2.split("\n")
    doAssert lines[0].checksum2 == 4
    doAssert lines[1].checksum2 == 3
    doAssert lines[2].checksum2 == 2

proc part2(input: string): int =
  input.split("\n").mapIt(it.checkSum2).sum

when defined(test):
  block:
    doAssert part2(input2) == 9



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
