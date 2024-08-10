import ../../lib/imports
import ../day9/programs



const DPOS = [(0, 0), (-1, 0), (1, 0), (0, -1), (0, 1)]

type
  Movement {.pure.} = enum
    North = 1
    South = 2
    West = 3
    East = 4

  Tile {.pure.} = enum
    Wall
    Empty
    Target
    Oxygen

const REV = [0, 2, 1, 4, 3]

type
  Controller = ref object
    mapping: Table[(int, int), Tile]
    r, c: int
    path: seq[(Movement, bool)]
    p: Program

proc newController(p: Program): Controller =
  result.new
  result.p = p
  result.mapping[(result.r, result.c)] = Tile.Empty

proc run(self: Controller) =
  for mov in Movement:
    self.path.add (mov, false)
  while self.path.len > 0:
    let (mov, visited) = self.path[^1]
    if visited:
      let rMov = REV[mov.ord]
      queues[0].addLast rMov
      discard self.p.stepOver
      doAssert queues[1].popFirst != Tile.Wall.ord
      let (dr, dc) = DPOS[rMov]
      self.r += dr
      self.c += dc
      discard self.path.pop
      continue

    self.path[^1] = (mov, true)
    let (dr, dc) = DPOS[mov.ord]
    let (nr, nc) = (self.r + dr, self.c + dc)
    if (nr, nc) in self.mapping:
      discard self.path.pop
      continue

    queues[0].addLast mov.ord
    discard self.p.stepOver
    let tile = queues[1].popFirst.Tile
    self.mapping[(nr, nc)] = tile
    if tile == Tile.Wall:
      discard self.path.pop
      continue

    self.r = nr
    self.c = nc
    for mov in Movement:
      self.path.add (mov, false)

type
  Grid = ref object
    tiles: seq[seq[Tile]]
    sr, sc: int

proc makeGrid(self: Controller): Grid =
  var minR, minC = int.high
  var maxR, maxC = int.low
  for (r, c) in self.mapping.keys:
    minR = minR.min r
    maxR = maxR.max r
    minC = minC.min c
    maxC = maxC.max c
  let rows = maxR - minR + 1
  let cols = maxC - minC + 1
  var tiles = newSeqWith(rows, newSeq[Tile](cols))
  for (r, c) in self.mapping.keys:
    tiles[r - minR][c - minC] = self.mapping[(r, c)]
  result.new
  result.tiles = tiles
  result.sr = -minR
  result.sc = -minC

proc `$`(self: Grid): string {.inline.} =
  self.tiles.map(row => row.mapIt(if it == Tile.Wall: '#' elif it == Tile.Empty: '.' else: 'X').join).join("\n")

proc mapping(input: string): Grid =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  let c = newController(p)
  c.run
  c.makeGrid

proc bfs(grid: Grid): int =
  let (tiles, sr, sc) = (grid.tiles, grid.sr, grid.sc)
  let (rows, cols) = (tiles.len,tiles[0].len)
  var q = @[(sr, sc)]
  var visited = q.toHashSet
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      for mov in Movement:
        let (dr, dc) = DPOS[mov.ord]
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows: continue
        if nc notin 0 ..< cols: continue
        if tiles[nr][nc] == Tile.Wall: continue
        if tiles[nr][nc] == Tile.Target: return steps + 1
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        next.add (nr, nc)
    if next.len > 0: steps += 1
    q = next

proc part1(input: string): int =
  let grid = mapping(input)
  bfs(grid)



proc bfs2(grid: Grid): int =
  var tiles = grid.tiles
  let (rows, cols) = (tiles.len, tiles[0].len)
  var sr, sc = -1
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      if tiles[r][c] == Tile.Target:
        (sr, sc) = (r, c)
  var q = @[(sr, sc)]
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      for mov in Movement:
        let (dr, dc) = DPOS[mov.ord]
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows: continue
        if nc notin 0 ..< cols: continue
        if tiles[nr][nc] != Tile.Empty: continue
        tiles[nr][nc] = Tile.Oxygen
        next.add (nr, nc)
    if next.len > 0: steps += 1
    q = next
  steps

when defined(test):
  block:
    var grid = Grid.new
    grid.tiles = @[
      @[0,0,0,0,0,0].mapIt(it.Tile),
      @[0,1,1,0,0,0].mapIt(it.Tile),
      @[0,1,0,1,1,0].mapIt(it.Tile),
      @[0,1,2,1,0,0].mapIt(it.Tile),
      @[0,0,0,0,0,0].mapIt(it.Tile),
    ]
    grid.sr = 3
    grid.sc = 2
    doAssert bfs2(grid) == 4

proc part2(input: string): int =
  let grid = mapping(input)
  bfs2(grid)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
