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
  Inst = (string, string, int)

proc parseInst(line: string): Inst =
  if line =~ re"hlf ([ab])":
    ("hlf", matches[0], 0)
  elif line =~ re"tpl ([ab])":
    ("tpl", matches[0], 0)
  elif line =~ re"inc ([ab])":
    ("inc", matches[0], 0)
  elif line =~ re"jmp ([+-]\d+)":
    ("jmp", "", matches[0].parseInt)
  elif line =~ re"jie ([ab]), ([+-]\d+)":
    ("jie", matches[0], matches[1].parseInt)
  elif line =~ re"jio ([ab]), ([+-]\d+)":
    ("jio", matches[0], matches[1].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert parseInst("hlf a") == ("hlf", "a", 0)
    doAssert parseInst("tpl b") == ("tpl", "b", 0)
    doAssert parseInst("inc a") == ("inc", "a", 0)
    doAssert parseInst("jmp +2") == ("jmp", "", 2)
    doAssert parseInst("jie a, -2") == ("jie", "a", -2)
    doAssert parseInst("jio b, +2") == ("jio", "b", 2)

type
  Computer = ref object
    reg: array[2, int]
    instructions: seq[Inst]
    ip: int

proc newComputer(instructions: seq[Inst], a = 0, b = 0): Computer =
  result.new
  result.reg[0] = a
  result.reg[1] = b
  result.instructions = instructions

proc run(self: Computer) =
  while self.ip in 0 ..< self.instructions.len:
    let (op, reg, n) = self.instructions[self.ip]
    let r = if reg == "a": 0 else: 1
    case op:
    of "hlf":
      self.reg[r] = self.reg[r] shr 1
    of "tpl":
      self.reg[r] *= 3
    of "inc":
      self.reg[r] += 1
    of "jmp":
      self.ip += n
      continue
    of "jie":
      if self.reg[r] mod 2 == 0:
        self.ip += n
        continue
    of "jio":
      if self.reg[r] == 1:
        self.ip += n
        continue
    self.ip += 1

proc parse(input: string): seq[Inst] =
  for line in input.split("\n"):
    result.add parseInst(line)

when defined(test):
  block:
    let c = newComputer(parse("""
inc a
jio a, +2
tpl a
inc a
""".strip))
    c.run
    doAssert c.reg[0] == 2

proc part1(input: string): int =
  let c = newComputer(input.parse)
  c.run
  c.reg[1]

proc part2(input: string): int =
  let c = newComputer(input.parse, a = 1)
  c.run
  c.reg[1]

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
