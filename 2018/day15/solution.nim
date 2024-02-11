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

import ../../lib/grid



const WALL = '#'
const EMPTY = '.'
const GOBLIN = 'G'
const ELF = 'E'

type
  UnitType = enum
    ElfUnit
    GoblinUnit

  Unit = tuple[r, c, hp, atk: int, t: UnitType]

  Cave = ref object
    grid: seq[string]
    rows, cols: int
    units: seq[Unit]

proc `<`(a, b: Unit): bool =
  if a.r != b.r: a.r < b.r
  else: a.c < b.c

const INIT_HP = 200
const INIT_ATK = 3

proc parse(input: string): Cave =
  result.new
  result.grid = input.split("\n")
  result.rows = result.grid.len
  result.cols = result.grid[0].len
  result.units = newSeq[Unit]()
  for r in 0 ..< result.rows:
    for c in 0 ..< result.cols:
      if result.grid[r][c] == GOBLIN:
        result.units.add (r: r, c: c, hp: INIT_HP, atk: INIT_ATK, t: GoblinUnit)
        result.grid[r][c] = EMPTY
      elif result.grid[r][c] == ELF:
        result.units.add (r: r, c: c, hp: INIT_HP, atk: INIT_ATK, t: ElfUnit)
        result.grid[r][c] = EMPTY

proc `$`(self: Cave): string =
  var res = self.grid
  for u in self.units:
    if u.t == GoblinUnit:
      res[u.r][u.c] = GOBLIN
    else:
      res[u.r][u.c] = ELF
  res.join "\n"

when defined(test):
  let input = """
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
""".strip
  block:
    let cave = input.parse
    doAssert cave.grid == @[
      "#######",
      "#.....#",
      "#.....#",
      "#.#.#.#",
      "#...#.#",
      "#.....#",
      "#######",
    ]
    doAssert cave.units == @[
      (1, 2, 200, 3, GoblinUnit),
      (2, 4, 200, 3, ElfUnit),
      (2, 5, 200, 3, GoblinUnit),
      (3, 5, 200, 3, GoblinUnit),
      (4, 3, 200, 3, GoblinUnit),
      (4, 5, 200, 3, ElfUnit),
    ]
    doAssert $cave == input

proc hasUnit(self: Cave, r, c: int): bool =
  for u in self.units:
    if u.hp <= 0: continue
    if (u.r, u.c) == (r, c): return true

proc isEmpty(self: Cave, r, c: int): bool =
  self.grid[r][c] != WALL and not self.hasUnit(r, c)

iterator emptyNeighbors(self: Cave, r, c: int): (int, int) =
  for (nr, nc) in neighbors4((r, c), (self.rows, self.cols)):
    if self.isEmpty(nr, nc):
      yield (nr, nc)

proc getFirstTarget(self: Cave, start: (int, int), targets: var HashSet[(int, int)]): Option[(int, int)] =
  if targets.len == 0: return

  var q = @[start]
  var visited = initHashSet[(int, int)]()
  visited.incl q[0]
  var res = newSeq[(int, int)]()
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      if (r, c) in targets:
        res.add (r, c)
        continue
      for (nr, nc) in self.emptyNeighbors(r, c):
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        next.add (nr, nc)
    if res.len > 0: break
    q = next
  if res.len > 0: return some(res.sorted[0])

proc getMoveTarget(self: Cave, ui: int): Option[(int, int)] =
  let unit = self.units[ui]

  var targets = initHashSet[(int, int)]()
  for i, other in self.units:
    if other.t == unit.t: continue
    if other.hp <= 0: continue
    for (nr, nc) in self.emptyNeighbors(other.r, other.c):
      targets.incl (nr, nc)

  self.getFirstTarget((unit.r, unit.c), targets)

when defined(test):
  block:
    let input = """
#######
#E..G.#
#...#.#
#.G.#G#
#######
""".strip
    let cave = input.parse
    doAssert cave.getMoveTarget(0).get == (1, 3)

proc getNextMoveTarget(self: Cave, ui: int, target: (int, int)): (int, int) =
  let unit = self.units[ui]
  var targets = self.emptyNeighbors(unit.r, unit.c).toSeq.toHashSet
  self.getFirstTarget(target, targets).get

