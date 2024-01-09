import std/[
  algorithm,
  bitops,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]



type
  Gate = ref object of RootObj
    output: string

  Wire = ref object of Gate
    a: string

  AndGate = ref object of Gate
    a, b: string

  OrGate = ref object of Gate
    a, b: string

  NotGate = ref object of Gate
    a: string

  LShiftGate = ref object of Gate
    a: string
    n: int

  RShiftGate = ref object of Gate
    a: string
    n: int

  Circuit = ref object
    cache: Table[string, Gate]

method eval(g: Gate, c: Circuit): uint16 {.base.} = discard

proc eval(self: Circuit, output: string): uint16

method eval(g: Wire, c: Circuit): uint16 =
  c.eval(g.a)

method eval(g: AndGate, c: Circuit): uint16 =
  c.eval(g.a) and c.eval(g.b)

method eval(g: OrGate, c: Circuit): uint16 =
  c.eval(g.a) or c.eval(g.b)

method eval(g: NotGate, c: Circuit): uint16 =
  not c.eval(g.a)

method eval(g: LShiftGate, c: Circuit): uint16 =
  c.eval(g.a) shl g.n

method eval(g: RShiftGate, c: Circuit): uint16 =
  c.eval(g.a) shr g.n

proc addGate(self: var Circuit, gate: Gate) =
  self.cache[gate.output] = gate

proc eval(self: Circuit, output: string): uint16 =
  if output =~ re"\d+": return output.parseInt.uint16
  result = self.cache[output].eval(self)
  self.cache[output] = Wire(a: $result, output: output)

proc parseLine(line: string): Gate =
  if line =~ re"(\w+) -> (\w+)":
    Wire(a: matches[0], output: matches[1])
  elif line =~ re"(\w+) AND (\w+) -> (\w+)":
    AndGate(a: matches[0], b: matches[1], output: matches[2])
  elif line =~ re"(\w+) OR (\w+) -> (\w+)":
    OrGate(a: matches[0], b: matches[1], output: matches[2])
  elif line =~ re"NOT (\w+) -> (\w+)":
    NotGate(a: matches[0], output: matches[1])
  elif line =~ re"(\w+) LSHIFT (\d+) -> (\w+)":
    LShiftGate(a: matches[0], n: matches[1].parseInt, output: matches[2])
  elif line =~ re"(\w+) RSHIFT (\d+) -> (\w+)":
    RShiftGate(a: matches[0], n: matches[1].parseInt, output: matches[2])
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): Circuit =
  result.new
  result.cache = initTable[string, Gate]()
  for line in input.split("\n"):
    result.addGate(line.parseLine)

when defined(test):
  const test = """
  123 -> x
  456 -> y
  x AND y -> d
  x OR y -> e
  x LSHIFT 2 -> f
  y RSHIFT 2 -> g
  NOT x -> h
  NOT y -> i
  """.strip

  doAssert test.parse.eval("d") == 72
  doAssert test.parse.eval("e") == 507
  doAssert test.parse.eval("f") == 492
  doAssert test.parse.eval("g") == 114
  doAssert test.parse.eval("h") == 65412
  doAssert test.parse.eval("i") == 65079
  doAssert test.parse.eval("x") == 123
  doAssert test.parse.eval("y") == 456

proc part1(input: string): int =
  input.parse.eval("a").int

proc part2(input: string): int =
  let circuit = input.parse
  circuit.cache["b"] = Wire(a: $part1(input), output: "b")
  circuit.eval("a").int

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
