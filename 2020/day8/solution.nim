import ../../lib/imports



type
  Inst = (string, int)

proc parseLine(line: string): Inst =
  let p = line.split(" ")
  (p[0], p[1].parseInt)

proc parse(input: string): seq[Inst] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
""".strip
  block:
    let insts = input.parse
    doAssert insts[^1] == ("acc", 6)
    doAssert insts[^2] == ("jmp", -4)

proc run(insts: seq[Inst]): (bool, int) =
  var a, ip = 0
  var seen = newSeq[bool](insts.len)
  while ip < insts.len:
    if seen[ip]: return (false, a)
    seen[ip] = true
    let (name, x) = insts[ip]
    case name
    of "acc":
      a += x
      ip += 1
    of "jmp":
      ip += x
    of "nop":
      ip += 1
  (true, a)

proc part1(input: string): int =
  input.parse.run[1]

when defined(test):
  block:
    doAssert part1(input) == 5



iterator tryRestore(input: string): seq[Inst] =
  var insts = input.parse
  for i in 0 ..< insts.len:
    if insts[i][0] == "jmp":
      insts[i][0] = "nop"
      yield insts
      insts[i][0] = "jmp"
    elif insts[i][0] == "nop":
      insts[i][0] = "jmp"
      yield insts
      insts[i][0] = "nop"

proc part2(input: string): int =
  for insts in input.tryRestore:
    let (r, a) = insts.run
    if r: return a

when defined(test):
  block:
    doAssert part2(input) == 8



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
