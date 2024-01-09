import std/[
  strutils,
]



proc part1(s: string): int =
  for c in s:
    if c == '(': result += 1
    else: result -= 1

when defined(test):
  doAssert part1("(())") == 0
  doAssert part1("()()") == 0
  doAssert part1("(((") == 3
  doAssert part1("(()(()(") == 3
  doAssert part1("))(((((") == 3
  doAssert part1("())") == -1
  doAssert part1("))(") == -1
  doAssert part1(")))") == -3
  doAssert part1(")())())") == -3

proc part2(s: string): int =
  var f = 0
  for i, c in s:
    if c == '(': f += 1
    else: f -= 1
    if f == -1: return i + 1

when defined(test):
  doAssert part2(")") == 1
  doAssert part2("()())") == 5

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
