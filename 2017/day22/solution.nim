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
  Locations = HashSet[(int, int)]

proc parse(input: string): (int, int, Locations) =
  var infected = initHashSet[(int, int)]()
  let lines = input.split("\n")
  let (rows, cols) = (lines.len, lines[0].len)
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      if lines[r][c] == '#':
        infected.incl (r, c)
  (rows shr 1, cols shr 1, infected)

when defined(test):
  let input = """
..#
#..
...
""".strip
  block:
    doAssert input.parse == (1, 1, @[(0, 2), (1, 0)].toHashSet)

const dPos = [(-1, 0), (0, 1), (1, 0), (0, -1)]

proc run(infected: Locations, r, c, n: int): int =
  var infected = infected
  var (r, c) = (r, c)
  var d = 0
  for _ in 0 ..< n:
    if (r, c) in infected:
      d = (d + 1) mod 4
    else:
      d = (d - 1 + 4) mod 4
    if (r, c) notin infected:
      infected.incl (r, c)
      result += 1
    else:
      infected.excl (r, c)
    let (dr, dc) = dPos[d]
    (r, c) = (r + dr, c + dc)

when defined(test):
  block:
    let (r, c, infected) = input.parse
    doAssert run(infected, r, c, 7) == 5
    doAssert run(infected, r, c, 70) == 41
    doAssert run(infected, r, c, 10000) == 5587

proc part1(input: string): int =
    let (r, c, infected) = input.parse
    run(infected, r, c, 10000)



proc run2(infected: Locations, r, c, n: int): int =
  var infected = infected
  var weakened, flagged = initHashSet[(int, int)]()
  var (r, c) = (r, c)
  var d = 0
  for _ in 0 ..< n:
    if (r, c) in weakened:
      discard
    elif (r, c) in infected:
      d = (d + 1) mod 4
    elif (r, c) in flagged:
      d = (d + 2) mod 4
    else:
      d = (d - 1 + 4) mod 4

    if (r, c) in weakened:
      weakened.excl (r, c)
      infected.incl (r, c)
      result += 1
    elif (r, c) in infected:
      infected.excl (r, c)
      flagged.incl (r, c)
    elif (r, c) in flagged:
      flagged.excl (r, c)
    else:
      weakened.incl (r, c)

    let (dr, dc) = dPos[d]
    (r, c) = (r + dr, c + dc)

when defined(test):
  block:
    let (r, c, infected) = input.parse
    doAssert run2(infected, r, c, 100) == 26
    doAssert run2(infected, r, c, 10000000) == 2511944

proc part2(input: string): int =
    let (r, c, infected) = input.parse
    run2(infected, r, c, 10000000)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
