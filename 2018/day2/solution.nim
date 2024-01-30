import std/[
  algorithm,
  bitops,
  deques,
  intsets,
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



proc parse(input: string): seq[string] =
  input.split("\n")

proc part1(input: string): int =
  let a = input.parse
  var twos, threes = 0
  for s in a:
    let cnts = s.toCountTable.values.toSeq
    if 2 in cnts: twos += 1
    if 3 in cnts: threes += 1
  twos * threes

when defined(test):
  block:
    let input = """
abcdef
bababc
abbcde
abcccd
aabcdd
abcdee
ababab
""".strip
    doAssert part1(input) == 12

proc diff(a, b: string): int =
  for i, c in a:
    if c != b[i]: result += 1

proc common(a, b: string): string =
  for i, c in a:
    if c == b[i]: result &= c

proc part2(input: string): string =
  let a = input.parse
  for i in 0 ..< a.len:
    for j in i + 1 ..< a.len:
      if diff(a[i], a[j]) == 1:
        return common(a[i], a[j])

when defined(test):
  block:
    let input = """
abcde
fghij
klmno
pqrst
fguij
axcye
wvxyz
""".strip
    doAssert part2(input) == "fgij"



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
