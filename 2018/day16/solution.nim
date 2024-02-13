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
  Registers = array[4, int]

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

type
  Inst = tuple[opcode, a, b, c: int]

proc parseBlock(b: string): (Registers, Inst, Registers) =
  let lines = b.strip.split("\n")
  if lines[0] =~ re"Before: \[(\d+), (\d+), (\d+), (\d+)\]":
    let m = matches[0 ..< 4].mapIt(it.parseInt)
    let before = [m[0], m[1], m[2], m[3]]
    if lines[1] =~ re"(\d+) (\d+) (\d+) (\d+)":
      let m = matches[0 ..< 4].mapIt(it.parseInt)
      let inst = (m[0], m[1], m[2], m[3])
      if lines[2] =~ re"After:  \[(\d+), (\d+), (\d+), (\d+)\]":
        let m = matches[0 ..< 4].mapIt(it.parseInt)
        let after = [m[0], m[1], m[2], m[3]]
        return (before, inst, after)

when defined(test):
  let input = """
Before: [3, 2, 1, 1]
9 2 1 2
After:  [3, 2, 2, 1]
""".strip
  block:
    doAssert input.parseBlock == ([3, 2, 1, 1], (9, 2, 1, 2), [3, 2, 2, 1])

proc isValid(before: Registers, inst: Inst, after: Registers, instName: string): bool =
  let (_, a, b, c) = inst
  exec(before, instName, a, b, c) == after

when defined(test):
  block:
    let (before, inst, after) = input.parseBlock
    doAssert isValid(before, inst, after, "mulr")
    doAssert isValid(before, inst, after, "addi")
    doAssert isValid(before, inst, after, "seti")
    doAssert not isValid(before, inst, after, "addr")

proc validInsts(before: Registers, inst: Inst, after: Registers): seq[string] =
  @["addr", "addi", "mulr", "muli", "banr", "bani", "borr", "bori",
    "setr", "seti", "gtir", "gtri", "gtrr", "eqir", "eqri", "eqrr"]
    .filterIt(isValid(before, inst, after, it))

when defined(test):
  block:
    let (before, inst, after) = input.parseBlock
    doAssert validInsts(before, inst, after).len == 3

proc parse(input: string): (seq[(Registers, Inst, Registers)], seq[Inst]) =
  let p = input.split("\n\n\n\n")
  let blocks = p[0].strip.split("\n\n").mapIt(it.parseBlock)
  let insts = p[1].strip.split("\n").mapIt(it.split(" "))
    .mapIt((it[0].parseInt, it[1].parseInt, it[2].parseInt, it[3].parseInt))
  (blocks, insts)

proc part1(input: string): int =
  let (blocks, _) = input.parse
  for (before, inst, after) in blocks:
    if validInsts(before, inst, after).len >= 3: result += 1



proc findAssignment(blocks: seq[(Registers, Inst, Registers)]): seq[string] =
  var res = newSeq[string](16)
  proc search(i: int): bool =
    if i >= blocks.len: return true
    let (before, inst, after) = blocks[i]
    if res[inst[0]] != "": return search(i + 1)
    for cand in validInsts(before, inst, after):
      if cand in res: continue
      res[inst[0]] = cand
      if search(i + 1): return true
      res[inst[0]] = ""
  doAssert search(0)
  res

proc part2(input: string): int =
  let (blocks, insts) = input.parse
  let instNames = findAssignment(blocks)
  var regs: array[4, int]
  for (op, a, b, c) in insts:
    regs = exec(regs, instNames[op], a, b, c)
  regs[0]



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
