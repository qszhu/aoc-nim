import ../../lib/imports



type
  Tile = char

  Keys = int

const EMPTY = '.'
const WALL = '#'
const ENTRANCE = '@'

proc isKey(ch: Tile): bool {.inline.} =
  ch.isLowerAscii

proc isDoor(ch: Tile): bool {.inline.} =
  ch.isUpperAscii

proc addKey(self: Keys, key: Tile): Keys {.inline.} =
  assert key.isKey
  result = self
  result.setBit(key.ord - 'a'.ord)

proc canOpen(self: Keys, door: Tile): bool {.inline.} =
  assert door.isDoor
  self.testBit(door.ord - 'A'.ord)

type
  Grid = ref object
    tiles: seq[string]
    rows, cols: int
    sr, sc: int
    keys: int

proc parse(input: string): Grid =
  result.new
  result.tiles = input.split("\n")
  result.rows = result.tiles.len
  result.cols = result.tiles[0].len
  for r in 0 ..< result.rows:
    for c in 0 ..< result.cols:
      let tile = result.tiles[r][c]
      if tile == ENTRANCE:
        result.sr = r
        result.sc = c
      elif tile.isKey:
        result.keys = result.keys.addKey tile

when defined(test):
  let input = """
#########
#b.A.@.a#
#########
""".strip
  block:
    let grid = input.parse
    doAssert (grid.rows, grid.cols) == (3, 9)
    doAssert (grid.sr, grid.sc) == (1, 5)
    doAssert grid.keys == 0b11

const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

proc part1(input: string): int =
  let grid = input.parse
  let (rows, cols) = (grid.rows, grid.cols)
  let (sr, sc, targetKeys) = (grid.sr, grid.sc, grid.keys)
  var q = @[(sr, sc, 0)]
  var visited = q.toHashSet
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c, keys) in q:
      if keys == targetKeys: return steps
      for (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows: continue
        if nc notin 0 ..< cols: continue
        let tile = grid.tiles[nr][nc]
        if tile == WALL: continue
        if tile.isDoor and not keys.canOpen(tile): continue
        var nextKeys = keys
        if tile.isKey: nextKeys = nextKeys.addKey(tile)
        if (nr, nc, nextkeys) in visited: continue
        visited.incl (nr, nc, nextKeys)
        next.add (nr, nc, nextKeys)
    if next.len > 0: steps += 1
    q = next

when defined(test):
  block:
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



proc changeGrid(grid: Grid) =
  let (sr, sc) = (grid.sr, grid.sc)
  for dr in -1 .. 1:
    for dc in -1 .. 1:
      grid.tiles[sr + dr][sc + dc] = WALL
  grid.tiles[sr - 1][sc - 1] = ENTRANCE
  grid.tiles[sr - 1][sc + 1] = ENTRANCE
  grid.tiles[sr + 1][sc - 1] = ENTRANCE
  grid.tiles[sr + 1][sc + 1] = ENTRANCE

when defined(test):
  let input1 = """
#######
#a.#Cd#
##...##
##.@.##
##...##
#cB#Ab#
#######
""".strip
  block:
    var grid = input1.parse
    grid.changeGrid
    doAssert grid.tiles.join("\n") == """
#######
#a.#Cd#
##@#@##
#######
##@#@##
#cB#Ab#
#######
""".strip

iterator nextMove(grid: Grid, r, c: int): (int, int, int) =
  let (rows, cols) = (grid.rows, grid.cols)
  var q = @[(r, c)]
  var visited = q.toHashSet
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      for (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows: continue
        if nc notin 0 ..< cols: continue
        let tile = grid.tiles[nr][nc]
        if tile == WALL: continue
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        if tile != EMPTY: yield (nr, nc, steps + 1)
        else: next.add (nr, nc)
    if next.len > 0: steps += 1
    q = next

type
  State = tuple[steps: int, robots: array[4, (int, int)], keys: Keys]

proc `<`(a, b: State): bool =
  a.steps < b.steps

proc part2(input: string): int =
  var grid = input.parse
  grid.changeGrid
  let (sr, sc, targetKeys) = (grid.sr, grid.sc, grid.keys)
  let robots = [
    (sr - 1, sc - 1),
    (sr - 1, sc + 1),
    (sr + 1, sc - 1),
    (sr + 1, sc + 1),
  ]
  var q = @[(0, robots, 0)].toHeapQueue
  var visited = @[(robots, 0)].toHashSet
  while q.len > 0:
    let (steps, robots, keys) = q.pop
    stderr.write &"\r{steps}     "
    if keys == targetKeys: return steps
    for i, (r, c) in robots:
      for (nr, nc, steps1) in nextMove(grid, r, c):
        var nextRobots = robots
        let tile = grid.tiles[nr][nc]
        if tile.isDoor and not keys.canOpen(tile): continue
        var nextKeys = keys
        if tile.isKey: nextKeys = nextKeys.addKey(tile)
        nextRobots[i] = (nr, nc)
        if (nextRobots, nextKeys) in visited: continue
        visited.incl (nextRobots, nextKeys)
        q.push (steps + steps1, nextRobots, nextKeys)

when defined(test):
  block:
    doAssert part2(input1) == 8

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
