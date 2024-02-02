import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]

import ../../lib/grid



proc powerLevel(x, y, serial: int): int =
  let rackId = x + 10
  result = rackId * y
  result += serial
  result *= rackId
  result = result mod 1000 div 100
  result -= 5

when defined(test):
  block:
    doAssert powerLevel(3, 5, 8) == 4
    doAssert powerLevel(122, 79, 57) == -5
    doAssert powerLevel(217, 196, 39) == 0
    doAssert powerLevel(101, 153, 71) == 4

proc genGrid(serial, size: int): seq[seq[int]] =
  result = newSeqWith(size, newSeq[int](size))
  for r in 0 ..< size:
    for c in 0 ..< size:
      result[r][c] = powerLevel(c + 1, r + 1, serial)

proc maxPos(grid: var seq[seq[int]], size = 3): (int, int, int) =
  var preSum = prefixSum(grid)
  let (rows, cols) = (grid.len, grid[0].len)
  var maxPower = 0
  for r in 0 ..< rows:
    if r + size > rows: break
    for c in 0 ..< cols:
      if c + size > cols: break
      let power = preSum.blockSum(r, c, r + size - 1, c + size - 1)
      if maxPower < power:
        maxPower = power
        result = (maxPower, c + 1, r + 1)

proc part1(input: string): (int, int) =
  let serial = input.parseInt
  var grid = genGrid(serial, 300)
  let (_, x, y) = maxPos(grid)
  (x, y)

when defined(test):
  block:
    doAssert part1("18") == (33, 45)
    doAssert part1("42") == (21, 61)



proc part2(input: string): (int, int, int) =
  let serial = input.parseInt
  var grid = genGrid(serial, 300)
  var maxPower = 0
  for size in 1 .. 300:
    let (power, x, y) = maxPos(grid, size)
    if maxPower < power:
      maxPower = power
      result = (x, y, size)

when defined(test):
  block:
    doAssert part2("18") == (90, 269, 16)
    doAssert part2("42") == (232, 251, 12)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
