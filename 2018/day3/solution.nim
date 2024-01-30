import std/[
  algorithm,
  bitops,
  deques,
  intsets,
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

import ../../lib/imos



type
  Claim = tuple[id: string, left, top, width, height: int]

proc parseLine(line: string): Claim =
  if line =~ re"#(\w+) @ (\d+),(\d+): (\d+)x(\d+)":
    (matches[0], matches[1].parseInt, matches[2].parseInt, matches[3].parseInt, matches[4].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert "#1 @ 1,3: 4x4".parseLine == ("1", 1, 3, 4, 4)

proc parse(input: string): seq[Claim] =
  input.split("\n").mapIt(it.parseLine)

proc fillGrid(claims: seq[Claim], size: int): seq[seq[int]] =
  var imos = initImos[int](size, size)
  for (_, left, top, width, height) in claims:
    imos.addRect(left, top, left + width - 1, top + height - 1)
  imos.restore

const MAXN = 1000

proc part1(input: string): int =
  let grid = input.parse.fillGrid(MAXN)
  for r in 0 ..< MAXN:
    for c in 0 ..< MAXN:
      if grid[r][c] > 1: result += 1

when defined(test):
  let input = """
#1 @ 1,3: 4x4
#2 @ 3,1: 4x4
#3 @ 5,5: 2x2
""".strip
  block:
    doAssert part1(input) == 4

proc check(grid: var seq[seq[int]], claim: Claim): bool =
  let (_, left, top, width, height) = claim
  for r in left ..< left + width:
    for c in top ..< top + height:
      if grid[r][c] > 1: return false
  true


proc part2(input: string): string =
  let claims = input.parse
  var grid = input.parse.fillGrid(MAXN)
  for claim in claims:
    if grid.check(claim): return claim.id

when defined(test):
  block:
    doAssert part2(input) == "3"



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
