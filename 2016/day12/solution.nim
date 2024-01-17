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

proc run(self: Computer) =
  while self.ip < self.insts.len:
    let inst = self.insts[self.ip]
    case inst[0]:
    of "cpy":
      let x = if inst[1] in "abcd": self.registers[inst[1]]
        else: inst[1].parseInt
      let y = inst[2]
      self.registers[y] = x
    of "inc":
      let x = inst[1]
      self.registers[x] += 1
    of "dec":
      let x = inst[1]
      self.registers[x] -= 1
    of "jnz":
      let x = if inst[1] in "abcd": self.registers[inst[1]]
        else: inst[1].parseInt
      let y = inst[2].parseInt
      if x != 0:
        self.ip += y
        continue
    self.ip += 1

proc parseLine(line: string): Inst =
  line.split(" ").toSeq

proc part1(input: string): int =
  let insts = input.split("\n").mapIt(it.parseLine)
  let c = newComputer(insts)
  c.run
  c.registers["a"]

when defined(test):
  let input = """
cpy 41 a
inc a
inc a
dec a
jnz a 2
dec a
""".strip
  doAssert part1(input) == 42

proc part2(input: string): int =
  let insts = input.split("\n").mapIt(it.parseLine)
  let c = newComputer(insts)
  c.registers["c"] = 1
  c.run
  c.registers["a"]



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
