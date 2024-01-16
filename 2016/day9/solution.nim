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



proc decompress(s: string): string =
  var i = 0
  while i < s.len:
    if s[i] == ' ':
      i += 1
      continue
    if s[i] == '(':
      var matches: array[2, string]
      let l = s.matchLen(re"\((\d+)x(\d+)\)", matches, start = i)
      if l != -1:
        let (a, b) = (matches[0].parseInt, matches[1].parseInt)
        i += l
        let t = s[i ..< i + a]
        i += a
        result &= t.repeat(b)
        continue
    result &= s[i]
    i += 1

when defined(test):
  block:
    doAssert decompress("ADVENT") == "ADVENT"
    doAssert decompress("A(1x5)BC") == "ABBBBBC"
    doAssert decompress("(3x3)XYZ") == "XYZXYZXYZ"
    doAssert decompress("A(2x2)BCD(2x2)EFG") == "ABCBCDEFEFG"
    doAssert decompress("(6x1)(1x3)A") == "(1x3)A"
    doAssert decompress("X(8x2)(3x3)ABCY") == "X(3x3)ABC(3x3)ABCY"

proc part1(input: string): int =
  var s = input.replace(re"\s+", "")
  decompress(s).len

proc decompressedLen(s: var string, a, b: int): int =
  var i = a
  while i < b:
    if s[i] == '(':
      var matches: array[2, string]
      let l = s.matchLen(re"\((\d+)x(\d+)\)", matches, start = i)
      if l != -1:
        i += l
        let (a, b) = (matches[0].parseInt, matches[1].parseInt)
        result += decompressedLen(s, i, i + a) * b
        i += a
        continue
    i += 1
    result += 1

proc part2(input: string): int =
  var s = input.replace(re"\s+", "")
  decompressedLen(s, 0, s.len)

when defined(test):
  block:
    doAssert part2("(3x3)XYZ") == 9
    doAssert part2("X(8x2)(3x3)ABCY") == 20
    doAssert part2("(27x12)(20x12)(13x14)(7x10)(1x12)A") == 241920
    doAssert part2("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN") == 445

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
