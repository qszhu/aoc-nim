import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  options,
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]

import ../../lib/grid



type
  NodeKind = enum
    nkLeaf
    nkGroup

  Node = object
    case kind: NodeKind
    of nkLeaf:
      val: string
    of nkGroup:
      children: seq[Route]

  Route = seq[Node]

proc newLeaf(): Node =
  Node(kind: nkLeaf, val: "")

proc newGroup(): Node =
  Node(kind: nkGroup, children: newSeq[Route]())

proc `$`(self: Route): string
proc `$`(self: Node): string =
  case self.kind:
  of nkLeaf: self.val
  of nkGroup: "(" & self.children.mapIt($it).join("|") & ")"

proc `$`(self: Route): string =
  self.mapIt($it).join("")

proc preprocess(input: string): Table[int, seq[int]] =
  var st = newSeq[int]()
  for i, ch in input:
    if ch == '(':
      st.add i
      result[i] = newSeq[int]()
    elif ch == ')':
      result[st.pop].add i
    elif ch == '|':
      result[st[^1]].add i

proc parse(input: string): Route =
  let input = "(" & input[1 ..< ^1] & ")"
  let next = input.preprocess

  proc parse(a, b: int): Route =
    var leaf = newLeaf()
    var i = a
    while i < b:
      let ch = input[i]
      if ch == '(':
        if leaf.val.len > 0:
          result.add leaf
          leaf = newLeaf()
        var group = newGroup()
        var j = i
        for k in next[i]:
          group.children.add parse(j + 1, k)
          j = k
        result.add group
        i = j + 1
      else:
        leaf.val &= ch
        i += 1
    result.add leaf

  parse(0, input.len)

when defined(test):
  let input1 = """
^WNE$
""".strip
  let input2 = """
^ENWWW(NEEE|SSE(EE|N))$
""".strip
  let input3 = """
^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$
""".strip
  let input4 = """
^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$
""".strip
  let input5 = """
^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$
""".strip
  block:
    for input in [input1, input2, input3, input4, input5]:
      doAssert ($input.parse)[1 ..< ^1] == input[1 ..< ^1]



const dPos = [(-1, 0), (0, 1), (1, 0), (0, -1)]
const DIRS = "NESW"

type
  CellType = enum
    ROOM
    DOOR
    WALL

  Cells = Table[(int, int), CellType]

proc restore(route: Route): Cells =
  var res: Cells
  res[(0, 0)] = ROOM
  proc dfs(r, c: int, route: Route) =
    var (r, c) = (r, c)
    for node in route:
      case node.kind:
      of nkLeaf:
        for ch in node.val:
          let (dr, dc) = dPos[DIRS.find(ch)]
          (r, c) = (r + dr, c + dc)
          res[(r, c)] = DOOR
          (r, c) = (r + dr, c + dc)
          res[(r, c)] = ROOM
      of nkGroup:
        for route in node.children:
          dfs(r, c, route)
  dfs(0, 0, route)
  res

proc restore(cells: Cells): (int, int, seq[seq[int]]) =
  var minR, minC = int.high
  var maxR, maxC = int.low
  for (r, c) in cells.keys:
    (minR, minC) = (minR.min r, minC.min c)
    (maxR, maxC) = (maxR.max r, maxC.max c)
  let (rows, cols) = (maxR - minR + 1, maxC - minC + 1)
  let (sr, sc) = (-minR, -minC)
  var grid = newSeqWith(rows, newSeq[int](cols))
  for r in 0 ..< rows:
    grid[r].fill WALL.ord
  for k, v in cells:
    let (r, c) = k
    grid[r - minR][c - minC] = v.ord
  (sr, sc, grid)

proc maxDoors(grid: seq[seq[int]], sr, sc: int): int =
  let (rows, cols) = (grid.len, grid[0].len)
  var visited = newSeqWith(rows, newSeq[bool](cols))
  var q = @[(sr, sc)]
  var step = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      for (nr, nc) in neighbors4((r, c), (rows, cols)):
        if visited[nr][nc]: continue
        if grid[nr][nc] != DOOR.ord: continue
        visited[nr][nc] = true
        let (dr, dc) = (nr - r, nc - c)
        next.add (nr + dr, nc + dc)
    q = next
    if q.len > 0: step += 1
  step

proc part1(input: string): int =
  let (sr, sc, grid) = input.parse.restore.restore
  maxDoors(grid, sr, sc)

when defined(test):
  block:
    doAssert part1(input1) == 3
    doAssert part1(input2) == 10
    doAssert part1(input3) == 18
    doAssert part1(input4) == 23
    doAssert part1(input5) == 31



proc maxDoors(grid: seq[seq[int]], sr, sc: int, lo: int): int =
  let (rows, cols) = (grid.len, grid[0].len)
  var visited = newSeqWith(rows, newSeq[bool](cols))
  var q = @[(sr, sc)]
  var step = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      for (nr, nc) in neighbors4((r, c), (rows, cols)):
        if visited[nr][nc]: continue
        if grid[nr][nc] != DOOR.ord: continue
        visited[nr][nc] = true
        let (dr, dc) = (nr - r, nc - c)
        next.add (nr + dr, nc + dc)
        if step + 1 >= lo: result += 1
    q = next
    if q.len > 0: step += 1

proc part2(input: string): int =
  let (sr, sc, grid) = input.parse.restore.restore
  maxDoors(grid, sr, sc, 1000)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
