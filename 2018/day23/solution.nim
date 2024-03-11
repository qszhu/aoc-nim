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

import ../../lib/bisect



type
  Nanobot = tuple[x, y, z, r: int]

proc parseLine(line: string): Nanobot =
  if line =~ re"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)":
    let m = matches[0 ..< 4].mapIt(it.parseInt)
    (m[0], m[1], m[2], m[3])
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): seq[Nanobot] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
pos=<0,0,0>, r=4
pos=<1,0,0>, r=1
pos=<4,0,0>, r=3
pos=<0,2,0>, r=1
pos=<0,5,0>, r=3
pos=<0,0,3>, r=1
pos=<1,1,1>, r=1
pos=<1,1,2>, r=1
pos=<1,3,1>, r=1
""".strip
  block:
    let bots = input.parse
    doAssert bots[8] == (1, 3, 1, 1)

proc dist(a, b: Nanobot): int =
  let (x1, y1, z1, _) = a
  let (x2, y2, z2, _) = b
  (x1 - x2).abs + (y1 - y2).abs + (z1 - z2).abs

proc part1(input: string): int =
  let bots = input.parse.sortedByIt(-it[3])
  bots.countIt(dist(bots[0], it) <= bots[0][3])

when defined(test):
  block:
    doAssert part1(input) == 7



proc buildGraph(bots: seq[Nanobot]): seq[seq[bool]] =
  let N = bots.len
  result = newSeqWith(N, newSeq[bool](N))
  for i in 0 ..< N:
    let r1 = bots[i][3]
    for j in i + 1 ..< N:
      let r2 = bots[j][3]
      let d = dist(bots[i], bots[j])
      if d <= r1 + r2:
        result[i][j] = true
        result[j][i] = true

proc findMaxClique(adj: var seq[seq[bool]]): seq[int] =
  let N = adj.len
  var visited = newSeq[bool](N)
  var cur: seq[int]
  var maxSize = 0
  for i in 0 ..< N:
    if visited[i]: continue
    visited[i] = true
    cur = @[i]
    for j in i + 1 ..< N:
      if cur.allIt(adj[it][j]):
        cur.add j
        visited[j] = true
    if maxSize < cur.len:
      maxSize = cur.len
      result = cur

proc part2(input: string): int =
  let bots = input.parse

  proc maxClique(r: int): int =
    var adjList = (bots & (0, 0, 0, r)).buildGraph
    adjList.findMaxClique.len

  let p = maxClique(0)
  bisectRangeFirst(1, 1e10.int, r => maxClique(r) > p)

when defined(test):
  let input2 = """
pos=<10,12,12>, r=2
pos=<12,14,12>, r=2
pos=<16,12,12>, r=4
pos=<14,14,14>, r=6
pos=<50,50,50>, r=200
pos=<10,10,10>, r=5
""".strip
  block:
    doAssert part2(input2) == 36



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
