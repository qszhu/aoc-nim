import ../../lib/imports



iterator hexDirs(s: string): string =
  var i = 0
  while i < s.len:
    if s[i] == 'n':
      if i + 1 < s.len and s[i + 1] == 'e':
        yield "ne"
        i += 2
      elif i + 1 < s.len and s[i + 1] == 'w':
        yield "nw"
        i += 2
    elif s[i] == 's':
      if i + 1 < s.len and s[i + 1] == 'e':
        yield "se"
        i += 2
      elif i + 1 < s.len and s[i + 1] == 'w':
        yield "sw"
        i += 2
    else:
      yield $s[i]
      i += 1

when defined(test):
  block:
    doAssert "esenee".hexDirs.toSeq == @["e", "se", "ne", "e"]

type
  Pos = (int, int, int)

proc `+`(a, b: Pos): Pos =
  (a[0] + b[0], a[1] + b[1], a[2] + b[2])

const dPos = [
  (1, 0, -1),
  (0, 1, -1),
  (-1, 1, 0),
  (-1, 0, 1),
  (0, -1, 1),
  (1, -1, 0),
]

const dirs = ["e", "se", "sw", "w", "nw", "ne"]

proc move(a: Pos, d: string): Pos =
  a + dPos[dirs.find(d)]

proc parse(input: string): HashSet[Pos] =
  for line in input.split("\n"):
    var p = (0, 0, 0)
    for dir in line.hexDirs:
      p = p.move(dir)
    if p notin result:
      result.incl p
    else:
      result.excl p

proc part1(input: string): int =
  let tiles = input.parse
  tiles.len

when defined(test):
  let input = """
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
""".strip
  block:
    doAssert part1(input) == 10



proc step(tiles: HashSet[Pos]): HashSet[Pos] =
  for p in tiles:
    var blacks = 0
    for d in dirs:
      if p.move(d) in tiles: blacks += 1
    if not (blacks == 0 or blacks > 2): result.incl p

  var cands = initHashSet[Pos]()
  for p in tiles:
    for d in dirs:
      cands.incl p.move(d)
  for p in cands:
    var blacks = 0
    for d in dirs:
      if p.move(d) in tiles: blacks += 1
    if blacks == 2: result.incl p

when defined(test):
  block:
    var tiles = input.parse
    var expected = @[15, 12, 25, 14, 23, 28, 41, 37, 49, 37]
    for i in 1 .. 10:
      tiles = tiles.step
      doAssert tiles.len == expected[i - 1]
    expected = @[132, 259, 406, 566, 788, 1106, 1373, 1844, 2208]
    for i in 11 .. 100:
      tiles = tiles.step
      if i mod 10 == 0:
        doAssert tiles.len == expected[i div 10 - 2]

proc part2(input: string): int =
  var tiles = input.parse
  for _ in 1 .. 100:
    tiles = tiles.step
  tiles.len



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
