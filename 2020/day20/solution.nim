import ../../lib/imports



type
  Tile = ref object
    id: int
    grid: seq[string]
    features: array[8, array[4, int]]
    orient: int

proc calcFeatures(self: Tile)
proc parseTile(s: string): Tile =
  let lines = s.split("\n")
  result.new
  if lines[0] =~ re"Tile (\d+):":
    result.id = matches[0].parseInt
  else:
    raise newException(ValueError, "parse error: " & lines[0])
  result.grid = lines[1 .. ^1]
  result.calcFeatures

proc parse(input: string): seq[Tile] =
  input.split("\n\n").mapIt(it.parseTile)

when defined(test):
  let input = """
Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...
""".strip
  block:
    let tiles = input.parse
    doAssert tiles[0].id == 2311
    doAssert tiles[0].grid.len == 10
    doAssert tiles[0].grid[0].len == 10

proc flipV(grid: sink seq[string]): seq[string] =
  let (rows, cols) = (grid.len, grid[0].len)
  result = newSeqWith(rows, newString(cols))
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      result[r][c] = grid[r][cols - 1 - c]

when defined(test):
  block:
    let grid = """
#####
#....
#####
#....
#....
""".strip.split("\n")
    doAssert grid.flipV.join("\n") == """
#####
....#
#####
....#
....#
""".strip

proc rotateCCW(grid: sink seq[string]): seq[string] =
  let (rows, cols) = (grid.len, grid[0].len)
  result = newSeqWith(cols, newString(rows))
  for c in countdown(cols - 1, 0):
    for r in 0 ..< rows:
      result[cols - 1 - c][r] = grid[r][c]

when defined(test):
  block:
    let grid = """
#####
#....
#####
#....
#....
""".strip.split("\n")
    doAssert grid.rotateCCW.join("\n") == """
#.#..
#.#..
#.#..
#.#..
#####
""".strip

proc getFeature(a: string): int =
  for ch in a:
    result = result shl 1
    if ch == '#': result += 1

proc calcFeatures(grid: sink seq[string]): array[4, int] =
  let N = grid.len
  let top = grid[0]
  let bottom = grid[N - 1]
  let left = (0 ..< N).toSeq.mapIt(grid[it][0]).join
  let right = (0 ..< N).toSeq.mapIt(grid[it][N - 1]).join
  [
    top.getFeature,
    right.getFeature,
    bottom.getFeature,
    left.getFeature,
  ]

proc calcFeatures(self: Tile) =
  var grid = self.grid
  for i in 0 ..< 4:
    self.features[i] = grid.calcFeatures
    grid = grid.rotateCCW
  grid = self.grid.flipV
  for i in 0 ..< 4:
    self.features[4 + i] = grid.calcFeatures
    grid = grid.rotateCCW

# TOP, RIGHT, BOTTOM, LEFT
const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

