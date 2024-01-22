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

proc run(self: Computer) =
  while self.ip < self.insts.len:
    let inst = self.insts[self.ip]
    # echo (&"[{self.ip}] " & inst.join(" "))
    case inst[0]:
    of "tgl":
      let x = self.getVal(inst[1])
      let newIp = self.ip + x
      if newIp in 0 ..< self.insts.len:
        var inst = self.insts[newIp]
        if inst.len == 2:
          inst[0] = if inst[0] == "inc": "dec" else: "inc"
        else:
          inst[0] = if inst[0] == "jnz": "cpy" else: "jnz"
        self.insts[newIp] = inst
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
    # echo "abcd".mapIt($(self.registers[$it])).join(" ")
    self.ip += 1

proc parseLine(line: string): Inst =
  line.split(" ").toSeq

when defined(test):
  let input = """
cpy 2 a
tgl a
tgl a
tgl a
cpy 1 a
dec a
dec a
""".strip
  let insts = input.split("\n").mapIt(it.parseLine)
  let c = newComputer(insts)
  c.run
  doAssert c.registers["a"] == 3

proc run(input: string, a: int): int =
  let insts = input.split("\n").mapIt(it.parseLine)
  let c = newComputer(insts)
  c.registers["a"] = a
  c.run
  c.registers["a"]

proc part1(input: string): int =
  run(input, 7)

proc part2(input: string): int =
  let a = 12
  let lines = input.split("\n")
  let b = lines[19].split(" ")[1].parseInt
  let c = lines[20].split(" ")[1].parseInt
  fac(a) + b * c

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
