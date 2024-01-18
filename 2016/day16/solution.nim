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



proc generate(a: string): string =
  let b = a.reversed.mapIt(if it == '0': '1' else: '0').join
  &"{a}0{b}"

when defined(test):
  block:
    doAssert generate("1") == "100"
    doAssert generate("0") == "001"
    doAssert generate("11111") == "11111000000"
    doAssert generate("111100001010") == "1111000010100101011110000"

proc checksum(s: string): string =
  var s = s
  while true:
    result = ""
    for i in countup(0, s.len - 1, 2):
      let (a, b) = (s[i], s[i + 1])
      if a == b: result &= "1"
      else: result &= "0"
    if result.len mod 2 == 1: return
    s = result

when defined(test):
  block:
    doAssert checksum("110010110100") == "100"

proc calc(s: string, n: int): string =
  var s = s
  while s.len < n:
    s = generate(s)
  checksum(s[0 ..< n])

when defined(test):
  block:
    doAssert calc("10000", 20) == "01100"

proc part1(input: string): string =
  calc(input, 272)

proc part2(input: string): string =
  calc(input, 35651584)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
