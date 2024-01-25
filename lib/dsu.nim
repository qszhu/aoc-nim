import std/[
  algorithm,
  sequtils,
  tables,
]



type DSU* = ref object
  parent: seq[int]
  rank: seq[int]
  size: seq[int]
  comps: int

proc newDSU*(n: int): DSU =
  result.new
  result.parent = (0 ..< n).toSeq
  result.rank = newSeq[int](n)
  result.size = newSeq[int](n)
  result.size.fill 1
  result.comps = n

proc append*(dsu: DSU): int =
  result = dsu.parent.len
  dsu.parent.add result
  dsu.rank.add 0
  dsu.size.add 1
  dsu.comps.inc

proc find*(dsu: DSU, x: int): int =
  if dsu.parent[x] != x: dsu.parent[x] = dsu.find(dsu.parent[x])
  dsu.parent[x]

proc isConnected*(dsu: DSU, x: int, y: int): bool {.inline.} =
  dsu.find(x) == dsu.find(y)

proc union*(dsu: DSU, x, y: int): bool {.discardable.} =
  var (a, b) = (dsu.find(x), dsu.find(y))
  if a == b: return false

  if dsu.rank[a] < dsu.rank[b]: swap(a, b)
  if dsu.rank[a] == dsu.rank[b]: dsu.rank[a].inc
  dsu.parent[b] = a
  dsu.size[a].inc dsu.size[b]
  dsu.comps.dec
  true

proc compSize*(dsu: DSU, x: int): int {.inline.} =
  dsu.size[dsu.find(x)]

proc numComps*(dsu: DSU): int {.inline.} =
  dsu.comps
