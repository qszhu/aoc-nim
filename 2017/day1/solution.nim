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



proc calc(s: string, offset = 1): int =
  let N = s.len
  for i in 0 ..< N:
    if s[i] == s[(i + offset) mod N]:
      result += s[i].ord - '0'.ord

proc part1(input: string): int =
  calc(input)

when defined(test):
  block:
    doAssert part1("1122") == 3
    doAssert part1("1111") == 4
    doAssert part1("1234") == 0
    doAssert part1("91212129") == 9

proc part2(input: string): int =
  calc(input, input.len shr 1)

when defined(test):
  block:
    doAssert part2("1212") == 6
    doAssert part2("1221") == 0
    doAssert part2("123425") == 4
    doAssert part2("123123") == 12
    doAssert part2("12131415") == 4



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