when defined(test):
  block:
    let input = """
#######
#.E...#
#.....#
#...G.#
#######
""".strip
    let cave = input.parse
    let target = cave.getMoveTarget(0)
    doAssert target.get == (2, 4)
    doAssert cave.getNextMoveTarget(0, (2, 4)) == (1, 3)

proc isNeighbor(p1, p2: (int, int)): bool =
  let (r1, c1) = p1
  let (r2, c2) = p2
  (r1 - r2).abs + (c1 - c2).abs == 1

proc chooseOpponent(self: Cave, ui: int): Option[int] =
  let unit = self.units[ui]
  var cands = newSeq[int]()
  for uj, other in self.units:
    if other.t == unit.t: continue
    if other.hp <= 0: continue
    if isNeighbor((unit.r, unit.c), (other.r, other.c)):
      cands.add uj
  if cands.len > 0:
    cands = cands.sortedByIt(self.units[it].hp)
    let minHp = self.units[cands[0]].hp
    cands = cands.filterIt(self.units[it].hp == minHp)
    cands = cands.sortedByIt(self.units[it])
    return some(cands[0])

proc liveUnits(self: Cave, t: UnitType): int =
  self.units.countIt(it.hp > 0 and it.t == t)

proc hasTargets(self: Cave): bool =
  self.liveUnits(GoblinUnit) > 0 and self.liveUnits(ElfUnit) > 0

proc turn(self: Cave): bool =
  result = true
  self.units = self.units.sorted
  for i, unit in self.units.mpairs:
    if unit.hp <= 0: continue
    if not self.hasTargets:
      result = false
      break

    var opp = self.chooseOpponent(i)
    if opp.isNone:
      var t = self.getMoveTarget(i)
      if t.isNone: continue

      let (r, c) = self.getNextMoveTarget(i, t.get)
      unit.r = r
      unit.c = c
      opp = self.chooseOpponent(i)

    if opp.isSome:
      self.units[opp.get].hp -= unit.atk
  self.units = self.units.filterIt(it.hp > 0).sorted

when defined(test):
  block:
    let input = """
#########
#G..G..G#
#.......#
#.......#
#G..E..G#
#.......#
#.......#
#G..G..G#
#########
""".strip
    let cave = input.parse
    discard cave.turn
    doAssert $cave == """
#########
#.G...G.#
#...G...#
#...E..G#
#.G.....#
#.......#
#G..G..G#
#.......#
#########
""".strip
    discard cave.turn
    doAssert $cave == """
#########
#..G.G..#
#...G...#
#.G.E.G.#
#.......#
#G..G..G#
#.......#
#.......#
#########
""".strip
    discard cave.turn
    doAssert $cave == """
#########
#.......#
#..GGG..#
#..GEG..#
#G..G...#
#......G#
#.......#
#.......#
#########
""".strip

when defined(test):
  block:
    let cave = input.parse
    for _ in 0 ..< 47:
      doAssert cave.hasTargets
      discard cave.turn
    doAssert not cave.hasTargets

proc outcome(cave: Cave): int =
  var turns = 0
  while cave.hasTargets:
    if cave.turn:
      turns += 1
  turns * cave.units.mapIt(it.hp).sum

proc part1(input: string): int =
  let cave = input.parse
  cave.outcome

when defined(test):
  block:
    doAssert part1(input) == 27730
  block:
    let input = """
#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######
""".strip
    doAssert part1(input) == 36334
  let input2 = """
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
""".strip
  block:
    doAssert part1(input2) == 39514
  let input3 = """
#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######
""".strip
  block:
    doAssert part1(input3) == 27755
  let input4 = """
#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######
""".strip
  block:
    doAssert part1(input4) == 28944
  let input5 = """
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
""".strip
  block:
    doAssert part1(input5) == 18740



proc numElves(self: Cave): int =
  self.units.countIt(it.t == ElfUnit)

proc part2(input: string): int =
  var atk = 4
  while true:
    let cave = input.parse
    let elves = cave.numElves
    for unit in cave.units.mitems:
      if unit.t == ElfUnit:
        unit.atk = atk
    result = cave.outcome
    if cave.numElves == elves: return
    atk += 1

when defined(test):
  block:
    doAssert part2(input) == 4988
    doAssert part2(input2) == 31284
    doAssert part2(input3) == 3478
    doAssert part2(input4) == 6474
    doAssert part2(input5) == 1140


when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
