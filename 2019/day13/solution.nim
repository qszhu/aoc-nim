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

const EMPTY = 0
const WALL = 1
const BLOCK = 2
const PADDLE = 3
const BALL = 4

proc part1(input: string): int =
  let p = input.parse
  p.run
  while true:
    var x = channels[1].recv
    if x == END: break
    x = channels[1].recv
    x = channels[1].recv
    if x == BLOCK:
      result += 1



proc joystick() =
  var px = -1
  while true:
    let x = channels[1].recv
    if x == END: break
    let y = channels[1].recv
    let t = channels[1].recv
    if (x, y) == (-1.Value, 0.Value):
      echo t
      continue
    if t == PADDLE:
      px = x
      continue
    if t == BALL:
      if px != -1:
        if px < x:
          channels[0].send(1)
        elif px > x:
          channels[0].send(-1)
        continue
      channels[0].send(0)
      continue

proc part2(input: string): int =
  let p = input.parse
  p.mem[0] = 2
  spawn p.run
  spawn joystick()
  sync()

when isMainModule and not defined(test):
  let input = readFile("input").strip
  # echo part1(input)
  discard part2(input)
