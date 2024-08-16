import ../../lib/imports



proc parse(input: string): seq[seq[string]] =
  input.split("\n\n").mapIt(it.split("\n"))

proc union(s: seq[string]): int =
  s.foldl(a + b.toHashSet, initHashSet[char]()).len

proc part1(input: string): int =
  input.parse.mapIt(it.union).sum

when defined(test):
  let input = """
abc

a
b
c

ab
ac

a
a
a
a

b
""".strip
  block:
    doAssert part1(input) == 11



proc intersect(s: seq[string]): int =
  s.foldl(a * b.toHashSet, s[0].toHashSet).len

proc part2(input: string): int =
  input.parse.mapIt(it.intersect).sum

when defined(test):
  block:
    doAssert part2(input) == 6



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