proc arrange(tiles: seq[Tile]): seq[seq[(int, int)]] =
  # (feature, dir): [(idx, orient)]]
  var featuresMap = initTable[(int, int), seq[(int, int)]]()
  for idx, tile in tiles:
    for orient, features in tile.features:
      for dir, f in features:
        if (f, dir) notin featuresMap:
          featuresMap[(f, dir)] = newSeq[(int, int)]()
        featuresMap[(f, dir)].add (idx, orient)

  # (row, col): (idx, orient)
  var res = initTable[(int, int), (int, int)]()
  res[(0, 0)] = (0, 0)
  while res.len < tiles.len:
    for (r, c) in res.keys.toSeq:
      let (idx, orient) = res[(r, c)]
      for dir, (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if (nr, nc) in res: continue
        let f = tiles[idx].features[orient][dir]
        let rDir = (dir + 2) mod 4
        if (f, rDir) in featuresMap:
          let cands = featuresMap[(f, rDir)].filterIt(it[0] != idx)
          if cands.len == 1: res[(nr, nc)] = cands[0]

  let d = tiles.len.float.sqrt.int
  result = newSeqWith(d, newSeq[(int, int)](d))
  var mr, mc = int.high
  for (r, c) in res.keys:
    mr = mr.min r
    mc = mc.min c
  for (r, c) in res.keys:
    result[r - mr][c - mc] = res[(r, c)]

proc part1(input: string): int =
  let tiles = input.parse
  let arr = tiles.arrange
  proc getId(idx: int): int =
    tiles[idx].id
  arr[0][0][0].getId * arr[0][^1][0].getId * arr[^1][0][0].getId * arr[^1][^1][0].getId

when defined(test):
  block:
    doAssert part1(input) == 20899048083289



proc transform(grid: sink seq[string], orient: int): seq[string] =
  result = grid
  if orient > 3: result = result.flipV
  for _ in 0 ..< orient mod 4:
    result = result.rotateCCW

proc merge(tiles: seq[Tile]): seq[string] =
  let arr = tiles.arrange
  let D = tiles[0].grid.len
  let rows = arr.len * (D - 2)
  result = newSeqWith(rows, ".".repeat(rows))

  for i in 0 ..< arr.len:
    for j in 0 ..< arr[i].len:
      let (idx, orient) = arr[i][j]
      let grid = tiles[idx].grid.transform(orient)
      for r in 1 ..< D - 1:
        for c in 1 ..< D - 1:
          result[i * (D - 2) + r - 1][j * (D - 2) + c - 1] = grid[r][c]

when defined(test):
  block:
    let tiles = input.parse.merge
    doAssert tiles.flipV.rotateCCW.rotateCCW.join("\n") == """
.#.#..#.##...#.##..#####
###....#.#....#..#......
##.##.###.#.#..######...
###.#####...#.#####.#..#
##.#....#.##.####...#.##
...########.#....#####.#
....#..#...##..#.#.###..
.####...#..#.....#......
#..#.##..#..###.#.##....
#.####..#.####.#.#.###..
###.#.#...#.######.#..##
#.####....##..########.#
##..##.#...#...#.#.#.#..
...#..#..#.#.##..###.###
.#.#....#.##.#...###.##.
###.#...#..#.##.######..
.#.#.###.##.##.#..#.##..
.####.###.#...###.#..#.#
..#.#..#..#.#.#.####.###
#..####...#.#.#.###.###.
#####..#####...###....##
#.##..#..#...#..####...#
.#.###..##..##..####.##.
...###...##...#...#..###
""".strip

iterator matches(grid: seq[string], pat: seq[string]): (int, int) =
  let (rows, cols) = (grid.len, grid[0].len)
  let (pRows, pCols) = (pat.len, pat[0].len)
  proc find(r, c: int): bool =
    result = true
    for r1 in 0 ..< pRows:
      for c1 in  0 ..< pCols:
        if pat[r1][c1] == '#' and grid[r + r1][c + c1] != '#': return false
  for r in 0 .. rows - pRows:
    for c in 0 .. cols - pCols:
      if find(r, c): yield (r, c)

const pat = """
                  # 
#    ##    ##    ###
 #  #  #  #  #  #   """.split("\n")

when defined(test):
  block:
    var grid = input.parse.merge
    for _ in 0 ..< 3: grid = grid.rotateCCW
    doAssert grid.matches(pat).toSeq == @[(2, 2), (16, 1)]

proc numMatches(grid: sink seq[string]): int =
  var grid = grid
  for i in 0 ..< 4:
    result = grid.matches(pat).toSeq.len
    if result > 0: return
    grid = grid.rotateCCW
  grid = grid.flipV
  for i in 0 ..< 4:
    result = grid.matches(pat).toSeq.len
    if result > 0: return
    grid = grid.rotateCCW

proc count(grid: seq[string]): int =
  grid.mapIt(it.count('#')).sum

proc part2(input: string): int =
  let grid = input.parse.merge
  grid.count - grid.numMatches * pat.count

when defined(test):
  block:
    doAssert part2(input) == 273



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
