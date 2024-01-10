import std/[
  algorithm,
  bitops,
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



proc step(grid: var seq[seq[bool]]): seq[seq[bool]] =
  let (rows, cols) = (grid.len, grid[0].len)
  result = newSeqWith(rows, newSeq[bool](cols))
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      var s = 0
      for dr in -1 .. 1:
        for dc in -1 .. 1:
          if (dr, dc) == (0, 0): continue
          let (nr, nc) = (r + dr, c + dc)
          if nr notin 0 ..< rows or nc notin 0 ..< cols: continue
          if grid[nr][nc]: s += 1
      if grid[r][c]:
        result[r][c] = s in [2, 3]
      else:
        result[r][c] = s == 3

proc countOn(grid: var seq[seq[bool]]): int =
  for row in grid:
    result += row.countIt(it)

proc parse(input: string): seq[seq[bool]] =
  for line in input.split("\n"):
    result.add line.mapIt(it == '#')

proc `$`(grid: var seq[seq[bool]]): string =
  grid.map(line => line.mapIt(if it: "#" else: ".").join & "\n").join

when defined(test):
  var grid = parse("""
.#.#.#
...##.
#....#
..#...
#.#..#
####..
""".strip)
  doAssert grid.countOn == 15
  grid = grid.step
  echo grid
  doAssert grid.countOn == 11
  grid = grid.step
  echo grid
  doAssert grid.countOn == 8
  grid = grid.step
  echo grid
  doAssert grid.countOn == 4
  grid = grid.step
  echo grid
  doAssert grid.countOn == 4

proc part1(input: string): int =
  var grid = input.parse
  for _ in 0 ..< 100:
    grid = grid.step
  grid.countOn

proc turnOnCorners(grid: var seq[seq[bool]]) =
  grid[0][0] = true
  grid[0][^1] = true
  grid[^1][0] = true
  grid[^1][^1] = true

proc step2(grid: var seq[seq[bool]]): seq[seq[bool]] =
  result = grid.step
  result.turnOnCorners

when defined(test):
  grid = parse("""
##.#.#
...##.
#....#
..#...
#.#..#
####.#
""".strip)
  doAssert grid.countOn == 17
  grid = grid.step2
  echo grid
  doAssert grid.countOn == 18
  grid = grid.step2
  echo grid
  doAssert grid.countOn == 18
  grid = grid.step2
  echo grid
  doAssert grid.countOn == 18
  grid = grid.step2
  echo grid
  doAssert grid.countOn == 14
  grid = grid.step2
  echo grid
  doAssert grid.countOn == 17

proc part2(input: string): int =
  var grid = input.parse
  grid.turnOnCorners
  for _ in 0 ..< 100:
    grid = grid.step2
  grid.countOn

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
