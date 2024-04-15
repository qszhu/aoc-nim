import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  options,
  os,
  rdstdin,
  re,
  sequtils,
  sets,
  streams,
  strformat,
  strutils,
  tables,
  threadpool,
  sugar,
]



const PAT = [0, 1, 0, -1]

iterator pattern(p: int): int {.closure.} =
  var i, c = 0
  while true:
    yield PAT[i]
    c += 1
    if c == p:
      c = 0
      i = (i + 1) mod PAT.len

proc step(a: seq[int]): seq[int] =
  for i in 1 .. a.len:
    var s = 0
    var p = pattern
    discard p(i)
    for x in a:
      let t = p(i)
      s += x * t
    result.add s.abs mod 10

when defined(test):
  block:
    var a = @[1,2,3,4,5,6,7,8]
    a = a.step
    doAssert a == @[4,8,2,2,6,1,5,8]
    a = a.step
    doAssert a == @[3,4,0,4,0,4,3,8]
    a = a.step
    doAssert a == @[0,3,4,1,5,5,1,8]
    a = a.step
    doAssert a == @[0,1,0,2,9,4,9,8]

proc part1(input: string): string =
  var a = input.mapIt(it.ord - '0'.ord)
  for _ in 0 ..< 100:
    a = a.step
  a[0 ..< 8].join

when defined(test):
  block:
    doAssert part1("80871224585914546619083218645595") == "24176176"
    doAssert part1("19617804207202209144916044189917") == "73745418"
    doAssert part1("69317163492948606335995924319873") == "52432133"

proc part2(input: string): string =
  let offset = input[0 ..< 7].parseInt
  var a = input.repeat(10000).mapIt(it.ord - '0'.ord)
  let N = a.len
  for _ in 0 ..< 100:
    var d = 0
    for i in countdown(N - 1, offset):
      a[i] = (a[i] + d) mod 10
      d = a[i]
  a[offset ..< offset + 8].join

when defined(test):
  block:
    doAssert part2("03036732577212944063491565474664") == "84462026"
    doAssert part2("02935109699940807407585447034323") == "78725270"
    doAssert part2("03081770884921959731165446850517") == "53553731"



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
