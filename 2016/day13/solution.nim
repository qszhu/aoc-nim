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



proc isWall(y, x, n: int): bool =
  ((x * x + 3 * x + 2 * x * y + y + y * y + n).countSetBits and 1) == 1

when defined(test):
  block:
    var rows: seq[string] = @[]
    for r in 0 ..< 7:
      var row = ""
      for c in 0 ..< 10:
        row &= (if isWall(r, c, 10): '#' else: '.')
      rows.add row
    doAssert rows.join("\n") == """
.#.####.##
..#..#...#
#....##...
###.#.###.
.##..#..#.
..##....#.
#...##.###
""".strip

const dPos = [(-1, 0), (0, 1), (1, 0), (0, -1)]

proc bfs(tc, tr, n: int): int =
  var q = @[(1, 1)]
  var visited = initHashSet[(int, int)]()
  visited.incl q[0]
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      if (r, c) == (tr, tc): return steps
      for (dr, dc) in dPos:
        let (nr, nc) = (r + dr, c + dc)
        if nr < 0 or nc < 0: continue
        if isWall(nr, nc, n): continue
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        next.add (nr, nc)
    q = next
    steps += 1

when defined(test):
  block:
    doAssert bfs(7, 4, 10) == 11

proc part1(input: string): int =
  let n = input.parseInt
  bfs(31, 39, n)

proc bfs2(n: int): int =
  var q = @[(1, 1)]
  var visited = initHashSet[(int, int)]()
  visited.incl q[0]
  var steps = 0
  while steps < 50:
    var next: typeof q = @[]
    for (r, c) in q:
      for (dr, dc) in dPos:
        let (nr, nc) = (r + dr, c + dc)
        if nr < 0 or nc < 0: continue
        if isWall(nr, nc, n): continue
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        next.add (nr, nc)
    q = next
    steps += 1
  visited.len

proc part2(input: string): int =
  let n = input.parseInt
  bfs2(n)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
