import ../../lib/imports



type
  Inst = (char, int)
  Ship = (int, int, char)

proc parseLine(line: string): Inst =
  (line[0], line[1 .. ^1].parseInt)

proc parse(input: string): seq[Inst] =
  input.split("\n").mapIt(it.parseLine)

const DPOS = [(0, 1), (1, 0), (0, -1), (-1, 0)]
const DIRS = "NESW"

proc move(ship: Ship, insts: seq[Inst]): Ship =
  var (x, y, d) = ship
  for (c, v) in insts:
    case c
    of 'N', 'E', 'S', 'W':
      let (dx, dy) = DPOS[DIRS.find(c)]
      x += dx * v
      y += dy * v
    of 'L':
      d = DIRS[((DIRS.find(d) - v div 90) mod 4 + 4) mod 4]
    of 'R':
      d = DIRS[(DIRS.find(d) + v div 90) mod 4]
    of 'F':
      let (dx, dy) = DPOS[DIRS.find(d)]
      x += dx * v
      y += dy * v
    else: discard
  (x, y, d)

proc part1(input: string): int =
  let ship = (0, 0, 'E').move(input.parse)
  ship[0].abs + ship[1].abs

when defined(test):
  let input = """
F10
N3
F7
R90
F11
""".strip
  block:
    doAssert part1(input) == 25



type
  Navi = ref object
    shipX, shipY, waypointX, waypointY: int

proc newNavi(): Navi =
  result.new
  result.waypointX = 10
  result.waypointY = 1

proc move(self: Navi, inst: Inst) =
  let (c, v) = inst
  case c
  of 'N', 'S', 'E', 'W':
    let (dx, dy) = DPOS[DIRS.find(c)]
    self.waypointX += dx * v
    self.waypointY += dy * v
  of 'L':
    for _ in 0 ..< v div 90:
      (self.waypointX, self.waypointY) = (-self.waypointY, self.waypointX)
  of 'R':
    for _ in 0 ..< v div 90:
      (self.waypointX, self.waypointY) = (self.waypointY, -self.waypointX)
  of 'F':
    self.shipX += self.waypointX * v
    self.shipY += self.waypointY * v
  else: discard

proc part2(input: string): int =
  var navi = newNavi()
  for inst in input.parse:
    navi.move(inst)
  navi.shipX.abs + navi.shipY.abs

when defined(test):
  block:
    doAssert part2(input) == 286



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
