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
  Node = tuple[x, y, used, avail: int]

proc parseLine(line: string): Node =
  if line =~ re"/dev/grid/node-x(\d+)-y(\d+)\s+\d+T\s+(\d+)T\s+(\d+)T\s+\d+%":
    let m = matches[0 .. 3].mapIt(it.parseInt)
    (x: m[0], y: m[1], used: m[2], avail: m[3])
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert "/dev/grid/node-x0-y0     94T   65T    29T   69%".parseLine == (0, 0, 65, 29)

proc isEmpty(a: Node): bool {.inline.} =
  a.used == 0

proc wouldFit(a, b: Node): bool {.inline.} =
  a.used <= b.avail

type
  Grid = Table[(int, int), Node]

proc parse(input: string, skip = 2): Grid =
  let lines = input.split("\n")[skip .. ^1]
  for line in lines:
    let node = line.parseLine
    result[(node.x, node.y)] = node

proc part1(input: string): int =
  let grid = input.parse
  let nodes = grid.values.toSeq
  for a in nodes:
    for b in nodes:
      if a == b: continue
      if a.isEmpty: continue
      #[
        key fact:
          without the only empty node,
          there would be no viable pairs
      ]#
      # if b.isEmpty: continue
      if a.wouldFit(b): result += 1

proc findTarget(grid: var Grid): (int, int) =
  var x = 0
  for node in grid.values:
    if node.y != 0: continue
    x = x.max node.x
  (x, 0)

proc findEmpty(grid: var Grid): (int, int) =
  for node in grid.values:
    if node.isEmpty: return (node.x, node.y)

when defined(test):
  let input = """
Filesystem            Size  Used  Avail  Use%
/dev/grid/node-x0-y0   10T    8T     2T   80%
/dev/grid/node-x0-y1   11T    6T     5T   54%
/dev/grid/node-x0-y2   32T   28T     4T   87%
/dev/grid/node-x1-y0    9T    7T     2T   77%
/dev/grid/node-x1-y1    8T    0T     8T    0%
/dev/grid/node-x1-y2   11T    7T     4T   63%
/dev/grid/node-x2-y0   10T    6T     4T   60%
/dev/grid/node-x2-y1    9T    8T     1T   88%
/dev/grid/node-x2-y2    9T    6T     3T   66%
""".strip
  block:
    var grid = input.parse(skip = 1)
    doAssert grid.findTarget == (2, 0)
    doAssert grid.findEmpty == (1, 1)

type
  State = tuple[ex, ey, gx, gy: int]

proc finished(s: State): bool =
  (s.gx, s.gy) == (0, 0)

const dPos4 = [(-1, 0), (0, 1), (1, 0), (0, -1)]

iterator next(s: State, g: var Grid): State =
  for (dx, dy) in dPos4:
    let (nx, ny) = (s.ex + dx, s.ey + dy)
    if (nx, ny) notin g: continue
    if (nx, ny) != (s.gx, s.gy):
      yield (ex: nx, ey: ny, gx: s.gx, gy: s.gy)
    else:
      yield (ex: nx, ey: ny, gx: s.ex, gy: s.ey)

proc bfs(g: var Grid): int =
  let (gx, gy) = g.findTarget
  let (ex, ey) = g.findEmpty
  let s = (ex: ex, ey: ey, gx: gx, gy: gy)
  var q = @[s]
  var visited = initHashSet[State]()
  visited.incl s
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for s in q:
      if s.finished: return steps
      for ns in s.next(g):
        if ns in visited: continue
        visited.incl ns
        next.add ns
    q = next
    steps += 1

when defined(test):
  block:
    var grid = input.parse(skip = 1)
    doAssert bfs(grid) == 7

proc part2(input: string): int =
  var grid = input.parse
  var viable = initHashSet[(int, int)]()
  let nodes = grid.values.toSeq
  for a in nodes:
    for b in nodes:
      if a == b: continue
      if a.isEmpty: continue
      if a.wouldFit(b):
        viable.incl (a.x, a.y)
        viable.incl (b.x, b.y)
  for (x, y) in grid.keys.toSeq:
    if (x, y) notin viable:
      grid.del (x, y)
  bfs(grid)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
