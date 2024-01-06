import std/[
  algorithm,
  bitops,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]



proc parseLine(line: string): (string, string, int) =
  if line =~ re"(\w+) to (\w+) = (\d+)":
    (matches[0], matches[1], matches[2].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

doAssert parseLine("London to Dublin = 464") == ("London", "Dublin", 464)

proc parse(input: string): seq[seq[int]] =
  var mapping = initTable[string, int]()
  proc getMapping(s: string): int =
    if s notin mapping: mapping[s] = mapping.len
    mapping[s]

  var mapped = newSeq[(int, int, int)]()
  for line in input.split("\n"):
    let (a, b, w) = parseLine(line)
    let u = getMapping(a)
    let v = getMapping(b)
    mapped.add (u, v, w)

  let N = mapping.len
  var adj = newSeqWith(N, newSeq[int](N))
  for i in 0 ..< N: adj[i].fill int.high
  for (u, v, w) in mapped:
    adj[u][v] = w
    adj[v][u] = w
  adj

proc dist(route: var seq[int], adj: var seq[seq[int]]): int =
  for i in 1 ..< route.len:
    let u = route[i - 1]
    let v = route[i]
    if adj[u][v] != int.high:
      result += adj[u][v]

proc minDist(adj: var seq[seq[int]]): int =
  let N = adj.len
  result = int.high
  var route = (0 ..< N).toSeq
  while true:
    result = result.min dist(route, adj)
    if not route.nextPermutation: break

proc part1(input: string): int =
  var adj = input.parse
  minDist(adj)

proc maxDist(adj: var seq[seq[int]]): int =
  let N = adj.len
  var route = (0 ..< N).toSeq
  while true:
    result = result.max dist(route, adj)
    if not route.nextPermutation: break

proc part2(input: string): int =
  var adj = input.parse
  maxDist(adj)

when isMainModule:
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
