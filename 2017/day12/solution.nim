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

import ../../lib/dsu


proc parseLine(line: string): (int, seq[int]) =
  if line =~ re"(\d+) <-> (.+)":
    (matches[0].parseInt, matches[1].findAll(re"\d+").mapIt(it.parseInt))
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert "0 <-> 2".parseLine == (0, @[2])
    doAssert "2 <-> 0, 3, 4".parseLine == (2, @[0, 3, 4])

proc part1(input: string): int =
  let lines = input.split("\n")
  let dsu = newDSU(lines.len)
  for line in lines:
    let (u, vs) = line.parseLine
    for v in vs:
      dsu.union(u, v)
  dsu.compSize(0)

when defined(test):
  let input = """
0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5
""".strip
  block:
    doAssert part1(input) == 6

proc part2(input: string): int =
  let lines = input.split("\n")
  let dsu = newDSU(lines.len)
  for line in lines:
    let (u, vs) = line.parseLine
    for v in vs:
      dsu.union(u, v)
  dsu.numComps

when defined(test):
  block:
    doAssert part2(input) == 2



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
