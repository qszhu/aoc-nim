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
  Program = ref object
    name: string
    weight: int
    children: seq[string]

proc parseLine(line: string): Program =
  result.new
  if line =~ re"(\w+) \((\d+)\) -> (.+)":
    result.name = matches[0]
    result.weight = matches[1].parseInt
    result.children = matches[2].split(", ")
  elif line =~ re"(\w+) \((\d+)\)":
    result.name = matches[0]
    result.weight = matches[1].parseInt
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    let p = parseLine("pbga (66)")
    doAssert p.name == "pbga"
    doAssert p.weight == 66
    doAssert p.children.len == 0

  block:
    let p = parseLine("fwft (72) -> ktlj, cntj, xhth")
    doAssert p.name == "fwft"
    doAssert p.weight == 72
    doAssert p.children == @["ktlj", "cntj", "xhth"]

proc findRoot(programs: seq[Program]): Program =
  var childSet = initHashSet[string]()
  for p in programs:
    childSet = childSet + p.children.toHashSet
  for p in programs:
    if p.name notin childSet: return p

proc parse(input: string): seq[Program] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
pbga (66)
xhth (57)
ebii (61)
havc (66)
ktlj (57)
fwft (72) -> ktlj, cntj, xhth
qoyq (66)
padx (45) -> pbga, havc, qoyq
tknk (41) -> ugml, padx, fwft
jptl (61)
ugml (68) -> gyxo, ebii, jptl
gyxo (61)
cntj (57)
""".strip
  block:
    doAssert findRoot(input.parse).name == "tknk"

proc part1(input: string): string =
  findRoot(input.parse).name



proc fixedWeight(programs: seq[Program]): int =
  var pMap = initTable[string, Program]()
  for p in programs: pMap[p.name] = p

  var weights = initTable[string, int]()
  proc calcWeights(p: Program): int =
    if p.name in weights: return weights[p.name]
    result = p.weight
    for cName in p.children: result += calcWeights(pMap[cName])
    weights[p.name] = result

  let root = findRoot(programs)
  discard calcWeights(root)

  proc findUnbalanced(p: Program, otherWeight = -1): (Program, int) =
    if p.children.mapIt(weights[it]).toHashSet.len == 1: return (p, otherWeight)
    let cWeights = p.children.mapIt(weights[it]).toCountTable
    let targetName = p.children.filterIt(cWeights[weights[it]] == 1)[0]
    let otherName = p.children.filterIt(cWeights[weights[it]] > 1)[0]
    let otherWeight = weights[otherName]
    findUnbalanced(pMap[targetName], otherWeight)

  let (target, otherWeight) = findUnbalanced(root)
  let targetWeight = weights[target.name]
  let diff = targetWeight - otherWeight
  target.weight - diff



when defined(test):
  block:
    doAssert fixedWeight(input.parse) == 60

proc part2(input: string): int =
  fixedWeight(input.parse)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
