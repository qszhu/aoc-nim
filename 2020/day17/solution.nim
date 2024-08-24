import ../../lib/imports



type
  Coord = (int, int, int)
  Cubes = HashSet[Coord]

proc parse(input: string): Cubes =
  for r, row in input.split("\n").toSeq:
    for c, ch in row:
      if ch == '#':
        result.incl (r, c, 0)

when defined(test):
  let input = """
.#.
..#
###
""".strip
  block:
    doAssert input.parse.len == 5

iterator neighbors(p: Coord): Coord =
  let (x, y, z) = p
  for dx in -1 .. 1:
    for dy in -1 .. 1:
      for dz in -1 .. 1:
        if (dx, dy, dz) == (0, 0, 0): continue
        yield (x + dx, y + dy, z + dz)

proc countNeighbors(cubes: sink Cubes, p: Coord): int =
  for n in p.neighbors:
    if n in cubes: result += 1

proc step(cubes: sink Cubes): Cubes =
  result = cubes.toSeq.filterIt(cubes.countNeighbors(it) in [2, 3]).toHashSet
  var cands: Cubes
  for p in cubes:
    for n in p.neighbors:
      if n notin cubes:
        cands.incl n
  for p in cands:
    if cubes.countNeighbors(p) == 3:
      result.incl p

proc part1(input: string): int =
  var cubes = input.parse
  for _ in 0 ..< 6:
    cubes = cubes.step
  cubes.len

when defined(test):
  block:
    doAssert part1(input) == 112




type
  Coord2 = (int, int, int, int)
  Cubes2 = HashSet[Coord2]

proc parse2(input: string): Cubes2 =
  for r, row in input.split("\n").toSeq:
    for c, ch in row:
      if ch == '#':
        result.incl (r, c, 0, 0)

iterator neighbors2(p: Coord2): Coord2 =
  let (x, y, z, w) = p
  for dx in -1 .. 1:
    for dy in -1 .. 1:
      for dz in -1 .. 1:
        for dw in -1 .. 1:
          if (dx, dy, dz, dw) == (0, 0, 0, 0): continue
          yield (x + dx, y + dy, z + dz, w + dw)

proc countNeighbors2(cubes: sink Cubes2, p: Coord2): int =
  for n in p.neighbors2:
    if n in cubes: result += 1

proc step2(cubes: sink Cubes2): Cubes2 =
  result = cubes.toSeq.filterIt(cubes.countNeighbors2(it) in [2, 3]).toHashSet
  var cands: Cubes2
  for p in cubes:
    for n in p.neighbors2:
      if n notin cubes:
        cands.incl n
  for p in cands:
    if cubes.countNeighbors2(p) == 3:
      result.incl p

proc part2(input: string): int =
  var cubes = input.parse2
  for _ in 0 ..< 6:
    cubes = cubes.step2
  cubes.len

when defined(test):
  block:
    doAssert part2(input) == 848



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
