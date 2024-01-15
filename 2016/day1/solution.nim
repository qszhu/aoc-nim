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



proc parse(input: string): seq[(char, int)] =
  input.split(", ").mapIt (it[0], it[1 .. ^1].parseInt)

when defined(test):
  block:
    doAssert parse("R2, L3") == @[('R', 2), ('L', 3)]

const dPos = [(-1, 0), (0, 1), (1, 0), (0, -1)]

iterator walk(insts: seq[(char, int)]): (int, int) =
  var x, y = 0
  yield (x, y)
  var d = 0
  for (turn, dist) in insts:
    if turn == 'L': d = (d - 1 + 4) mod 4
    else: d = (d + 1) mod 4
    let (dx, dy) = dPos[d]
    for _ in 0 ..< dist:
      (x, y) = (x + dx, y + dy)
      yield (x, y)

proc dist(p: (int, int)): int =
  p[0].abs + p[1].abs

when defined(test):
  block:
    doAssert walk(@[('R', 2), ('L', 3)]).toSeq[^1].dist == 5

proc part1(input: string): int =
  walk(input.parse).toSeq[^1].dist

when defined(test):
  block:
    doAssert part1("R2, L3") == 5
    doAssert part1("R2, R2, R2") == 2
    doAssert part1("R5, L5, R5, R3") == 12

proc part2(input: string): int =
  var visited = initHashSet[(int, int)]()
  for (x, y) in walk(input.parse):
    if (x, y) in visited:
      return (x, y).dist
    visited.incl (x, y)

when defined(test):
  block:
    doAssert part2("R8, R4, R4, R8") == 4

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
