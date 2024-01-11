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



proc parseLine(line: string): (string, string) =
  if line =~ re"(\w+) => (\w+)":
    (matches[0], matches[1])
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  doAssert parseLine("H => HO") == ("H", "HO")

proc parse(rules: string): Table[string, HashSet[string]] =
  for line in rules.split("\n"):
    let (a, b) = line.parseLine
    var s = result.getOrDefault(a, initHashSet[string]())
    s.incl b
    result[a] = s

iterator generate(rules: Table[string, HashSet[string]], src: string): string =
  # for i in 0 ..< src.len:
  for i in countdown(src.len - 1, 0): # essential for part2
    for k, v in rules:
      if i + k.len > src.len: continue
      if src[i ..< i + k.len] != k: continue
      for t in rules[k]:
        yield src[0 ..< i] & t & src[i + k.len ..< src.len]

proc part1(input: string): int =
  let p = input.split("\n\n")
  let (rules, src) = (p[0].parse, p[1])
  generate(rules, src).toSeq.toHashSet.len

when defined(test):
  doAssert part1("""
H => HO
H => OH
O => HH

HOH
""".strip) == 4
  doAssert part1("""
H => HO
H => OH
O => HH

HOHOHO
""".strip) == 7

proc parseRev(rules: string): Table[string, HashSet[string]] =
  for line in rules.split("\n"):
    let (a, b) = line.parseLine
    var s = result.getOrDefault(b, initHashSet[string]())
    s.incl a
    result[b] = s

proc search(revRules: Table[string, HashSet[string]], target: string): int =
  var path = newSeq[string]()
  proc bt(target: string): bool =
    if target == "e": return true
    path.add target
    for c in generate(revRules, target):
      if bt(c): return true
    discard path.pop
  discard bt(target)
  path.len

proc part2(input: string): int =
  let p = input.split("\n\n")
  let (revRules, target) = (p[0].parseRev, p[1])
  search(revRules, target)

when defined(test):
  doAssert part2("""
e => H
e => O
H => HO
H => OH
O => HH

HOH
""".strip) == 3
  doAssert part2("""
e => H
e => O
H => HO
H => OH
O => HH

HOHOHO
""".strip) == 6

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
