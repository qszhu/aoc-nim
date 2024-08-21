import ../../lib/imports



const FLOOR = '.'
const EMPTY = 'L'
const OCCUPIED = '#'

type
  Grid = seq[string]

proc countOccupiedAdj(grid: var Grid, r, c: int): int =
  let (rows, cols) = (grid.len, grid[0].len)
  for dr in -1 .. 1:
    for dc in -1 .. 1:
      if (dr, dc) == (0, 0): continue
      let (nr, nc) = (r + dr, c + dc)
      if nr notin 0 ..< rows: continue
      if nc notin 0 ..< cols: continue
      if grid[nr][nc] == OCCUPIED: result += 1

proc step(grid: var Grid): (bool, Grid) =
  let (rows, cols) = (grid.len, grid[0].len)
  var next = grid
  var changed = false
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      case grid[r][c]
      of EMPTY:
        if grid.countOccupiedAdj(r, c) == 0:
          next[r][c] = OCCUPIED
          changed = true
      of OCCUPIED:
        if grid.countOccupiedAdj(r, c) >= 4:
          next[r][c] = EMPTY
          changed = true
      else: discard
  (changed, next)

proc countOccupied(grid: sink Grid): int =
  grid.mapIt(it.count(OCCUPIED)).sum

proc parse(input: string): Grid =
  input.split("\n")

proc part1(input: string): int =
  var grid = input.parse
  while true:
    let (changed, next) = grid.step
    if not changed: break
    grid = next
  grid.countOccupied

when defined(test):
  let input = """
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
""".strip
  block:
    doAssert part1(input) == 37



proc countOccupiedAdj2(grid: var Grid, r, c: int): int =
  let (rows, cols) = (grid.len, grid[0].len)
  template inRange(r, c: int): bool =
    r in 0 ..< rows and c in 0 ..< cols
  for dr in -1 .. 1:
    for dc in -1 .. 1:
      if (dr, dc) == (0, 0): continue
      var (nr, nc) = (r + dr, c + dc)
      while inRange(nr, nc) and grid[nr][nc] == FLOOR:
        (nr, nc) = (nr + dr, nc + dc)
      if inRange(nr, nc) and grid[nr][nc] == OCCUPIED:
        result += 1

proc step2(grid: var Grid): (bool, Grid) =
  let (rows, cols) = (grid.len, grid[0].len)
  var next = grid
  var changed = false
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      case grid[r][c]
      of EMPTY:
        if grid.countOccupiedAdj2(r, c) == 0:
          next[r][c] = OCCUPIED
          changed = true
      of OCCUPIED:
        if grid.countOccupiedAdj2(r, c) >= 5:
          next[r][c] = EMPTY
          changed = true
      else: discard
  (changed, next)

proc part2(input: string): int =
  var grid = input.parse
  while true:
    let (changed, next) = grid.step2
    if not changed: break
    grid = next
  grid.countOccupied

when defined(test):
  block:
    doAssert part2(input) == 26



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
