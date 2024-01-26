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

import ../day10/solution
import ../../lib/grid



proc toBin(h: string): string =
  h.toSeq.mapIt(fromHex[int]($it).toBin(4)).join

when defined(test):
  let input = "flqrgnkx"
  block:
    doAssert hash(&"{input}-0").toBin[0 ..< 8] == "11010100"

proc genGrid(key: string): seq[string] =
  for r in 0 ..< 128:
    result.add hash(&"{key}-{r}").toBin

proc part1(input: string): int =
  for b in genGrid(input):
    result += b.toSeq.countIt(it == '1')

when defined(test):
  block:
    doAssert part1(input) == 8108



proc part2(input: string): int =
  var grid = genGrid(input).mapIt(it.toSeq)
  for r in 0 ..< grid.len:
    for c in 0 ..< grid[r].len:
      if grid[r][c] == '0': continue
      result += 1
      floodfill(grid, r, c, '1', '0')

when defined(test):
  block:
    doAssert part2(input) == 1242



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
