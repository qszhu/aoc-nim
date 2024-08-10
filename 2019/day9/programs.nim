import std/[
  deques,
  sequtils,
  strformat,
  strutils,
  tables,
]



type
  InstMode = enum
    ModePosition
    ModeImmediate
    ModeRelative

  RunStatus* = enum
    StatusRunning
    StatusWaiting
    StatusFinished

type
  Value* = int64

  Inst = tuple[op: int, modes: array[3, InstMode]]

proc parseInst(n: Value): Inst =
  (
    op: (n mod 100).int,
    modes: [
      (n mod 1000 div 100).InstMode,
      (n mod 10000 div 1000).InstMode,
      (n mod 100000 div 10000).InstMode,
    ]
  )

var queues*: seq[Deque[Value]]

proc initQueues*(n: int) {.inline.} =
  queues = newSeq[Deque[Value]](n)

type
  Program* = ref object
    mem*: Table[int, Value]
    ip: int
    base: int
    ic, oc: int

proc getMem(self: Program, i = 0): Value {.inline.} =
  self.mem.getOrDefault(i, 0)

proc getRaw(self: Program, i = 0): Value {.inline.} =
  self.getMem(self.ip + i)

template getParam(i: int, write = false): Value =
  let v = self.getRaw(i)
  case inst.modes[i - 1]
  of ModePosition:
    if write: v else: self.getMem(v)
  of ModeImmediate:
    v
  of ModeRelative:
    if write: self.base + v else: self.getMem(self.base + v)

proc step*(self: Program): RunStatus =
  if self.getRaw == 99: return StatusFinished

  let inst = self.getRaw.parseInst
  case inst.op:
  of 1:
    let a = getParam(1)
    let b = getParam(2)
    let c = getParam(3, write = true)
    self.mem[c] = a + b
    self.ip += 4
  of 2:
    let a = getParam(1)
    let b = getParam(2)
    let c = getParam(3, write = true)
    self.mem[c] = a * b
    self.ip += 4
  of 3:
    let a = getParam(1, write = true)
    if queues[self.ic].len == 0: return StatusWaiting
    self.mem[a] = queues[self.ic].popFirst
    self.ip += 2
  of 4:
    let a = getParam(1)
    queues[self.oc].addLast a
    self.ip += 2
  of 5:
    let a = getParam(1)
    let b = getParam(2)
    if a != 0:
      self.ip = b
    else:
      self.ip += 3
  of 6:
    let a = getParam(1)
    let b = getParam(2)
    if a == 0:
      self.ip = b
    else:
      self.ip += 3
  of 7:
    let a = getParam(1)
    let b = getParam(2)
    let c = getParam(3, write = true)
    self.mem[c] = if a < b: 1 else: 0
    self.ip += 4
  of 8:
    let a = getParam(1)
    let b = getParam(2)
    let c = getParam(3, write = true)
    self.mem[c] = if a == b: 1 else: 0
    self.ip += 4
  of 9:
    let a = getParam(1)
    self.base += a
    self.ip += 2
  else:
    raise newException(ValueError, &"unknown op: {inst.op}")

proc stepOver*(self: Program): RunStatus =
  result = self.step
  while result == StatusRunning:
    result = self.step

proc runToEnd*(self: Program) =
  var res = self.step
  while res != StatusFinished:
    res = self.step

proc newProgram*(input: string, ic, oc: int): Program =
  result.new
  for i, d in input.split(",").mapIt(it.parseBiggestInt):
    result.mem[i] = d
  result.ic = ic
  result.oc = oc
