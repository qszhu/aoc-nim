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



proc part1(input: string): int =
  let lines = input.split("\n")
  var a = lines[0].split(" ")[1].parseInt
  var b = lines[1].split(" ")[1].parseInt
  var d = lines[2].split(" ")[1].parseInt
  for _ in 0 ..< d:
    let c = a
    a += b
    b = c
  var c = lines[16].split(" ")[1].parseInt
  d = lines[17].split(" ")[1].parseInt
  a += c * d
  a

proc part2(input: string): int =
  let lines = input.split("\n")
  var a = lines[0].split(" ")[1].parseInt
  var b = lines[1].split(" ")[1].parseInt
  var d = lines[2].split(" ")[1].parseInt
  var c = lines[5].split(" ")[1].parseInt
  d += 7
  for _ in 0 ..< d:
    c = a
    a += b
    b = c
  c = lines[16].split(" ")[1].parseInt
  d = lines[17].split(" ")[1].parseInt
  a += c * d
  a



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
