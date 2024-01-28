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



proc next(a: var seq[int], cur: var int, steps: int) =
  let x = a.len
  cur = (cur + steps) mod a.len
  a = a[0 .. cur] & x & a[cur + 1 .. ^1]
  cur += 1

when defined(test):
  block:
    var (a, cur) = (@[0], 0)
    next(a, cur, 3)
    doAssert (a, cur) == (@[0, 1], 1)
    next(a, cur, 3)
    doAssert (a, cur) == (@[0, 2, 1], 1)
    next(a, cur, 3)
    doAssert (a, cur) == (@[0, 2, 3, 1], 2)

proc part1(input: string): int =
  let steps = input.parseInt
  var (a, cur) = (@[0], 0)
  for i in 1 .. 2017:
    next(a, cur, steps)
  a[a.find(2017) + 1]

when defined(test):
  block:
    doAssert part1("3") == 638

proc part2(input: string): int =
  let steps = input.parseInt
  var cur = 0
  var l = 1
  for i in 1 .. 5e7.int:
    cur = (cur + steps) mod l + 1
    l += 1
    if cur == 1: result = i



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
