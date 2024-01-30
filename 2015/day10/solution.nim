import std/[
  algorithm,
  bitops,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]



iterator rle*[T](x: var openArray[T]): (T, int) =
  var c = 0
  for i in 0 ..< x.len:
    c += 1
    if i + 1 == x.len or x[i + 1] != x[i]:
      yield (x[i], c)
      c = 0

proc next(s: string): string =
  var s = s.toSeq
  s.rle.toSeq.mapIt(&"{it[1]}{it[0]}").join

when defined(test):
  doAssert next("1") == "11"
  doAssert next("11") == "21"
  doAssert next("21") == "1211"
  doAssert next("1211") == "111221"
  doAssert next("111221") == "312211"

proc calc(s: string, iters: int): int =
  var s = s
  for _ in 0 ..< iters:
    s = s.next
  s.len

proc part1(input: string): int =
  calc(input, 40)

proc part2(input: string): int =
  calc(input, 50)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
