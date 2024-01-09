import std/[
  algorithm,
  bitops,
  json,
  math,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]

proc parseLine(line: string): (string, string, int) =
  if line =~ re"(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)":
    (matches[0], matches[3], (if matches[1] == "gain": 1 else: -1) * matches[2].parseInt)
  else:
    raise newException(ValueError, "error parsing: " & line)

when defined(test):
  doAssert parseLine("Alice would gain 54 happiness units by sitting next to Bob.") == ("Alice", "Bob", 54)
  doAssert parseLine("Alice would lose 79 happiness units by sitting next to Carol.") == ("Alice", "Carol", -79)

proc parse(input: string): seq[seq[int]] =
  var mapping = newTable[string, int]()
  proc getMapping(s: string): int =
    if s notin mapping: mapping[s] = mapping.len
    mapping[s]

  for line in input.split("\n"):
    let (a, b, _) = parseLine(line)
    discard getMapping(a)
    discard getMapping(b)

  let N = mapping.len
  result = newSeqWith(N, newSeq[int](N))
  for line in input.split("\n"):
    let (a, b, w) = parseLine(line)
    let u = getMapping(a)
    let v = getMapping(b)
    result[u][v] = w

proc score(g: var seq[seq[int]], arrangement: var seq[int]): int =
  let N = arrangement.len
  for i in 0 ..< N:
    let u = arrangement[i]
    let p = arrangement[(i - 1 + N) mod N]
    let q = arrangement[(i + 1) mod N]
    result += g[u][p]
    result += g[u][q]

proc maxScore(g: var seq[seq[int]]): int =
  let N = g.len
  var arrangement = (0 ..< N).toSeq
  while true:
    result = result.max score(g, arrangement)
    if not arrangement.nextPermutation: break

proc part1(input: string): int =
  var g = parse(input)
  g.maxScore

proc part2(input: string): int =
  var g = parse(input)
  for r in g.mitems: r.add(0)
  g.add newSeq[int](g.len + 1)
  g.maxScore

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
