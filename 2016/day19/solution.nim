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

import ../../lib/llrb



proc joseph(n: int): int =
  (n - (n.nextPowerOfTwo shr 1)) shl 1 + 1

when defined(test):
  block:
    doAssert joseph(5) == 3

proc part1(input: string): int =
  let n = input.parseInt
  joseph(n)

proc joseph2(n: int): int =
  var ol = newOrderedList[int]()
  for i in 1 .. n:
    ol.insert i
  while ol.len > 1:
    for i in ol.items:
      let j = (ol.find(i) + (ol.len shr 1)) mod ol.len
      ol.deleteAt(j)
  ol.getAt(0)

when defined(test):
  block:
    doAssert joseph2(5) == 2

proc part2(input: string): int =
  let n = input.parseInt
  joseph2(n)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
