import ../../lib/imports



type
  InstMode = enum
    ModePosition
    ModeImmediate

  Inst = tuple[op: int, modes: array[3, InstMode]]

proc parseInst(n: int): Inst =
  (
    op: n mod 100,
    modes: [
      (n mod 1000 div 100).InstMode,
      (n mod 10000 div 1000).InstMode,
      (n mod 100000 div 10000).InstMode,
    ]
  )

type
  Program = ref object
    mem: seq[int]
    input: int
    outputs: seq[int]
    ip: int

proc newProgram(mem: seq[int]): Program =
  result.new
  result.mem = mem

proc run(self: Program) =
  var inst: Inst
  proc getParam(i: int, write = false): int =
    let v = self.mem[self.ip + i]
    case inst.modes[i - 1]
    of ModeImmediate:
      v
    of ModePosition:
      if write: v else: self.mem[v]

  while true:
    if self.mem[self.ip] == 99: return
    inst = self.mem[self.ip].parseInst
    case inst.op:
    of 1:
      let a = getParam(1)
      let b = getParam(2)
      let c = getParam(3, write = true)
      self.mem[c] = a + b
      self.ip += 4
    of 2:
      let a = getParam(1)
      let b = getParam(2)
      let c = getParam(3, write = true)
      self.mem[c] = a * b
      self.ip += 4
    of 3:
      let a = getParam(1, write = true)
      self.mem[a] = self.input
      self.ip += 2
    of 4:
      let a = getParam(1)
      self.outputs.add a
      self.ip += 2
    of 5:
      let a = getParam(1)
      let b = getParam(2)
      if a != 0:
        self.ip = b
      else:
        self.ip += 3
    of 6:
      let a = getParam(1)
      let b = getParam(2)
      if a == 0:
        self.ip = b
      else:
        self.ip += 3
    of 7:
      let a = getParam(1)
      let b = getParam(2)
      let c = getParam(3, write = true)
      self.mem[c] = if a < b: 1 else: 0
      self.ip += 4
    of 8:
      let a = getParam(1)
      let b = getParam(2)
      let c = getParam(3, write = true)
      self.mem[c] = if a == b: 1 else: 0
      self.ip += 4
    else:
      raise newException(ValueError, &"unknown op: {inst.op}")

proc parse(input: string): Program =
  input.split(",").mapIt(it.parseInt).newProgram

when defined(test):
  block:
    let input = """
1002,4,3,4,33
""".strip
    var prog = input.parse
    prog.run
    doAssert prog.mem[^1] == 99
  block:
    let input = """
1101,100,-1,4,0
""".strip
    var prog = input.parse
    prog.run
    doAssert prog.mem[^1] == 99

proc part1(input: string): int =
  let prog = input.parse
  prog.input = 1
  prog.run
  # for o in prog.outputs: echo o
  prog.outputs[^1]



when defined(test):
  block:
    for input in @["""
3,9,8,9,10,9,4,9,99,-1,8
""".strip, """
3,3,1108,-1,8,3,4,3,99
""".strip, """
3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9
""".strip, """
3,3,1105,-1,9,1101,0,0,12,4,12,99,1
""".strip]:
      block:
        let prog = input.parse
        prog.run
        doAssert prog.outputs == @[0]
      block:
        let prog = input.parse
        prog.input = 8
        prog.run
        doAssert prog.outputs == @[1]
  block:
    for input in @["""
3,9,7,9,10,9,4,9,99,-1,8
""".strip, """
3,3,1107,-1,8,3,4,3,99
""".strip]:
      block:
        let prog = input.parse
        prog.run
        doAssert prog.outputs == @[1]
      block:
        let prog = input.parse
        prog.input = 8
        prog.run
        doAssert prog.outputs == @[0]
  block:
    let input = """
3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
""".strip
    block:
      let prog = input.parse
      prog.input = 7
      prog.run
      doAssert prog.outputs == @[999]
    block:
      let prog = input.parse
      prog.input = 8
      prog.run
      doAssert prog.outputs == @[1000]
    block:
      let prog = input.parse
      prog.input = 9
      prog.run
      doAssert prog.outputs == @[1001]

proc part2(input: string): int =
  let prog = input.parse
  prog.input = 5
  prog.run
  # for o in prog.outputs: echo o
  prog.outputs[^1]



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
