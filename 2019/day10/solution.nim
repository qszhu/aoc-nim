import ../../lib/imports



const EMPTY = '.'

type
  Grid = seq[string]

proc parse(input: string): Grid =
  input.split("\n")

proc getAngle(dy, dx: int): float =
  let g = gcd(dx, dy)
  arctan2((dy div g).float, (dx div g).float)

proc scan(g: Grid, r0, c0: int): Table[float, seq[(int, int)]] =
  let (rows, cols) = (g.len, g[0].len)
  result = initTable[float, seq[(int, int)]]()
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      if (r, c) == (r0, c0): continue
      if g[r][c] == EMPTY: continue
      let angle = getAngle(r - r0, c - c0)
      if angle notin result:
        result[angle] = newSeq[(int, int)]()
      result[angle].add (r, c)

proc countLines(g: Grid, r, c: int): int =
  g.scan(r, c).len

when defined(test):
  block:
    let input = """
.#..#
.....
#####
....#
...##
""".strip
    let g = input.parse
    let res = """
.7..7
.....
67775
....7
...87
""".strip.split("\n")
    for r in 0 ..< g.len:
      for c in 0 ..< g[0].len:
        if g[r][c] == EMPTY: continue
        doAssert g.countLines(r, c) == res[r][c].ord - '0'.ord

proc findTarget(g: Grid): (int, (int, int)) =
  var (tr, tc) = (-1, -1)
  var maxLines = 0
  for r in 0 ..< g.len:
    for c in 0 ..< g[0].len:
      if g[r][c] == EMPTY: continue
      let lines = g.countLines(r, c)
      if maxLines < lines:
        maxLines = lines
        (tr, tc) = (r, c)
  (maxLines, (tr, tc))

proc part1(input: string): int =
  let g = input.parse
  let (maxLines, _) = g.findTarget
  maxLines

when defined(test):
  block:
    let input = """
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
""".strip
    doAssert input.parse.findTarget == (33, (8, 5))
  block:
    let input = """
#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
""".strip
    doAssert input.parse.findTarget == (35, (2, 1))
  block:
    let input = """
.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..
""".strip
    doAssert input.parse.findTarget == (41, (3, 6))
  let input = """
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
""".strip
  block:
    doAssert input.parse.findTarget == (210, (13, 11))



proc dist(r1, c1, r2, c2: int): float =
  let dr = (r1 - r2).float
  let dc = (c1 - c2).float
  (dr * dr + dc * dc).sqrt

proc vaporList(g: Grid): seq[(int, int)] =
  let (_, (tr, tc)) = g.findTarget
  let scans = g.scan(tr, tc)
  var angles = scans.keys.toSeq.sorted

  let i = angles.lowerBound(-PI / 2)
  angles = angles[i .. ^1] & angles[0 ..< i]

  var sortedScans = initTable[float, seq[(int, int)]]()
  for a in angles:
    sortedScans[a] = scans[a].sortedByIt(-dist(tr, tc, it[0], it[1]))

  while true:
    var hasMore = false
    for a in angles:
      if sortedScans[a].len == 0: continue
      hasMore = true
      result.add sortedScans[a].pop
    if not hasMore: break



when defined(test):
  block:
    let input = """
.#....#####...#..
##...##.#####..##
##...#...#.#####.
..#.....X...###..
..#.#.....#....##
""".strip
    let vl = input.parse.vaporList
#[
  00000000001111111
  01234567890123456
-------------------
0|.#....###24...#..
1|##...##.13#67..9#
2|##...#...5.8####.
3|..#.....X...###..
4|..#.#.....#....##
]#
    doAssert vl[0 .. 8] == @[
      (1, 8), (0, 9), (1, 9),
      (0, 10), (2, 9), (1, 11),
      (1, 12), (2, 11), (1, 15)
    ]
#[
  00000000001111111
  01234567890123456
-------------------
0|.#....###.....#..
1|##...##...#.....#
2|##...#......1234.
3|..#.....X...5##..
4|..#.9.....8....76
]#
    doAssert vl[9 .. 17] == @[
      (2, 12), (2, 13), (2, 14),
      (2, 15), (3, 12), (4, 16),
      (4, 15), (4, 10), (4, 4)
    ]
#[
  00000000001111111
  01234567890123456
-------------------
0|.8....###.....#..
1|56...9#...#.....#
2|34...7...........
3|..2.....X....##..
4|..1..............
]#
    doAssert vl[18 .. 26] == @[
      (4, 2), (3, 2), (2, 0),
      (2, 1), (1, 0), (1, 1),
      (2, 5), (0, 1), (1, 5)
    ]
#[
  00000000001111111
  01234567890123456
-------------------
0|......234.....6..
1|......1...5.....7
2|.................
3|........X....89..
4|.................
]#
    doAssert vl[27 .. 35] == @[
      (1, 6), (0, 6), (0, 7),
      (0, 8), (1, 10), (0, 14),
      (1, 16), (3, 13), (3, 14)
    ]

  block:
    let vl = input.parse.vaporList
    doAssert vl[0] == (12, 11)
    doAssert vl[1] == (1, 12)
    doAssert vl[2] == (2, 12)
    doAssert vl[9] == (8, 12)
    doAssert vl[19] == (0, 16)
    doAssert vl[49] == (9, 16)
    doAssert vl[99] == (16, 10)
    doAssert vl[198] == (6, 9)
    doAssert vl[199] == (2, 8)
    doAssert vl[200] == (9, 10)
    doAssert vl[298] == (1, 11)

proc part2(input: string): int =
  let vl = input.parse.vaporList
  let (r, c) = vl[199]
  c * 100 + r



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
