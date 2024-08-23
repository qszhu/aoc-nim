import ../../lib/imports



proc parseMask(line: string): string =
  line.split(" = ")[1]

proc parseMem(line: string): (int64, int64) =
  if line =~ re"mem\[(\d+)\] = (\d+)":
    (matches[0].parseBiggestInt, matches[1].parseBiggestInt)
  else:
    raise newException(ValueError, "parse error: " & line)

type
  InstType {.pure.} = enum
    Mask
    Mem

  Inst = object
    case kind: InstType
    of InstType.Mask:
      mask: string
    of InstType.Mem:
      address: int64
      value: int64

proc parseLine(line: string): Inst =
  if line.startsWith("mask"):
    Inst(kind: InstType.Mask, mask: line.parseMask)
  else:
    let (address, value) = line.parseMem
    Inst(kind: InstType.Mem, address: address, value: value)

proc parse(input: string): seq[Inst] =
  input.split("\n").mapIt(it.parseLine)

proc applyMask(v: int64, m: string): int64 =
  result = v
  for i in countdown(35, 0):
    if m[i] == '0':
      result.clearBit(35 - i)
    elif m[i] == '1':
      result.setBit(35 - i)

proc run(mem: var Table[int64, int64], insts: seq[Inst]) =
  var mask: string
  for inst in insts:
    case inst.kind
    of InstType.Mask:
      mask = inst.mask
    of InstType.Mem:
      mem[inst.address] = applyMask(inst.value, mask)

proc part1(input: string): int64 =
  var mem = initTable[int64, int64]()
  mem.run(input.parse)
  mem.values.toSeq.sum

when defined(test):
  let input = """
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
""".strip
  block:
    doAssert part1(input) == 165



proc applyFloating(a: string, n: int): int64 =
  var a = a
  var n = n
  for i in countdown(35, 0):
    if a[i] != 'X': continue
    a[i] = if (n and 1) == 1: '1' else:'0'
    n = n shr 1
  a.fromBin[:int64]

iterator addresses(address: int64, mask: string): int64 =
  var a = address.toBin(36)
  for i, b in mask:
    if b != '0': a[i] = b
  let floating = a.count('X')
  for i in 0 ..< (1 shl floating):
    yield a.applyFloating(i)

proc run2(mem: var Table[int64, int64], insts: seq[Inst]) =
  var mask: string
  for inst in insts:
    case inst.kind
    of InstType.Mask:
      mask = inst.mask
    of InstType.Mem:
      for address in inst.address.addresses(mask):
        mem[address] = inst.value

proc part2(input: string): int64 =
  var mem = initTable[int64, int64]()
  mem.run2(input.parse)
  mem.values.toSeq.sum

when defined(test):
  let input2 = """
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
""".strip
  block:
    doAssert part2(input2) == 208



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
