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

const DPOS = [(0, 0), (-1, 0), (1, 0), (0, -1), (0, 1)]
const REV = [0, 2, 1, 4, 3]

const WALL = 0
const EMPTY = 1
const TARGET = 2

type
  Grid = seq[seq[int]]

proc makeGrid(mapping: Table[(int, int), int]): (Grid, int, int) =
  var minR, minC = int.high
  var maxR, maxC = int.low
  for (r, c) in mapping.keys:
    minR = minR.min r
    maxR = maxR.max r
    minC = minC.min c
    maxC = maxC.max c
  let rows = maxR - minR + 1
  let cols = maxC - minC + 1
  var grid = newSeqWith(rows, newSeq[int](cols))
  for (r, c) in mapping.keys:
    grid[r - minR][c - minC] = mapping[(r, c)]
  (grid, -minR, -minC)

proc `$`(self: Grid): string =
  self.map(row => row.mapIt(if it == WALL: '#' elif it == EMPTY: '.' else: 'X').join).join("\n")

proc bfs1(grid: Grid, sr, sc: int): (int, int, int) =
  let (rows, cols) = (grid.len, grid[0].len)
  var q = @[(sr, sc)]
  var visited = q.toHashSet
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    steps += 1
    for (r, c) in q:
      for dir in 1 .. 4:
        let (dr, dc) = DPOS[dir]
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows: continue
        if nc notin 0 ..< cols: continue
        if grid[nr][nc] == WALL: continue
        if grid[nr][nc] == TARGET: return (steps, nr, nc)
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        next.add (nr, nc)
    q = next

const OXYGEN = 3

proc bfs2(grid: Grid, sr, sc: int): int =
  var grid = grid
  let (rows, cols) = (grid.len, grid[0].len)
  var q = @[(sr, sc)]
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      for dir in 1 .. 4:
        let (dr, dc) = DPOS[dir]
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows: continue
        if nc notin 0 ..< cols: continue
        if grid[nr][nc] != EMPTY: continue
        grid[nr][nc] = OXYGEN
        next.add (nr, nc)
    q = next
    if q.len > 0:
      steps += 1
  steps

when defined(test):
  block:
    let grid = @[
      @[0,0,0,0,0,0],
      @[0,1,1,0,0,0],
      @[0,1,0,1,1,0],
      @[0,1,2,1,0,0],
      @[0,0,0,0,0,0],
    ]
    doAssert bfs2(grid, 3, 2) == 4

proc control() =
  var (r, c) = (0, 0)

  var mapping = initTable[(int, int), int]()
  mapping[(r, c)] = EMPTY

  var routes = newSeq[(int, bool)]()
  for dir in 1 .. 4:
    routes.add (dir, false)

  while routes.len > 0:
    let (dir, visited) = routes[^1]
    if visited:
      let revDir = REV[dir]
      channels[0].send revDir
      doAssert channels[1].recv != WALL
      let (dr, dc) = DPOS[revDir]
      (r, c) = (r + dr, c + dc)
      discard routes.pop
      continue

    routes[^1] = (dir, true)
    let (dr, dc) = DPOS[dir]
    let (nr, nc) = (r + dr, c + dc)
    if (nr, nc) in mapping:
      discard routes.pop
      continue

    channels[0].send dir
    let res = channels[1].recv
    mapping[(nr, nc)] = res
    if res == WALL:
      discard routes.pop
      continue

    (r, c) = (nr, nc)
    for dir in 1 .. 4:
      routes.add (dir, false)

  let (grid, sr, sc) = makeGrid(mapping)
  echo grid
  let (steps, tr, tc) = bfs1(grid, sr, sc)
  echo steps
  echo bfs2(grid, tr, tc)

when isMainModule and not defined(test):
  let input = readFile("input").strip
  let p = input.parse
  spawn p.run
  spawn control()
  sync()
