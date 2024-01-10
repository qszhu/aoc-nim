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
  sugar,
]



const TARGET = """
children: 3
cats: 7
samoyeds: 2
pomeranians: 3
akitas: 0
vizslas: 0
goldfish: 5
trees: 3
cars: 2
perfumes: 1
"""

proc getTargetMap(): Table[string, int] =
  for line in TARGET.strip.split("\n"):
    let p = line.split(": ")
    result[p[0]] = p[1].parseInt

proc parseLine(line: string): (int, Table[string, int]) =
  if line =~ re"^Sue (\d+): (.+)$":
    let id = matches[0].parseInt
    let rest = matches[1]
    var tab = initTable[string, int]()
    for m in rest.findAll(re"\w+: \d+"):
      let p = m.split(": ")
      tab[p[0]] = p[1].parseInt
    return (id, tab)
  raise newException(ValueError, "parse error: " & line)

when defined(test):
  doAssert parseLine("Sue 1: cars: 9, akitas: 3, goldfish: 0") == (1, {"cars": 9, "akitas": 3, "goldfish": 0}.toTable)

proc matches(a, b: Table[string, int]): bool =
  for k, v in a:
    if b[k] != v: return false
  true

proc part1(input: string): int =
  let t = getTargetMap()
  for line in input.split("\n"):
    let (d, t1) = line.parseLine
    if t1.matches(t): return d

proc matches2(a, b: Table[string, int]): bool =
  for k, v in a:
    if k in ["cats", "trees"]:
      if not (v > b[k]): return false
    elif k in ["pomeranians", "goldfish"]:
      if not (v < b[k]): return false
    else:
      if v != b[k]: return false
  true

proc part2(input: string): int =
  let t = getTargetMap()
  for line in input.split("\n"):
    let (d, t1) = line.parseLine
    if t1.matches2(t): return d

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
