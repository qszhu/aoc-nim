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



#[
  1 2 3 4 5 6 7 8 9
1 x x x x x x x x x
2   x   x   x   x
3     x     x     x
4       x       x
5         x
6           x
7             x
8               x
9                 x
]#
proc calc(n: int): int =
  var p = 1
  while p * p <= n:
    if n mod p == 0:
      result += p
      let q = n div p
      if p != q: result += q
    p += 1
  result *= 10

when defined(test):
  doAssert calc(1) == 10
  doAssert calc(2) == 30
  doAssert calc(3) == 40
  doAssert calc(4) == 70
  doAssert calc(5) == 60
  doAssert calc(6) == 120
  doAssert calc(7) == 80
  doAssert calc(8) == 150
  doAssert calc(9) == 130

proc part1(input: string): int =
  let t = input.parseInt
  result = 1
  while result.calc < t:
    result += 1

proc calc2(n: int): int =
  var p = 1
  while p * p <= n:
    if n mod p == 0:
      if n <= 50 * p: result += p
      let q = n div p
      if p != q and n <= 50 * q: result += q
    p += 1
  result *= 11

proc part2(input: string): int =
  let t = input.parseInt
  result = 1
  while result.calc2 < t:
    result += 1

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
