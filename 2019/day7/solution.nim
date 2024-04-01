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
  Inst = tuple[op: int, modes: seq[int]]

proc parseInst(n: int): Inst =
  (
    op: n mod 100,
    modes: @[
      n mod 1_000 div 100,
      n mod 10_000 div 1_000,
      n mod 100_000 div 10_000,
    ],
  )

var channels: array[6, Channel[int]]
for i in 0 ..< channels.len: channels[i].open

type
  Program = ref object
    data: seq[int]
    ip: int
    ic, oc: int

const MODE_POS = 0
const MODE_IMD = 1

proc getRaw(self: Program, i = 0): int =
  self.data[self.ip + i]

proc getValue(self: Program, i: int): int =
  let (_, modes) = self.getRaw.parseInst
  let v = self.getRaw(i)
  if modes[i - 1] == MODE_IMD: v
  else: self.data[v]

proc hasEnded(self: Program): bool =
  self.getRaw == 99

proc run(self: Program) =
  while true:
    if self.getRaw == 99: return
    let (op, _) = self.getRaw.parseInst
    case op:
    of 1:
      let a = self.getValue(1)
      let b = self.getValue(2)
      let c = self.getRaw(3)
      self.data[c] = a + b
      self.ip += 4
    of 2:
      let a = self.getValue(1)
      let b = self.getValue(2)
      let c = self.getRaw(3)
      self.data[c] = a * b
      self.ip += 4
    of 3:
      let a = self.getRaw(1)
      let v = channels[self.ic].recv()
      self.data[a] = v
      self.ip += 2
    of 4:
      let a = self.getValue(1)
      channels[self.oc].send(a)
      self.ip += 2
    of 5:
      let a = self.getValue(1)
      let b = self.getValue(2)
      if a != 0:
        self.ip = b
      else:
        self.ip += 3
    of 6:
      let a = self.getValue(1)
      let b = self.getValue(2)
      if a == 0:
        self.ip = b
      else:
        self.ip += 3
    of 7:
      let a = self.getValue(1)
      let b = self.getValue(2)
      let c = self.getRaw(3)
      self.data[c] = if a < b: 1 else: 0
      self.ip += 4
    of 8:
      let a = self.getValue(1)
      let b = self.getValue(2)
      let c = self.getRaw(3)
      self.data[c] = if a == b: 1 else: 0
      self.ip += 4
    else:
      raise newException(ValueError, &"unknown op: {op}")

proc parse(input: string, ic, oc: int): Program =
  result.new
  result.data = input.split(",").mapIt(it.parseInt)
  result.ic = ic
  result.oc = oc

proc signal(input: string, conf: seq[int]): int =
  for i, c in conf:
    channels[i].send(c)
    var p = input.parse(i, i + 1)
    spawn p.run()
  channels[0].send(0)
  sync()
  result = channels[^1].recv

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
  for i, c in conf:
    channels[i].send(c)
    var p = input.parse(i, (i + 1) mod 5)
    spawn p.run()
  channels[0].send(0)
  sync()
  result = channels[0].recv

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
