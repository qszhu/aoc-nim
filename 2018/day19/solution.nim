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
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



type
  Inst = tuple[op: string, a, b, c: int]

  Registers = array[6, int]

  Computer* = ref object
    regs*: Registers
    insts: seq[Inst]
    ip*, ipReg: int

proc parseInst(line: string): Inst =
  let p = line.split(" ")
  (p[0], p[1].parseInt, p[2].parseInt, p[3].parseInt)

proc parse*(input: string): Computer =
  result.new
  let lines = input.split("\n")
  result.ipReg = lines[0].split(" ")[1].parseInt
  result.insts = lines[1 .. ^1].mapIt(it.parseInst)

when defined(test):
  let input = """
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
""".strip
  block:
    let c = input.parse
    doAssert c.ipReg == 0
    doAssert c.insts.len == 7

proc exec(regs: Registers, inst: string, a, b, c: int): Registers =
  result = regs
  case inst:
  of "addr":
    result[c] = regs[a] + regs[b]
  of "addi":
    result[c] = regs[a] + b
  of "mulr":
    result[c] = regs[a] * regs[b]
  of "muli":
    result[c] = regs[a] * b
  of "banr":
    result[c] = regs[a] and regs[b]
  of "bani":
    result[c] = regs[a] and b
  of "borr":
    result[c] = regs[a] or regs[b]
  of "bori":
    result[c] = regs[a] or b
  of "setr":
    result[c] = regs[a]
  of "seti":
    result[c] = a
  of "gtir":
    result[c] = if a > regs[b]: 1 else: 0
  of "gtri":
    result[c] = if regs[a] > b: 1 else: 0
  of "gtrr":
    result[c] = if regs[a] > regs[b]: 1 else: 0
  of "eqir":
    result[c] = if a == regs[b]: 1 else: 0
  of "eqri":
    result[c] = if regs[a] == b: 1 else: 0
  of "eqrr":
    result[c] = if regs[a] == regs[b]: 1 else: 0
  else:
    raise newException(ValueError, "unknown instruction " & inst)

proc step*(self: Computer): bool =
  let (inst, a, b, c) = self.insts[self.ip]
  self.regs[self.ipReg] = self.ip
  self.regs = self.regs.exec(inst, a, b, c)
  self.ip = self.regs[self.ipReg]
  self.ip += 1
  self.ip in 0 ..< self.insts.len

when defined(test):
  block:
    let c = input.parse
    doAssert c.step
    doAssert c.regs == [0, 5, 0, 0, 0, 0]
    doAssert c.step
    doAssert c.regs == [1, 5, 6, 0, 0, 0]
    doAssert c.step
    doAssert c.regs == [3, 5, 6, 0, 0, 0]
    doAssert c.step
    doAssert c.regs == [5, 5, 6, 0, 0, 0]
    doAssert not c.step
    doAssert c.regs == [6, 5, 6, 0, 0, 9]

proc part1(input: string): int =
  let c = input.parse
  while c.step: discard
  c.regs[0]



proc disassemble(self: Computer) =
  var ip = 0
  proc rl(r: int): string =
    if r == self.ipReg: "ip"
    else: &"r{r}"
  proc rr(r: int): string =
    if r == self.ipReg: &"{ip}"
    else: &"r{r}"
  for (inst, a, b, c) in self.insts:
    case inst:
    of "addr":
      echo &"[{ip}] {rl(c)} = {rr(a)} + {rr(b)}"
    of "addi":
      echo &"[{ip}] {rl(c)} = {rr(a)} + {b}"
    of "mulr":
      echo &"[{ip}] {rl(c)} = {rr(a)} * {rr(b)}"
    of "muli":
      echo &"[{ip}] {rl(c)} = {rr(a)} * {b}"
    of "banr":
      echo &"[{ip}] {rl(c)} = {rr(a)} and {rr(b)}"
    of "bani":
      echo &"[{ip}] {rl(c)} = {rr(a)} and {b}"
    of "borr":
      echo &"[{ip}] {rl(c)} = {rr(a)} or {rr(b)}"
    of "bori":
      echo &"[{ip}] {rl(c)} = {rr(a)} or {b}"
    of "setr":
      echo &"[{ip}] {rl(c)} = {rr(a)}"
    of "seti":
      echo &"[{ip}] {rl(c)} = {a}"
    of "gtir":
      echo &"[{ip}] {rl(c)} = {a} > {rr(b)}"
    of "gtri":
      echo &"[{ip}] {rl(c)} = {rr(a)} > {b}"
    of "gtrr":
      echo &"[{ip}] {rl(c)} = {rr(a)} > {rr(b)}"
    of "eqir":
      echo &"[{ip}] {rl(c)} = {a} == {rr(b)}"
    of "eqri":
      echo &"[{ip}] {rl(c)} = {rr(a)} == {b}"
    of "eqrr":
      echo &"[{ip}] {rl(c)} = {rr(a)} == {rr(b)}"
    else:
      raise newException(ValueError, "unknown instruction " & inst)
    ip += 1

proc sumDivisors(n: int): int =
  var p = 1
  while p * p <= n:
    if n mod p == 0:
      result += p
      if p * p != n:
        result += n div p
    p += 1

proc part2(input: string): int =
  let c = input.parse
  # c.disassemble
  c.regs[0] = 1
  while c.ip != 1:
    discard c.step
  let r1 = c.regs[1]
  r1.sumDivisors



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
