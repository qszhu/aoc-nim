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

import ../../lib/grid



const WALL = '#'

type
  Grid = object
    grid: seq[string]
    rows, cols, numLoc: int
    sr, sc: int

proc parse(input: string): Grid =
  let grid = input.split("\n")
  let rows = grid.len
  let cols = grid[0].len
  var numLoc = 0
  var sr, sc = -1
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      if grid[r][c].isDigit:
        numLoc = numLoc.max grid[r][c].ord - '0'.ord
        if grid[r][c] == '0':
          (sr, sc) = (r, c)
  Grid(grid: grid, rows: rows, cols: cols, numLoc: numLoc + 1, sr: sr, sc: sc)

when defined(test):
  let input = """
###########
#0.1.....2#
#.#######.#
#4.......3#
###########
""".strip
  block: doAssert input.parse == Grid(
    grid: input.split("\n"), rows: 5, cols: 11, numLoc: 5, sr: 1, sc: 1)

type
  State = tuple[r, c, mask: int]

proc isComplete(s: State, g: var Grid): bool =
  s.mask.countSetBits == g.numLoc

iterator next(s: State, g: var Grid): State =
  for (nr, nc) in neighbors4((s.r, s.c), (g.rows, g.cols)):
    if g.grid[nr][nc] == WALL: continue
    var mask = s.mask
    if g.grid[nr][nc].isDigit:
      let d = g.grid[nr][nc].ord - '0'.ord
      mask.setBit(d)
    yield (r: nr, c: nc, mask: mask)

proc bfs(g: var Grid, cf: proc (s: State, g: var Grid): bool): int =
  let s = (r: g.sr, c: g.sc, mask: 1)
  var q = @[s]
  var visited = initHashSet[State]()
  visited.incl s
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for s in q:
      if s.cf(g): return steps
      for ns in s.next(g):
        if ns in visited: continue
        visited.incl ns
        next.add ns
    q = next
    steps += 1

proc part1(input: string): int =
  var grid = input.parse
  bfs(grid, isComplete)

when defined(test):
  block:
    doAssert part1(input) == 14

proc isComplete2(s: State, g: var Grid): bool =
  s.mask.countSetBits == g.numLoc and (s.r, s.c) == (g.sr, g.sc)

proc part2(input: string): int =
  var grid = input.parse
  bfs(grid, isComplete2)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
