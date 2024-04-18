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
  os,
  rdstdin,
  re,
  sequtils,
  sets,
  streams,
  strformat,
  strutils,
  tables,
  threadpool,
  sugar,
]



type
  Value = int64

var channels: array[2, Channel[Value]]
for i in 0 ..< channels.len: channels[i].open

type
  Inst = tuple[op: int, modes: seq[int]]

proc parseInst(n: Value): Inst =
  (
    op: (n mod 100).int,
    modes: @[
      n mod 1_000 div 100,
      n mod 10_000 div 1_000,
      n mod 100_000 div 10_000,
    ].mapIt(it.int),
  )

type
  Program = ref object
    mem: Table[int, Value]
    ip: int
    base: int
    ic, oc: int

const MODE_POS = 0
const MODE_IMD = 1
const MODE_REL = 2

proc getRaw(self: Program, i: int): Value =
  self.mem.getOrDefault(i, 0)

proc getCur(self: Program, i = 0): Value =
  self.getRaw(self.ip + i)

proc getParam(self: Program, i: int, rw = "r"): Value =
  let (_, modes) = self.getCur.parseInst
  let v = self.getCur(i)
  if rw == "r":
    case modes[i - 1]:
    of MODE_POS:
      self.getRaw(v)
    of MODE_IMD:
      v
    of MODE_REL:
      self.getRaw(self.base + v)
    else:
      raise newException(ValueError, &"invalid mode {modes[i - 1]}")
  else:
    case modes[i - 1]:
    of MODE_POS:
      v
    of MODE_IMD:
      v
    of MODE_REL:
      self.base + v
    else:
      raise newException(ValueError, &"invalid mode {modes[i - 1]}")

const END = Value.high

proc run(self: Program) =
  while true:
    let (op, _) = self.getCur.parseInst
    case op:
    of 99:
      channels[self.oc].send(END)
      return
    of 1:
      let a = self.getParam(1)
      let b = self.getParam(2)
      let c = self.getParam(3, "w")
      self.mem[c] = a + b
      self.ip += 4
    of 2:
      let a = self.getParam(1)
      let b = self.getParam(2)
      let c = self.getParam(3, "w")
      self.mem[c] = a * b
      self.ip += 4
    of 3:
      let a = self.getParam(1, "w")
      let v = channels[self.ic].recv
      self.mem[a] = v
      self.ip += 2
    of 4:
      let a = self.getParam(1)
      channels[self.oc].send(a)
      self.ip += 2
    of 5:
      let a = self.getParam(1)
      let b = self.getParam(2)
      if a != 0:
        self.ip = b
      else:
        self.ip += 3
    of 6:
      let a = self.getParam(1)
      let b = self.getParam(2)
      if a == 0:
        self.ip = b
      else:
        self.ip += 3
    of 7:
      let a = self.getParam(1)
      let b = self.getParam(2)
      let c = self.getParam(3, "w")
      self.mem[c] = if a < b: 1 else: 0
      self.ip += 4
    of 8:
      let a = self.getParam(1)
      let b = self.getParam(2)
      let c = self.getParam(3, "w")
      self.mem[c] = if a == b: 1 else: 0
      self.ip += 4
    of 9:
      let a = self.getParam(1)
      self.base += a
      self.ip += 2
    else:
      raise newException(ValueError, &"unknown op: {op}")

proc parse(input: string): Program =
  result.new
  for i, d in input.split(",").mapIt(it.parseBiggestInt):
    result.mem[i] = d
  result.base = 0
  result.ip = 0
  result.ic = 0
  result.oc = 1

const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

const WALL = '#'
const EMTPY = '.'

