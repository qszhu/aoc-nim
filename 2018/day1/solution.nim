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



proc parse(input: string): seq[int] =
  input.split("\n").mapIt(it.parseInt)

proc run(a: seq[int]): int =
  a.sum

when defined(test):
  block:
    doAssert run(@[+1, -2, +3, +1]) == 3
    doAssert run(@[+1, +1, +1]) == 3
    doAssert run(@[+1, +1, -2]) == 0
    doAssert run(@[-1, -2, -3]) == -6

proc part1(input: string): int =
  input.parse.run



proc run2(a: seq[int]): int =
  var seen = initIntSet()
  var x, i = 0
  while x notin seen:
    seen.incl x
    x += a[i]
    i = (i + 1) mod a.len
  x

when defined(test):
  block:
    doAssert run2(@[+1, -2, +3, +1]) == 2
    doAssert run2(@[+1, -1]) == 0
    doAssert run2(@[+3, +3, +4, -2, -4]) == 10
    doAssert run2(@[-6, +3, +8, +5, -6]) == 5
    doAssert run2(@[+7, +7, -2, -7, -4]) == 14

proc part2(input: string): int =
  input.parse.run2



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
