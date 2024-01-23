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

  Computer = ref object
    ip: int
    insts: seq[Inst]
    registers: Table[string, int]

proc newComputer(insts: seq[Inst]): Computer =
  result.new
  result.insts = insts
  result.registers = { "a": 0, "b": 0, "c": 0, "d": 0 }.toTable

proc getVal(self: Computer, x: string): int =
  if x in "abcd": self.registers[x]
  else: x.parseInt

iterator run(self: Computer): int =
  while self.ip < self.insts.len:
    let inst = self.insts[self.ip]
    case inst[0]:
    of "out":
      let x = self.getVal(inst[1])
      yield x
    of "cpy":
      let x = self.getVal(inst[1])
      let y = inst[2]
      if y in "abcd":
        self.registers[y] = x
    of "inc":
      let x = inst[1]
      if x in "abcd":
        self.registers[x] += 1
    of "dec":
      let x = inst[1]
      if x in "abcd":
        self.registers[x] -= 1
    of "jnz":
      let x = self.getVal(inst[1])
      let y = self.getVal(inst[2])
      if x != 0:
        self.ip += y
        continue
    self.ip += 1

proc parseLine(line: string): Inst =
  line.split(" ").toSeq

proc run(input: string, a: int, n: int): seq[int] =
  let insts = input.split("\n").mapIt(it.parseLine)
  let c = newComputer(insts)
  c.registers["a"] = a
  var i = 0
  for x in c.run:
    result.add x
    i += 1
    if i >= n: break

proc part1(input: string): int =
  var a = 0
  while true:
    let o = run(input, a, 10)
    if o == @[0, 1, 0, 1, 0, 1, 0, 1, 0, 1]: return a
    a += 1

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
