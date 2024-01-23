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



proc check(n: int): bool =
  let x = n xor (n shr 1)
  (x and (x + 1)) == 0 and n mod 2 == 0

proc part1(input: string): int =
  let lines = input.split("\n")
  let c = lines[1].split(" ")[1].parseInt
  let b = lines[2].split(" ")[1].parseInt
  var a = 0
  while true:
    if check(a + b * c): return a
    a += 1

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
