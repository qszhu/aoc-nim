import ../../lib/imports



proc parseLine(line: string): (string, seq[(string, int)]) =
  var matches: array[2, string]
  var p = 0
  p += line.matchLen(re"(.+?) bags contain ", matches, p)
  let name = matches[0]
  var children = newSeq[(string, int)]()
  if line[p ..< line.len] != "no other bags.":
    while p < line.len:
      p += line.matchLen(re"(\d+) (.+?) bag[s]?(?:, |.)", matches, p)
      children.add (matches[1], matches[0].parseInt)
  (name, children)

when defined(test):
  let input = """
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
""".strip
  block:
    let lines = input.split("\n")
    doAssert lines[0].parseLine == ("light red", @[("bright white", 1), ("muted yellow", 2)])
    doAssert lines[2].parseLine == ("bright white", @[("shiny gold", 1)])
    doAssert lines[7].parseLine == ("faded blue", @[])



proc getParents(input: string): Table[string, seq[string]] =
  for line in input.split("\n"):
    let (outer, children) = line.parseLine
    for (inner, _) in children:
      if inner notin result:
        result[inner] = newSeq[string]()
      result[inner].add outer

proc part1(input: string): int =
  let g = input.getParents
  var seen = initHashSet[string]()
  proc dfs(s: string): int =
    if s notin g: return
    for c in g[s]:
      if c in seen: continue
      seen.incl c
      result += dfs(c) + 1
  dfs("shiny gold")

when defined(test):
  block:
    doAssert part1(input) == 4



proc getChildren(input: string): Table[string, seq[(string, int)]] =
  for line in input.split("\n"):
    let (outer, children) = line.parseLine
    result[outer] = children

proc part2(input: string): int =
  let g = input.getChildren
  proc dfs(s: string): int =
    result = 1
    if s notin g: return
    for (c, cnt) in g[s]:
      result += cnt * dfs(c)
  dfs("shiny gold") - 1

when defined(test):
  block:
    doAssert part2(input) == 32

  let input1 = """
shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
""".strip
  block:
    doAssert part2(input1) == 126



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
