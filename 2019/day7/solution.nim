import ../../lib/imports



var queues: seq[Deque[int]]

type
  InstMode = enum
    ModePosition
    ModeImmediate

  RunStatus = enum
    StatusRunning
    StatusWaiting
    StatusFinished

  Inst = tuple[op: int, modes: array[3, InstMode]]

proc parseInst(n: int): Inst =
  (
    op: n mod 100,
    modes: [
      (n mod 1000 div 100).InstMode,
      (n mod 10000 div 1000).InstMode,
      (n mod 100000 div 10000).InstMode,
    ]
  )

type
  Program = ref object
    mem: seq[int]
    ip: int
    ic, oc: int

proc newProgram(mem: seq[int], ic, oc: int): Program =
  result.new
  result.mem = mem
  result.ic = ic
  result.oc = oc

proc getRaw(self: Program, i = 0): int =
  self.mem[self.ip + i]

template getParam(i: int, write = false): int =
  let v = self.getRaw(i)
  case inst.modes[i - 1]
  of ModeImmediate:
    v
  of ModePosition:
    if write: v else: self.mem[v]

proc step(self: Program): RunStatus =
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
  else:
    raise newException(ValueError, &"unknown op: {inst.op}")

proc newProgram(input: string, ic, oc: int): Program {.inline.} =
  newProgram(input.split(",").mapIt(it.parseInt), ic, oc)

proc signal(input: string, conf: seq[int]): int =
  let N = conf.len

  queues = newSeq[Deque[int]]()
  for i in 0 .. N: queues.add initDeque[int]()

  var programs = newSeq[Program]()
  for i, c in conf:
    queues[i].addLast c
    programs.add newProgram(input, i, i + 1)

  queues[0].addLast 0
  while true:
    var hasRunning = false
    for p in programs:
      if p.step == StatusRunning: hasRunning = true
    if not hasRunning: break

  queues[^1].popFirst

when defined(test):
  block:
    let input = """
3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0
""".strip
    doAssert signal(input, @[4,3,2,1,0]) == 43210
  block:
    let input = """
3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0
""".strip
    doAssert signal(input, @[0,1,2,3,4]) == 54321
  block:
    let input = """
3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0
""".strip
    doAssert signal(input, @[1,0,4,3,2]) == 65210

proc part1(input: string): int =
  var a = (0 .. 4).toSeq
  while true:
    result = result.max input.signal(a)
    if not a.nextPermutation: break



proc signal2(input: string, conf: seq[int]): int =
  let N = conf.len

  queues = newSeq[Deque[int]]()
  for i in 0 ..< N: queues.add initDeque[int]()

  var programs = newSeq[Program]()
  for i, c in conf:
    queues[i].addLast c
    programs.add newProgram(input, i, (i + 1) mod N)

  queues[0].addLast 0
  while true:
    var hasRunning = false
    for p in programs:
      if p.step == StatusRunning: hasRunning = true
    if not hasRunning: break

  queues[0].popFirst

when defined(test):
  block:
    let input = """
3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5
""".strip
    doAssert signal2(input, @[9,8,7,6,5]) == 139629729
  block:
    let input = """
3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10
""".strip
    doAssert signal2(input, @[9,7,8,5,6]) == 18216

proc part2(input: string): int =
  var a = (5 .. 9).toSeq
  while true:
    result = result.max input.signal2(a)
    if not a.nextPermutation: break



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
