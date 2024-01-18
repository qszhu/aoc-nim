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
  Disc = (int, int)

proc parseLine(line: string): Disc =
  if line =~ re"Disc #\d+ has (\d+) positions; at time=0, it is at position (\d+).":
    (matches[0].parseInt, matches[1].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  let input = """
Disc #1 has 5 positions; at time=0, it is at position 4.
Disc #2 has 2 positions; at time=0, it is at position 1.
""".strip
  let lines = input.split("\n")
  block:
    doAssert parseLine(lines[0]) == (5, 4)
    doAssert parseLine(lines[1]) == (2, 1)

proc parse(input: string): seq[Disc] =
  for line in input.split("\n"):
    let (a, b) = parseLine(line)
    result.add (a, b)

when defined(test):
  block:
    doAssert parse(input) == @[(5, 4), (2, 1)]

#[
0 1 2 3 4 5 6 7
4 0 1 2 3 4 0 1
1 0 1 0 1 0 1 0
          ^
]#
proc getDiscPos(d: Disc, t: int): int =
  let (s, o) = d
  (t mod s + o) mod s

when defined(test):
  block:
    doAssert (0 .. 7).toSeq.mapIt(getDiscPos((5, 4), it)) == @[4, 0, 1, 2, 3, 4, 0, 1]
    doAssert (0 .. 7).toSeq.mapIt(getDiscPos((2, 1), it)) == @[1, 0, 1, 0, 1, 0, 1, 0]

proc check(discs: seq[Disc], t: int): bool =
  for i, d in discs:
    if getDiscPos(d, t + i) != 0: return false
  true

proc calc(discs: seq[Disc]): int =
  let (a, b) = discs[0]
  var i = a - b
  while not check(discs, i):
    i += a
  i - 1

proc part1(input: string): int =
  let discs = input.parse
  calc(discs)

when defined(test):
  block:
    doAssert part1(input) == 5

proc part2(input: string): int =
  let discs = input.parse & (11, 0)
  calc(discs)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
