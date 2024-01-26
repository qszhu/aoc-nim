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
  Scanner = tuple[depth, `range`: int]

proc parseLine(line: string): Scanner =
  if line =~ re"(\d+): (\d+)":
    (depth: matches[0].parseInt, `range`: matches[1].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): seq[Scanner] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
0: 3
1: 2
4: 4
6: 4
""".strip
  block:
    let scanners = input.parse
    doAssert scanners[0] == (0, 3)
    doAssert scanners[1] == (1, 2)
    doAssert scanners[2] == (4, 4)
    doAssert scanners[3] == (6, 4)

proc pos(s: Scanner, t: int): int =
  let d = (s.`range` - 1) shl 1
  let r = t mod d
  if r <= s.`range` - 1: r
  else: d - r

when defined(test):
  block:
    doAssert (0 ..< 6).toSeq.mapIt((0, 3).pos(it)) == @[0, 1, 2, 1, 0, 1]
    doAssert (0 ..< 4).toSeq.mapIt((1, 2).pos(it)) == @[0, 1, 0, 1]
    doAssert (0 ..< 8).toSeq.mapIt((4, 4).pos(it)) == @[0, 1, 2, 3, 2, 1, 0, 1]

proc run(scanners: seq[Scanner], t = 0): seq[Scanner] =
  for (d, r) in scanners:
    let t1 = t + d
    let p = (d, r).pos(t1)
    if p == 0:
      result.add (d, r)

when defined(test):
  block:
    let scanners = input.parse
    doAssert scanners.run == @[(0, 3), (6, 4)]

proc part1(input: string): int =
  let scanners = input.parse
  scanners.run.mapIt(it[0] * it[1]).sum



when defined(test):
  block:
    let scanners = input.parse
    doAssert scanners.run(10) == @[]

proc part2(input: string): int =
  let scanners = input.parse
  while scanners.run(result).len != 0:
    result += 1



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
