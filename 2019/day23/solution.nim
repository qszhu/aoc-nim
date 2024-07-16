import ../../lib/imports



type
  Value = int64

var queues = newSeq[Deque[Value]](50 * 2)

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

const STATUS_RUNNING = 0
const STATUS_WAITING = 1
const STATUS_FINISHED = 2

proc step(self: Program): int =
  let (op, _) = self.getCur.parseInst
  case op:
  of 99:
    return STATUS_FINISHED
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
    let v = if queues[self.ic].len == 0: -1 else: queues[self.ic].popFirst
    self.mem[a] = v
    self.ip += 2
  of 4:
    let a = self.getParam(1)
    queues[self.oc].addLast a
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

proc networkStep(): Value =
  for i in 0 ..< 50:
    let oc = 50 + i
    if queues[oc].len < 3: continue
    let a = queues[oc].popFirst
    let x = queues[oc].popFirst
    let y = queues[oc].popFirst
    if a == 255: return y
    queues[a].addLast x
    queues[a].addLast y

proc part1(input: string): int =
  for i in 0 ..< 50:
    queues[i].addLast i

  var programs = newSeq[Program]()
  for i in 0 ..< 50:
    programs.add input.parse(i, 50 + i)

  while true:
    for p in programs:
      discard p.step
    result = networkStep()
    if result != 0: break



proc networkStep2() =
  var cp: (Value, Value) = (Value.low, Value.low)
  for i in 0 ..< 50:
    let oc = 50 + i
    if queues[oc].len < 3: continue
    let a = queues[oc].popFirst
    let x = queues[oc].popFirst
    let y = queues[oc].popFirst
    if a == 255:
      cp = (x, y)
    else:
      queues[a].addLast x
      queues[a].addLast y

  let idle = (0 ..< 50).allIt(queues[it].len == 0)
  if idle and cp[1] != Value.low:
    echo cp[1]
    queues[0].addLast cp[0]
    queues[0].addLast cp[1]

proc part2(input: string): int =
  for i in 0 ..< 50:
    queues[i].addLast i

  var programs = newSeq[Program]()
  for i in 0 ..< 50:
    programs.add input.parse(i, 50 + i)

  while true:
    for p in programs: discard p.step
    networkStep2()



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
