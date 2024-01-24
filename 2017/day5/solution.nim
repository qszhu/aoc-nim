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



proc parse(input: string): seq[int] =
  input.split("\n").mapIt(it.parseInt)

proc run(insts: var seq[int]): int =
  var ip = 0
  while ip in 0 ..< insts.len:
    let nip = ip + insts[ip]
    insts[ip] += 1
    ip = nip
    result += 1

when defined(test):
  let input = """
0
3
0
1
-3
""".strip
  block:
    var insts = input.parse
    doAssert insts.run == 5

proc part1(input: string): int =
  var insts = input.parse
  insts.run



proc run2(insts: var seq[int]): int =
  var ip = 0
  while ip in 0 ..< insts.len:
    let nip = ip + insts[ip]
    if insts[ip] >= 3: insts[ip] -= 1
    else: insts[ip] += 1
    ip = nip
    result += 1

when defined(test):
  block:
    var insts = input.parse
    doAssert insts.run2 == 10
    doAssert insts == @[2, 3, 2, 3, -1]

proc part2(input: string): int =
  var insts = input.parse
  insts.run2



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
