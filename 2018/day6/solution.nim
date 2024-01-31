import std/[
  algorithm,
  bitops,
  deques,
  intsets,
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

import ../../lib/grid



proc parseLine(line: string): (int, int) =
  let p = line.split(", ").mapIt(it.parseInt)
  (p[0], p[1])

proc parse(input: string): seq[(int, int)] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
""".strip
  block:
    doAssert input.parse == @[(1, 1), (1, 6), (8, 3), (3, 4), (5, 5), (8, 9)]

proc genDistMap(points: seq[(int, int)], size: int): seq[seq[int]] =
  result = newSeqWith(size, newSeq[int](size))
  for r in 0 ..< size:
    for c in 0 ..< size:
      var dist = int.high
      var target = -1
      for i, (x, y) in points:
        let d = (r - y).abs + (c - x).abs
        if dist > d:
          dist = d
          target = i
        elif dist == d:
          target = -1
      result[r][c] = target

proc part1(input: string, size = 400): int =
  var distMap = genDistMap(input.parse, size)

  for r in 0 ..< size:
    for c in 0 ..< size:
      if r != 0 and r != size - 1 and c != 0 and c != size - 1: continue
      if distMap[r][c] == -1: continue
      floodfill(distMap, r, c, distMap[r][c], -1)

  for r in 0 ..< size:
    for c in 0 ..< size:
      if distMap[r][c] == -1: continue
      result = result.max floodfill(distMap, r, c, distMap[r][c], -1)

when defined(test):
  block:
    doAssert part1(input, 10) == 17



proc part2(input: string, thres = 10000, size = 400): int =
  let points = input.parse
  for r in 0 ..< size:
    for c in 0 ..< size:
      var d = 0
      for (x, y) in points:
        d += (r - y).abs + (c - x).abs
      if d < thres: result += 1

when defined(test):
  block:
    doAssert part2(input, 32, 10) == 16



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
