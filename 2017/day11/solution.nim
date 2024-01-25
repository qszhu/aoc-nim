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
  Pos = (int, int, int)

proc `+`(a, b: Pos): Pos =
  (a[0] + b[0], a[1] + b[1], a[2] + b[2])

proc `-`(a, b: Pos): Pos =
  (a[0] - b[0], a[1] - b[1], a[2] - b[2])

proc dist(a, b: Pos): int =
  let d = a - b
  max [d[0].abs, d[1].abs, d[2].abs]

const dPos = [
  (0, 1, -1),
  (1, 0, -1),
  (1, -1, 0),
  (0, -1, 1),
  (-1, 0, 1),
  (-1, 1, 0),
]

const dirs = ["n", "ne", "se", "s", "sw", "nw"]

proc move(a: Pos, d: string): Pos =
  a + dPos[dirs.find(d)]

proc part1(input: string): int =
  var p = (0, 0, 0)
  for d in input.split(","):
    p = p.move(d)
  dist(p, (0, 0, 0))

when defined(test):
  block:
    doAssert part1("ne,ne,ne") == 3
    doAssert part1("ne,ne,sw,sw") == 0
    doAssert part1("ne,ne,s,s") == 2
    doAssert part1("se,sw,se,sw,sw") == 3



proc part2(input: string): int =
  var p = (0, 0, 0)
  for d in input.split(","):
    p = p.move(d)
    result = result.max p.dist (0, 0, 0)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
