import ../../lib/imports



type
  Tree = Table[string, HashSet[string]]

proc parse(input: string): Tree =
  result = initTable[string, HashSet[string]]()
  for line in input.split("\n"):
    let p = line.split(")")
    let (a, b) = (p[0], p[1])
    if a notin result:
      result[a] = initHashSet[string]()
    result[a].incl b
    if b notin result:
      result[b] = initHashSet[string]()
    result[b].incl a

proc depthSum(tree: Tree): int =
  proc dfs(u, p: string, depth: int): int =
    result += depth
    for v in tree[u]:
      if v == p: continue
      result += dfs(v, u, depth + 1)
  dfs("COM", "", 0)

when defined(test):
  let input = """
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
""".strip
  block:
    doAssert input.parse.depthSum == 42

proc part1(input: string): int =
  input.parse.depthSum



proc dist(tree: Tree, src, dst: string): int =
  var res = 0
  proc dfs(u, p: string, d: int): bool =
    if dst in tree[u]:
      res = d
      return true
    for v in tree[u]:
      if v == p: continue
      if dfs(v, u, d + 1): return true
  discard dfs(src, "", 0)
  res - 1

when defined(test):
  let input1 = """
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN
""".strip
  block:
    doAssert input1.parse.dist("YOU", "SAN") == 4

proc part2(input: string): int =
  input.parse.dist("YOU", "SAN")



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
