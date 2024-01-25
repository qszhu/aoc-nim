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
  Cond = tuple[left, op: string, right: int]

  Inst = tuple[reg, op: string, val: int, cond: Cond]

proc parseLine(line: string): Inst =
  let p = line.split(" ")
  let cond = (left: p[4], op: p[5], right: p[6].parseInt)
  (reg: p[0], op: p[1], val: p[2].parseInt, cond: cond)

proc parse(input: string): seq[Inst] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10
""".strip
  block:
    let insts = input.parse
    doAssert insts[0] == ("b", "inc", 5, ("a", ">", 1))
    doAssert insts[1] == ("a", "inc", 1, ("b", "<", 5))
    doAssert insts[2] == ("c", "dec", -10, ("a", ">=", 1))
    doAssert insts[3] == ("c", "inc", -20, ("c", "==", 10))

type
  Computer = ref object
    reg: Table[string, int]
    insts: seq[Inst]
    maxVal: int

proc newComputer(insts: seq[Inst]): Computer =
  result.new
  result.reg = initTable[string, int]()
  result.insts = insts

proc eval(self: Computer, cond: Cond): bool =
  let (left, op, right) = cond
  let val = self.reg.getOrDefault(left, 0)
  case op:
  of ">": val > right
  of "<": val < right
  of "==": val == right
  of ">=": val >= right
  of "<=": val <= right
  of "!=": val != right
  else:
    raise newException(ValueError, "unknown op: " & op)

proc run(self: Computer, inst: Inst) =
  if not self.eval(inst.cond): return
  let (reg, op, val, _) = inst
  case op:
  of "inc": self.reg[reg] = self.reg.getOrDefault(reg, 0) + val
  of "dec": self.reg[reg] = self.reg.getOrDefault(reg, 0) - val
  else:
    raise newException(ValueError, "unknown op: " & op)
  self.maxVal = self.maxVal.max self.reg[reg]

proc run(self: Computer) =
  for inst in self.insts:
    self.run(inst)

when defined(test):
  block:
    let c = newComputer(input.parse)
    c.run
    doAssert c.reg.values.toSeq.max == 1

proc part1(input: string): int =
  let c = newComputer(input.parse)
  c.run
  c.reg.values.toSeq.max



when defined(test):
  block:
    let c = newComputer(input.parse)
    c.run
    doAssert c.maxVal == 10

proc part2(input: string): int =
  let c = newComputer(input.parse)
  c.run
  c.maxVal



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
