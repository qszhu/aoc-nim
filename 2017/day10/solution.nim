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



proc step(a: var seq[int], l: int, cur, skip: var int) =
  let N = a.len
  var s = newSeq[int](l)
  for i in 0 ..< l:
    s[i] = a[(cur + i) mod N]
  s.reverse
  for i in 0 ..< l:
    a[(cur + i) mod N] = s[i]
  cur = (cur + l + skip) mod N
  skip += 1

when defined(test):
  block:
    var a = (0 ..< 5).toSeq
    var cur, skip = 0

    step(a, 3, cur, skip)
    doAssert a == @[2, 1, 0, 3, 4]
    doAssert cur == 3
    doAssert skip == 1

    step(a, 4, cur, skip)
    doAssert a == @[4, 3, 0, 1, 2]
    doAssert cur == 3
    doAssert skip == 2

    step(a, 1, cur, skip)
    doAssert a == @[4, 3, 0, 1, 2]
    doAssert cur == 1
    doAssert skip == 3

    step(a, 5, cur, skip)
    doAssert a == @[3, 4, 2, 1, 0]
    doAssert cur == 4
    doAssert skip == 4

proc part1(input: string): int =
  let lens = input.split(",").mapIt(it.parseInt)
  var a = (0 ..< 256).toSeq
  var cur, skip = 0
  for l in lens:
    step(a, l, cur, skip)
  a[0] * a[1]



proc getLens(input: string): seq[int] =
  input.mapIt(it.ord) & @[17, 31, 73, 47, 23]

when defined(test):
  block:
    doAssert getLens("1,2,3") == @[49, 44, 50, 44, 51, 17, 31, 73, 47, 23]

proc hash(input: string): string =
  let lens = getLens(input)
  var a = (0 ..< 256).toSeq
  var cur, skip = 0
  for _ in 0 ..< 64:
    for l in lens:
      step(a, l, cur, skip)
  countup(0, 255, 16).toSeq
    .mapIt(
      a[it ..< it + 16].foldl(a xor b).toHex(2).toLowerAscii)
    .join

when defined(test):
  block:
    doAssert hash("") == "a2582a3a0e66e6e86e3812dcb672a272"
    doAssert hash("AoC 2017") == "33efeb34ea91902bb2f59c9920caa6cd"
    doAssert hash("1,2,3") == "3efbe78a8d82f29979031a4aa0b16a9d"
    doAssert hash("1,2,4") == "63960835bcdc130f0b66d7ff4f6a5a8e"

proc part2(input: string): string =
  input.hash



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