proc part1(input: string): int =
  let p = input.parse
  spawn p.run
  sync()
  var output = ""
  while true:
    let c = channels[1].recv
    if c == END: break
    output &= c.char
  writeFile("map.txt", output)

  let grid = output.strip.split("\n")
  let (rows, cols) = (grid.len, grid[0].len)
  for r in 1 ..< rows - 1:
    for c in 1 ..< cols - 1:
      if grid[r][c] != WALL: continue
      var s = 0
      for (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if grid[nr][nc] == WALL: s += 1
      if s == 4: result += r * c

type
  Grid = seq[string]

const DIRS = "^>v<"

proc findStart(grid: Grid): (int, int, int) =
  let (rows, cols) = (grid.len, grid[0].len)
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      if grid[r][c] in DIRS:
        let dir = DIRS.find(grid[r][c])
        return (r, c, dir)

proc walk(grid: Grid): string =
  let (rows, cols) = (grid.len, grid[0].len)
  var (r, c, dir) = grid.findStart

  proc move(o: int): bool =
    let ndir = (dir + o + 4) mod 4
    let (dr, dc) = DPOS[ndir]
    let (nr, nc) = (r + dr, c + dc)
    if nr notin 0 ..< rows or nc notin 0 ..< cols: return false
    if grid[nr][nc] != WALL: return false
    (dir, r, c) = (ndir, nr, nc)
    true

  while true:
    if move(0):
      result &= "F"
    elif move(1):
      result &= "RF"
    elif move(-1):
      result &= "LF"
    else:
      break

proc rle(s: string): string =
  var res = newSeq[(char, int)]()
  var cnt = 1
  var ch = s[0]
  for i in 1 ..< s.len:
    if s[i] != ch:
      res.add (ch, cnt)
      ch = s[i]
      cnt = 1
    else:
      cnt += 1
  res.add (ch, cnt)
  res.mapIt((if it[0] == 'F': $it[1] else: $it[0])).join(",")

when defined(test):
  let grid = """
#######...#####
#.....#...#...#
#.....#...#...#
......#...#...#
......#...###.#
......#.....#.#
^########...#.#
......#.#...#.#
......#########
........#...#..
....#########..
....#...#......
....#...#......
....#...#......
....#####......
""".strip.split("\n")
  block:
    doAssert grid.walk.rle == "R,8,R,8,R,4,R,4,R,8,L,6,L,2,R,4,R,4,R,8,R,8,R,8,L,6,L,2"

proc compress(route: string): (seq[string], seq[int]) =
  let route = route
  var res: (seq[string], seq[int])
  proc search(i: int, dict: seq[string], sofar: seq[int]): bool =
    if sofar.len >= 20: return false
    if i == route.len:
      res = (dict, sofar)
      return true
    if i > route.len: return false
    for j, pat in dict:
      if i + pat.len <= route.len and route[i ..< i + pat.len] == pat:
        if search(i + pat.len, dict, sofar & j): return true
    if dict.len == 3: return false
    for j in i + 1 .. route.len:
      let pat = route[i ..< j]
      if pat.rle.len > 20: break
      if search(i + pat.len, dict & pat, sofar & dict.len): return true
  doAssert search(0, newSeq[string](), newSeq[int]())
  res

when defined(test):
  block:
    let route = grid.walk
    let (dict, routine) = route.compress
    doAssert route == routine.mapIt(dict[it]).join

proc controller() =
  let grid = readFile("map.txt").strip.split("\n")
  let (dict, routine) = grid.walk.compress
  let A = dict[0].rle
  let B = dict[1].rle
  let C = dict[2].rle
  let r = routine.mapIt(char(it + 'A'.ord)).join(",")
  echo (r, A, B, C)
  for m in [r, A, B, C]:
    for ch in m:
      channels[0].send ch.ord
    channels[0].send '\n'.ord
  channels[0].send 'n'.ord
  channels[0].send '\n'.ord

proc part2(input: string): int =
  let p = input.parse
  p.mem[0] = 2
  spawn p.run
  spawn controller()
  sync()
  var s = ""
  while true:
    let r = channels[1].recv
    if r == END: break
    if r < 256:
      s &= r.char
    else:
      echo s
      return r

when isMainModule and not defined(test):
  let input = readFile("input").strip
  # echo part1(input)
  echo part2(input)
