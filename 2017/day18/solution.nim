import std/[
  algorithm,
  bitops,
  deques,
  json,
  math,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



type
  Inst = seq[string]

  Program = ref object
    regs: Table[string, int]
    insts: seq[Inst]
    ip: int
    sound: int

proc newProgram(insts: seq[Inst]): Program =
  result.new
  result.insts = insts

proc getVal(self: Program, x: string): int =
  if x[0].isAlphaAscii: self.regs.getOrDefault(x)
  else: x.parseInt

proc run(self: Program): int =
  while self.ip in 0 ..< self.insts.len:
    let inst = self.insts[self.ip]
    case inst[0]:
    of "snd":
      let x = inst[1]
      self.sound = self.getVal(x)
    of "set":
      let (x, y) = (inst[1], inst[2])
      self.regs[x] = self.getVal(y)
    of "add":
      let (x, y) = (inst[1], inst[2])
      self.regs[x] = self.regs.getOrDefault(x, 0) + self.getVal(y)
    of "mul":
      let (x, y) = (inst[1], inst[2])
      self.regs[x] = self.regs.getOrDefault(x, 0) * self.getVal(y)
    of "mod":
      let (x, y) = (inst[1], inst[2])
      self.regs[x] = self.regs[x] mod self.getVal(y)
    of "rcv":
      let x = inst[1]
      if self.getVal(x) != 0:
        return self.sound
    of "jgz":
      let (x, y) = (inst[1], inst[2])
      if self.getVal(x) > 0:
        self.ip += self.getVal(y)
        continue
    else:
      raise newException(ValueError, "unknown instruction: " & inst.join(" "))
    self.ip += 1

proc parse(input: string): seq[Inst] =
  input.split("\n").mapIt(it.split(" "))

when defined(test):
  let input = """
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2
""".strip
  block:
    let p = newProgram(input.parse)
    doAssert p.run == 4

proc part1(input: string): int =
    let p = newProgram(input.parse)
    p.run



type
  Coroutine = ref object
    id: int
    regs: Table[string, int]
    ip: int
    output: Deque[int]
    sent: int

proc newCoroutine(id: int): Coroutine =
  result.new
  result.id = id
  result.regs["p"] = id

type
  Computer = ref object
    coroutines: array[2, Coroutine]
    insts: seq[Inst]

proc newComputer(insts: seq[Inst]): Computer =
  result.new
  result.insts = insts
  result.coroutines[0] = newCoroutine(0)
  result.coroutines[1] = newCoroutine(1)

proc getVal(self: Coroutine, x: string): int =
  if x[0].isAlphaAscii: self.regs.getOrDefault(x)
  else: x.parseInt

type
  Status = enum
    Running
    Waiting
    Stopped

proc step(self: Coroutine, computer: Computer): Status =
  if self.ip notin 0 ..< computer.insts.len: return Status.Stopped
  let inst = computer.insts[self.ip]
  case inst[0]:
  of "set":
    let (x, y) = (inst[1], inst[2])
    self.regs[x] = self.getVal(y)
  of "add":
    let (x, y) = (inst[1], inst[2])
    self.regs[x] = self.regs.getOrDefault(x, 0) + self.getVal(y)
  of "mul":
    let (x, y) = (inst[1], inst[2])
    self.regs[x] = self.regs.getOrDefault(x, 0) * self.getVal(y)
  of "mod":
    let (x, y) = (inst[1], inst[2])
    self.regs[x] = self.regs[x] mod self.getVal(y)
  of "jgz":
    let (x, y) = (inst[1], inst[2])
    if self.getVal(x) > 0:
      self.ip += self.getVal(y)
      return
  of "snd":
    let x = inst[1]
    self.output.addLast self.getVal(x)
    self.sent += 1
  of "rcv":
    let other = self.id xor 1
    if computer.coroutines[other].output.len > 0:
      let x = inst[1]
      let v = computer.coroutines[other].output.popFirst
      self.regs[x] = v
    else:
      return Status.Waiting
  else:
    raise newException(ValueError, "unknown instruction: " & inst.join(" "))
  self.ip += 1
  Status.Running

proc run(self: Computer): int =
  while true:
    let s0 = self.coroutines[0].step(self)
    let s1 = self.coroutines[1].step(self)
    if s0 != Status.Running and s1 != Status.Running: break
  self.coroutines[1].sent

proc part2(input: string): int =
  let computer = newComputer(input.parse)
  computer.run



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
