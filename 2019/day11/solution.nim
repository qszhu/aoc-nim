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

proc parse(input: string, ic, oc: int): Program =
  result.new
  for i, d in input.split(",").mapIt(it.parseBiggestInt):
    result.mem[i] = d
  result.base = 0
  result.ip = 0
  result.ic = ic
  result.oc = oc

const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

const BLACK = 0
const WHITE = 1

proc outputPanel(panel: Table[(int, int), int]) =
  var minR, minC = int.high
  var maxR, maxC = int.low
  for (r, c) in panel.keys:
    minR = minR.min r
    minC = minC.min c
    maxR = maxR.max r
    maxC = maxC.max c
  var rows = maxR - minR + 1
  var cols = maxC - minC + 1
  var grid = newSeqWith(rows, "#".repeat(cols))
  for (r, c) in panel.keys:
    let color = panel[(r, c)]
    if color == BLACK: grid[r - minR][c - minC] = '.'
    else: grid[r - minR][c - minC] = '#'
  for row in grid:
    echo row

proc robotRun(initColor: int) {.gcsafe.} =
  var panel = initTable[(int, int), int]()
  var dir = 0
  var r, c = 0
  while true:
    var color = if (r, c) in panel: panel[(r, c)] else: initColor
    channels[0].send color
    color = channels[1].recv
    if color == END: break
    panel[(r, c)] = color
    let t = channels[1].recv
    if t == 0: dir = (dir - 1 + 4) mod 4
    elif t == 1: dir = (dir + 1) mod 4
    let (dr, dc) = DPOS[dir]
    (r, c) = (r + dr, c + dc)
  if initColor == BLACK:
    echo panel.len
  else:
    outputPanel(panel)

proc part1(input: string): int =
  let p = input.parse(0, 1)
  spawn p.run()
  spawn robotRun(BLACK)
  sync()

proc part2(input: string): int =
  let p = input.parse(0, 1)
  spawn p.run()
  spawn robotRun(WHITE)
  sync()



when isMainModule and not defined(test):
  let input = readFile("input").strip
  # discard part1(input)
  discard part2(input)
