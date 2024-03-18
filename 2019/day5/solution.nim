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
  Inst = tuple[op: int, modes: seq[int]]

proc parseInst(n: int): Inst =
  (
    op: n mod 100,
    modes: @[
      n mod 1000 div 100,
      n mod 10000 div 1000,
      n mod 100000 div 10000,
    ],
  )

type
  Program = seq[int]

const MODE_POS = 0
const MODE_IMD = 1

proc run(prog: Program, input: int, outputs: var seq[int]): Program =
  var res = prog
  var ip = 0

  proc getValue(modes: seq[int], i: int): int =
    let t = ip + i
    let v = res[t]
    if modes[i - 1] == MODE_IMD: v
    else: res[v]

  while true:
    if res[ip] == 99: return res
    let (op, modes) = res[ip].parseInst
    case op:
    of 1:
      let a = getValue(modes, 1)
      let b = getValue(modes, 2)
      let c = res[ip + 3]
      res[c] = a + b
      ip += 4
    of 2:
      let a = getValue(modes, 1)
      let b = getValue(modes, 2)
      let c = res[ip + 3]
      res[c] = a * b
      ip += 4
    of 3:
      let a = res[ip + 1]
      res[a] = input
      ip += 2
    of 4:
      let a = getValue(modes, 1)
      outputs.add a
      ip += 2
    of 5:
      let a = getValue(modes, 1)
      let b = getValue(modes, 2)
      if a != 0:
        ip = b
      else:
        ip += 3
    of 6:
      let a = getValue(modes, 1)
      let b = getValue(modes, 2)
      if a == 0:
        ip = b
      else:
        ip += 3
    of 7:
      let a = getValue(modes, 1)
      let b = getValue(modes, 2)
      let c = res[ip + 3]
      res[c] = if a < b: 1 else: 0
      ip += 4
    of 8:
      let a = getValue(modes, 1)
      let b = getValue(modes, 2)
      let c = res[ip + 3]
      res[c] = if a == b: 1 else: 0
      ip += 4
    else:
      raise newException(ValueError, &"unknown op: {op}")

proc parse(input: string): Program =
  input.split(",").mapIt(it.parseInt)

when defined(test):
  block:
    let input = """
1002,4,3,4,33
""".strip
    var prog = input.parse
    var outputs: seq[int]
    prog = prog.run(0, outputs)
    doAssert prog[^1] == 99
  block:
    let input = """
1101,100,-1,4,0
""".strip
    var prog = input.parse
    var outputs: seq[int]
    prog = prog.run(0, outputs)
    doAssert prog[^1] == 99

proc part1(input: string): int =
  var outputs: seq[int]
  discard input.parse.run(1, outputs)
  # echo outputs
  outputs[^1]

when defined(test):
  block:
    let input = """
3,9,8,9,10,9,4,9,99,-1,8
""".strip
    var prog = input.parse
    block:
      var outputs: seq[int]
      discard prog.run(0, outputs)
      doAssert outputs == @[0]
    block:
      var outputs: seq[int]
      discard prog.run(8, outputs)
      doAssert outputs == @[1]
  block:
    let input = """
3,9,7,9,10,9,4,9,99,-1,8
""".strip
    var prog = input.parse
    block:
      var outputs: seq[int]
      discard prog.run(0, outputs)
      doAssert outputs == @[1]
    block:
      var outputs: seq[int]
      discard prog.run(8, outputs)
      doAssert outputs == @[0]
  block:
    let input = """
3,3,1108,-1,8,3,4,3,99
""".strip
    var prog = input.parse
    block:
      var outputs: seq[int]
      discard prog.run(0, outputs)
      doAssert outputs == @[0]
    block:
      var outputs: seq[int]
      discard prog.run(8, outputs)
      doAssert outputs == @[1]
  block:
    let input = """
3,3,1107,-1,8,3,4,3,99
""".strip
    var prog = input.parse
    block:
      var outputs: seq[int]
      discard prog.run(0, outputs)
      doAssert outputs == @[1]
    block:
      var outputs: seq[int]
      discard prog.run(8, outputs)
      doAssert outputs == @[0]
  block:
    let input = """
3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9
""".strip
    var prog = input.parse
    block:
      var outputs: seq[int]
      discard prog.run(0, outputs)
      doAssert outputs == @[0]
    block:
      var outputs: seq[int]
      discard prog.run(8, outputs)
      doAssert outputs == @[1]
  block:
    let input = """
3,3,1105,-1,9,1101,0,0,12,4,12,99,1
""".strip
    var prog = input.parse
    block:
      var outputs: seq[int]
      discard prog.run(0, outputs)
      doAssert outputs == @[0]
    block:
      var outputs: seq[int]
      discard prog.run(8, outputs)
      doAssert outputs == @[1]
  block:
    let input = """
3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
""".strip
    var prog = input.parse
    block:
      var outputs: seq[int]
      discard prog.run(7, outputs)
      doAssert outputs == @[999]
    block:
      var outputs: seq[int]
      discard prog.run(8, outputs)
      doAssert outputs == @[1000]
    block:
      var outputs: seq[int]
      discard prog.run(9, outputs)
      doAssert outputs == @[1001]

proc part2(input: string): int =
  var outputs: seq[int]
  discard input.parse.run(5, outputs)
  # echo outputs
  outputs[^1]



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
