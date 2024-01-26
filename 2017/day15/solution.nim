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



const AF = 16807
const BF = 48271
const MOD = 2147483647
const MASK = 65535

proc next(n, f: int): int {.inline.} =
  n * f mod MOD

when defined(test):
  block:
    let a = @[1092455, 1181022009, 245556042, 1744312007, 1352636452]
    var x = 65
    for i in 0 ..< a.len:
      doAssert x.next(AF) == a[i]
      x = a[i]

proc calc(a, b, c: int): int =
  var a = a
  var b = b
  for _ in 0 ..< c:
    a = a.next(AF)
    b = b.next(BF)
    if (a and MASK) == (b and MASK): result += 1

when defined(test):
  block:
    doAssert calc(65, 8921, 4e7.int) == 588

proc parse(input: string): (int, int) =
  let lines = input.split("\n")
  let a = lines[0].split(" ")[^1].parseInt
  let b = lines[1].split(" ")[^1].parseInt
  (a, b)

proc part1(input: string): int =
  let (a, b) = input.parse
  calc(a, b, 4e7.int)



proc next2(x, f, m: int): iterator =
  iterator iter(): int =
    var x = x
    while true:
      x = x * f mod MOD
      if x mod m == 0: yield x
  iter

const AM = 4
const BM = 8

when defined(test):
  block:
    let a = @[1352636452, 1992081072, 530830436, 1980017072, 740335192]
    var x = 65
    let an = next2(x, AF, AM)
    for i in 0 ..< a.len:
      x = an()
      doAssert a[i] == x

proc calc2(a, b, c: int): int =
  var (a, b, c) = (a, b, c)
  var an = next2(a, AF, AM)
  var bn = next2(b, BF, BM)
  for _ in 0 ..< c:
    a = an()
    b = bn()
    if (a and MASK) == (b and MASK):
      result += 1

when defined(test):
  block:
    doAssert calc2(65, 8921, 5e6.int) == 309

proc part2(input: string): int =
  let (a, b) = input.parse
  calc2(a, b, 5e6.int)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
