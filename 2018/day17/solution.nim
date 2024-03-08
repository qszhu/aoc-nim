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



type
  Clay = tuple[x1, x2, y1, y2: int]

proc parseLine(line: string): Clay =
  proc parseRange(s: string): (int, int) =
    if s =~ re"^(\d+)$":
      let x = matches[0].parseInt
      return (x, x)
    if s =~ re"^(\d+)..(\d+)$":
      return (matches[0].parseInt, matches[1].parseInt)
    raise newException(ValueError, "parse error: " & s)

  var x1, x2, y1, y2: int
  var parts = line.split(", ")
  if parts[0].startsWith("y="):
    swap(parts[0], parts[1])
  (x1, x2) = parseRange(parts[0][2 .. ^1])
  (y1, y2) = parseRange(parts[1][2 .. ^1])
  (x1, x2, y1, y2)

proc parse(input: string): seq[Clay] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504
""".strip
  block:
    doAssert input.parse == @[
      (495, 495, 2, 7),
      (495, 501, 7, 7),
      (501, 501, 3, 7),
      (498, 498, 2, 4),
      (506, 506, 1, 2),
      (498, 498, 10, 13),
      (504, 504, 10, 13),
      (498, 504, 13, 13),
    ]

const EMPTY = 0
const WATER_DROP = 1
const WALL = 2
const WATER = 3

type
  Grid = object
    grid: seq[seq[int]]
    sx, sy: int

proc `$`(self: Grid): string =
  self.grid.map(
    row => row.mapIt(
      case it:
      of EMPTY: '.'
      of WALL: '#'
      of WATER: '~'
      of WATER_DROP: '|'
      else: '?'
    ).join
  ).join("\n")

proc buildGrid(clays: seq[Clay]): Grid =
  var minX, minY = int.high
  var maxX, maxY = int.low
  for (x1, x2, y1, y2) in clays:
    minX = minX.min x1 - 1
    maxX = maxX.max x2 + 1
    minY = minY.min y1 - 1
    maxY = maxY.max y2
  let (cols, rows) = (maxX - minX + 1, maxY - minY + 1)
  var grid = newSeqWith(rows, newSeq[int](cols))
  for (x1, x2, y1, y2) in clays:
    for x in (x1 - minX) .. (x2 - minX):
      for y in (y1 - minY) .. (y2 - minY):
        grid[y][x] = WALL
  let (sy, sx) = (0, 500 - minX)
  grid[sy][sx] = WATER_DROP
  Grid(grid: grid, sx: sx, sy: sy)

when defined(test):
  block:
    let grid = input.parse.buildGrid
    # echo grid

proc flow(grid: Grid): Grid =
  let (sx, sy) = (grid.sx, grid.sy)
  var grid = grid.grid
  let (rows, cols) = (grid.len, grid[0].len)

  proc drop(y, x: int): bool =
    if grid[y][x] == WATER_DROP: return true
    if grid[y][x] != EMPTY: return false
    grid[y][x] = WATER_DROP
    if y + 1 >= rows:
      return true
    if drop(y + 1, x):
      return true

    var lx = x - 1
    var lf = false
    while grid[y][lx] < 2:
      grid[y][lx] = WATER_DROP
      if grid[y + 1][lx] < 2:
        lf = true
        break
      lx -= 1

    var rx = x + 1
    var rf = false
    while grid[y][rx] < 2:
      grid[y][rx] = WATER_DROP
      if grid[y + 1][rx] < 2:
        rf = true
        break
      rx += 1

    result = lf or rf
    if not result:
      for x in lx + 1 ..< rx:
        grid[y][x] = WATER
    else:
      let l = drop(y + 1, lx)
      let r = drop(y + 1, rx)
      result = l or r
      if not result:
        for x in lx + 1 ..< rx:
          grid[y][x] = EMPTY
        return drop(y, x)

  discard drop(sy + 1, sx)
  Grid(grid: grid, sx: sx, sy: sy)

proc count(grid: Grid, target: int): int =
  let grid = grid.grid
  let (rows, cols) = (grid.len, grid[0].len)
  for r in 1 ..< rows:
    for c in 0 ..< cols:
      if grid[r][c] == target:
        result += 1

proc part1(input: string): int =
  let grid = input.parse.buildGrid.flow
  # echo grid
  grid.count(WATER) + grid.count(WATER_DROP)

when defined(test):
  block:
    doAssert part1(input) == 57



proc part2(input: string): int =
  let grid = input.parse.buildGrid.flow
  grid.count(WATER)

when defined(test):
  block:
    doAssert part2(input) == 29


when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
