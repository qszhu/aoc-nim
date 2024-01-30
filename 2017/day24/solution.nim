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



type
  Component = (int, int)

proc parseLine(line: string): Component =
  let p = line.split("/")
  (p[0].parseInt, p[1].parseInt)

proc parse(input: string): seq[Component] =
  input.split("\n").mapIt(it.parseLine)

proc part1(input: string): int =
  let comps = input.parse
  var lookup = initTable[int, seq[Component]]()
  for comp in comps:
    var arr = lookup.getOrDefault(comp[0], newSeq[Component]())
    arr.add comp
    lookup[comp[0]] = arr
    arr = lookup.getOrDefault(comp[1], newSeq[Component]())
    arr.add comp
    lookup[comp[1]] = arr

  var seen = initHashSet[(int, int)]()
  var res = 0
  proc dfs(last, sofar: int) =
    res = res.max sofar
    var cands = lookup[last]
    for comp in cands:
      if comp in seen: continue
      seen.incl comp
      let next = if comp[0] == last: comp[1]
        else: comp[0]
      dfs(next, sofar + comp[0] + comp[1])
      seen.excl comp
  dfs(0, 0)
  res

when defined(test):
  let input = """
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10
""".strip
  block:
    doAssert part1(input) == 31



proc part2(input: string): int =
  let comps = input.parse
  var lookup = initTable[int, seq[Component]]()
  for comp in comps:
    var arr = lookup.getOrDefault(comp[0], newSeq[Component]())
    arr.add comp
    lookup[comp[0]] = arr
    arr = lookup.getOrDefault(comp[1], newSeq[Component]())
    arr.add comp
    lookup[comp[1]] = arr

  var seen = initHashSet[(int, int)]()
  var maxLen, maxStr = 0
  proc dfs(last, lenSofar, strSofar: int) =
    if lenSofar > maxLen:
      maxLen = lenSofar
      maxStr = strSofar
    elif lenSofar == maxLen:
      maxStr = maxStr.max strSofar

    var cands = lookup[last]
    for comp in cands:
      if comp in seen: continue
      seen.incl comp
      let next = if comp[0] == last: comp[1]
        else: comp[0]
      dfs(next, lenSofar + 1, strSofar + comp[0] + comp[1])
      seen.excl comp

  dfs(0, 0, 0)
  maxStr

when defined(test):
  block:
    doAssert part2(input) == 19



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
