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



proc redistribute(a: var seq[int]) =
  var i = a.find(a.max)
  var r = a[i]
  a[i] = 0
  while r > 0:
    i = (i + 1) mod a.len
    a[i] += 1
    r -= 1

when defined(test):
  block:
    var a = @[0, 2, 7, 0]
    a.redistribute
    doAssert a == @[2, 4, 1, 2]
    a.redistribute
    doAssert a == @[3, 1, 2, 3]
    a.redistribute
    doAssert a == @[0, 2, 3, 4]
    a.redistribute
    doAssert a == @[1, 3, 4, 1]
    a.redistribute
    doAssert a == @[2, 4, 1, 2]

proc parse(input: string): seq[int] =
  input.split(re"\s+").mapIt(it.parseInt)

proc findCycle(a: var seq[int]): (int, int) =
  var seen = initTable[seq[int], int]()
  while a notin seen:
    seen[a] = seen.len
    a.redistribute
  (seen.len, seen.len - seen[a])

proc part1(input: string): int =
  var a = input.parse
  let (l, _) = a.findCycle
  return l

when defined(test):
  block:
    doAssert part1("0 2 7 0") == 5

proc part2(input: string): int =
  var a = input.parse
  let (_, c) = a.findCycle
  return c



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
