import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  options,
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]

import ../../lib/dsu



type
  Point = (int, int, int ,int)

proc parseLine(line: string): Point =
  let r = line.split(",").mapIt(it.strip.parseInt)
  (r[0], r[1], r[2], r[3])

when defined(test):
  block:
    doAssert " 0,0,0,0".parseLine == (0, 0, 0, 0)
    doAssert "-1,2,2,0".parseLine == (-1, 2, 2, 0)

proc dist(a, b: Point): int =
  let (x1, y1, z1, w1) = a
  let (x2, y2, z2, w2) = b
  (x1 - x2).abs + (y1 - y2).abs + (z1 - z2).abs + (w1 - w2).abs

proc parse(input: string): seq[Point] =
  input.split("\n").mapIt(it.parseLine)

proc part1(input: string): int =
  let points = input.parse
  let N = points.len
  var dsu = newDSU(N)
  for i in 0 ..< N:
    let a = points[i]
    for j in i + 1 ..< N:
      let b = points[j]
      if dist(a, b) <= 3:
        dsu.union(i, j)
  dsu.numComps

when defined(test):
  block:
    let input = """
 0,0,0,0
 3,0,0,0
 0,3,0,0
 0,0,3,0
 0,0,0,3
 0,0,0,6
 9,0,0,0
12,0,0,0
""".strip
    doAssert part1(input) == 2
  block:
    let input = """
-1,2,2,0
0,0,2,-2
0,0,0,-2
-1,2,0,0
-2,-2,-2,2
3,0,2,-1
-1,3,2,2
-1,0,-1,0
0,2,1,-2
3,0,0,0
""".strip
    doAssert part1(input) == 4
  block:
    let input = """
1,-1,0,1
2,0,-1,0
3,2,-1,0
0,0,3,1
0,0,-1,-1
2,3,-2,0
-2,2,0,0
2,-2,0,-1
1,-1,0,-1
3,2,0,2
""".strip
    doAssert part1(input) == 3
  block:
    let input = """
1,-1,-1,-2
-2,-2,0,1
0,2,1,3
-2,3,-2,1
0,2,3,-2
-1,-1,1,-2
0,-2,-1,0
-2,2,3,-1
1,2,2,0
-1,-2,0,-2
""".strip
    doAssert part1(input) == 8



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
