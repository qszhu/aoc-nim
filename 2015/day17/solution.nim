import std/[
  algorithm,
  bitops,
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



proc countWays(capacities: seq[int], target: int): int =
  let N = capacities.len
  for i in 0 ..< (1 shl N):
    var s = 0
    for j in 0 ..< N:
      if not i.testBit(j): continue
      s += capacities[j]
    if s == target: result += 1

when defined(test):
  doAssert countWays(@[20, 15, 10, 5, 5], 25) == 4

proc part1(input: string): int =
  let capacities = input.split("\n").mapIt(it.parseInt)
  countWays(capacities, 150)

proc countWays2(capacities: seq[int], target: int): int =
  let N = capacities.len
  var minCnt = int.high
  for i in 0 ..< (1 shl N):
    var s = 0
    for j in 0 ..< N:
      if not i.testBit(j): continue
      s += capacities[j]
    if s == target:
      let c = i.countSetBits
      if minCnt > c:
        minCnt = c
        result = 1
      elif minCnt == c:
        result += 1

when defined(test):
  doAssert countWays2(@[20, 15, 10, 5, 5], 25) == 3

proc part2(input: string): int =
  let capacities = input.split("\n").mapIt(it.parseInt)
  countWays2(capacities, 150)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
