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



proc run(a, b, n: int): seq[int] =
  var r = @[a, b]
  var i = 0
  var j = 1
  while r.len < n + 10:
    let d = r[i] + r[j]
    if d >= 10: r.add d div 10
    r.add d mod 10
    i = (i + r[i] + 1) mod r.len
    j = (j + r[j] + 1) mod r.len
  r

proc part1(input: string): string =
  let n = input.parseInt
  let r = run(3, 7, n + 10)
  r[n ..< n + 10].join

when defined(test):
  block:
    doAssert part1("9") == "5158916779"
    doAssert part1("5") == "0124515891"
    doAssert part1("18") == "9251071085"
    doAssert part1("2018") == "5941429882"



proc run2(a, b: int, n: string): int =
  var r = @[a, b]
  var i = 0
  var j = 1
  while true:
    if r.len >= n.len:
      if r[^n.len .. ^1].join == n: return r.len - n.len
    if r.len - 1 >= n.len:
      if r[^(n.len + 1) .. ^2].join == n: return r.len - 1 - n.len
    let d = r[i] + r[j]
    if d >= 10: r.add d div 10
    r.add d mod 10
    i = (i + r[i] + 1) mod r.len
    j = (j + r[j] + 1) mod r.len

proc part2(input: string): int =
  run2(3, 7, input)

when defined(test):
  block:
    doAssert part2("51589") == 9
    doAssert part2("01245") == 5
    doAssert part2("92510") == 18
    doAssert part2("59414") == 2018



when isMainModule and not defined(test):
  let input = readFile("input")
  echo part1(input)
  echo part2(input)
