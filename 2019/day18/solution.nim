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
  os,
  rdstdin,
  re,
  sequtils,
  sets,
  streams,
  strformat,
  strutils,
  tables,
  threadpool,
  sugar,
]



const EMPTY = '.'
const WALL = '#'
const ENTRANCE = '@'

proc addKey(key: int, ch: char): int {.inline.} =
  result = key
  result.setBit(ch.ord - 'a'.ord)

proc canOpen(key: int, ch: char): bool {.inline.} =
  key.testBit(ch.ord - 'A'.ord)

proc isKey(ch: char): bool {.inline.} =
  ch.isLowerAscii

proc isDoor(ch: char): bool {.inline.} =
  ch.isUpperAscii

const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

type
  Grid = seq[string]

proc gridInfo(grid: Grid): (int, int, int) =
  let (rows, cols) = (grid.len, grid[0].len)
  var sr, sc = -1
  var keys = 0
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      if grid[r][c] == ENTRANCE:
        (sr, sc) = (r, c)
      elif grid[r][c].isKey:
        keys = keys.addKey(grid[r][c])
  (sr, sc, keys)

proc part1(input: string): int =
  let grid = input.split("\n")
  let (rows, cols) = (grid.len, grid[0].len)
  let (sr, sc, targetKeys) = grid.gridInfo
  var q = @[(sr, sc, 0)]
  var visited = q.toHashSet
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c, keys) in q:
      if keys == targetKeys: return steps
      for (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows or nc notin 0 ..< cols: continue
        let cell = grid[nr][nc]
        if cell == WALL: continue
        if cell.isDoor and not keys.canOpen(cell): continue
        var nextKeys = keys
        if cell.isKey:
          nextKeys = keys.addKey(cell)
        if (nr, nc, keys) in visited: continue
        visited.incl (nr, nc, nextKeys)
        next.add (nr, nc, nextKeys)
    q = next
    if q.len > 0: steps += 1

when defined(test):
  block:
    let input = """
#########
#b.A.@.a#
#########
""".strip
    doAssert part1(input) == 8

  block:
    let input = """
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
""".strip
    doAssert part1(input) == 86

  block:
    let input = """
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################
""".strip
    doAssert part1(input) == 132

  block:
    let input = """
#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################
""".strip
    doAssert part1(input) == 136

  block:
    let input = """
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################
""".strip
    doAssert part1(input) == 81



proc changeGrid(grid: var Grid, sr, sc: int) =
  for dr in -1 .. 1:
    for dc in -1 .. 1:
      grid[sr + dr][sc + dc] = WALL
  grid[sr - 1][sc - 1] = ENTRANCE
  grid[sr - 1][sc + 1] = ENTRANCE
  grid[sr + 1][sc - 1] = ENTRANCE
  grid[sr + 1][sc + 1] = ENTRANCE

iterator nextMove(grid: Grid, r, c: int): (int, int, int) =
  let (rows, cols) = (grid.len, grid[0].len)
  var q = @[(r, c)]
  var visited = q.toHashSet
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      for (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows or nc notin 0 ..< cols: continue
        if grid[nr][nc] == WALL: continue
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        if grid[nr][nc] != EMPTY:
          yield (nr, nc, steps + 1)
        else:
          next.add (nr, nc)
    q = next
    if q.len > 0: steps += 1

type
  State = tuple[steps: int, robots: array[4, (int, int)], keys: int]

proc `<`(a, b: State): bool =
  a.steps < b.steps

proc part2(input: string): int =
  var grid = input.split("\n")
  let (sr, sc, targetKeys) = grid.gridInfo
  changeGrid(grid, sr, sc)

  let robots = [(sr-1,sc-1),(sr-1, sc+1),(sr+1,sc-1),(sr+1,sc+1)]
  var q = @[(0, robots, 0)].toHeapQueue
  var visited = @[(robots, 0)].toHashSet
  while q.len > 0:
    let (steps, robots, keys) = q.pop
    if keys == targetKeys: return steps
    for i, (r, c) in robots:
      for (nr, nc, s) in nextMove(grid, r, c):
        var nextRobots = robots
        let cell = grid[nr][nc]
        if cell.isDoor and not keys.canOpen(cell): continue
        var nextKeys = keys
        if cell.isKey:
          nextKeys = keys.addKey(cell)
        nextRobots[i] = (nr, nc)
        if (nextRobots, nextKeys) in visited: continue
        visited.incl (nextRobots, nextKeys)
        q.push (steps + s, nextRobots, nextKeys)

when defined(test):
  block:
    let input = """
#######
#a.#Cd#
##...##
##.@.##
##...##
#cB#Ab#
#######
""".strip
    doAssert part2(input) == 8

  block:
    let input = """
###############
#d.ABC.#.....a#
######...######
######.@.######
######...######
#b.....#.....c#
###############
""".strip
    doAssert part2(input) == 24

  block:
    let input = """
#############
#DcBa.#.GhKl#
#.###...#I###
#e#d#.@.#j#k#
###C#...###J#
#fEbA.#.FgHi#
#############
""".strip
    doAssert part2(input) == 32

  block:
    let input = """
#############
#g#f.D#..h#l#
#F###e#E###.#
#dCba...BcIJ#
#####.@.#####
#nK.L...G...#
#M###N#H###.#
#o#m..#i#jk.#
#############
""".strip
    doAssert part2(input) == 72



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
