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



const OPEN = '.'
const TREE = '|'
const LUMBER = '#'

type
  Area = ref object
    grid: seq[string]
    rows, cols: int

proc parse(input: string): Area =
  result.new
  result.grid = input.split("\n")
  result.rows = result.grid.len
  result.cols = result.grid[0].len

when defined(test):
  let input = """
.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.
""".strip
  block:
    let area = input.parse
    doAssert area.rows == 10
    doAssert area.cols == 10

proc countNeighbors(area: Area, r, c: int, target: char): int =
  for dr in -1 .. 1:
    for dc in -1 .. 1:
      if (dr, dc) == (0, 0): continue
      let (nr, nc) = (r + dr, c + dc)
      if nr notin 0 ..< area.rows: continue
      if nc notin 0 ..< area.cols: continue
      if area.grid[nr][nc] == target: result += 1

proc step(area: Area): Area =
  result.new
  result.rows = area.rows
  result.cols = area.cols
  result.grid = area.grid
  for r in 0 ..< area.rows:
    for c in 0 ..< area.cols:
      if area.grid[r][c] == OPEN:
        if area.countNeighbors(r, c, TREE) >= 3:
          result.grid[r][c] = TREE
      elif area.grid[r][c] == TREE:
        if area.countNeighbors(r, c, LUMBER) >= 3:
          result.grid[r][c] = LUMBER
      elif area.grid[r][c] == LUMBER:
        if area.countNeighbors(r, c, LUMBER) >= 1 and area.countNeighbors(r, c, TREE) >= 1:
          discard
        else:
          result.grid[r][c] = OPEN

proc `$`(area: Area): string =
  area.grid.join "\n"

when defined(test):
  block:
    let area = input.parse
    doAssert $(area.step) == """
.......##.
......|###
.|..|...#.
..|#||...#
..##||.|#|
...#||||..
||...|||..
|||||.||.|
||||||||||
....||..|.
""".strip

proc count(area: Area, target: char): int =
  for r in 0 ..< area.rows:
    for c in 0 ..< area.cols:
      if area.grid[r][c] == target: result += 1

proc part1(input: string): int =
  var area = input.parse
  for _ in 0 ..< 10:
    area = area.step
  area.count(TREE) * area.count(LUMBER)

when defined(test):
  block:
    doAssert part1(input) == 1147



proc hash(area: Area): int =
  for r in 0 ..< area.rows:
    for c in 0 ..< area.cols:
      result = (result * 3 + ".|#".find(area.grid[r][c])) mod (1e9.int + 7)

proc part2(input: string): int =
  let N = 1e9.int

  var area = input.parse
  var hashes = newSeq[int]()
  var hashIdx = initTable[int, int]()
  var h = area.hash
  while h notin hashIdx:
    hashIdx[h] = hashes.len
    hashes.add h
    area = area.step
    h = area.hash

  let start = hashIdx[h]
  let cycleLen = hashes.len - start
  let n = start + (N - start) mod cycleLen

  area = input.parse
  for _ in 0 ..< n:
    area = area.step
  area.count(TREE) * area.count(LUMBER)

when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
