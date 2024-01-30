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

proc parseLine(line: string): Inst =
  line.split(" ")

proc parse(input: string): seq[Inst] =
  input.split("\n").mapIt(it.parseLine)

type
  Processor = ref object
    regs: Table[string, int]
    ip: int
    insts: seq[Inst]

proc newProcessor(insts: seq[Inst]): Processor =
  result.new
  result.insts = insts
  for r in 'a' .. 'h':
    result.regs[$r] = 0

proc getVal(self: Processor, x: string): int =
  if x in self.regs: self.regs[x]
  else: x.parseInt

proc debug(self: Processor): int =
  while self.ip in 0 ..< self.insts.len:
    let inst = self.insts[self.ip]
    case inst[0]:
    of "set":
      let (x, y) = (inst[1], inst[2])
      self.regs[x] = self.getVal(y)
    of "sub":
      let (x, y) = (inst[1], inst[2])
      self.regs[x] = self.regs[x] - self.getVal(y)
    of "mul":
      let (x, y) = (inst[1], inst[2])
      self.regs[x] = self.regs[x] * self.getVal(y)
      result += 1
    of "jnz":
      let (x, y) = (inst[1], inst[2])
      if self.getVal(x) != 0:
        self.ip += self.getVal(y)
        continue
    self.ip += 1

proc part1(input: string): int =
  let p = newProcessor(input.parse)
  p.debug

proc isPrime(n: int): bool =
  var p = 2
  while p * p <= n:
    if n mod p == 0: return false
    p += 1
  true

proc part2(input: string): int =
  let insts = input.parse

  let p = newProcessor(insts[0 ..< 8])
  p.regs["a"] = 1
  discard p.debug
  var (b, c) = (p.regs["b"], p.regs["c"])

  let step = insts[30][2].parseInt.abs
  countup(b, c, step).countIt(not it.isPrime)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
