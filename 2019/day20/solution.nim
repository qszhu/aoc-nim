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
  os,
  rdstdin,
  re,
  sequtils,
  sets,
  streams,
  strformat,
  strutils,
  tables,
  threadpool,
  sugar,
]



const WALL = '#'
const EMPTY = '.'

const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

type
  Grid = ref object
    grid: seq[string]
    rows, cols: int
    start, finish: (int, int)
    portals: Table[(int, int), (int, int)]

proc parse(input: string): Grid =
  let input = input.strip(leading = false, chars = { '\n' })
  result.new
  let lines = input.split("\n")
  let (rows, cols) = (lines.len, lines[0].len)
  result.grid = newSeqWith(rows - 4, " ".repeat(cols - 4))
  result.rows = result.grid.len
  result.cols = result.grid[0].len

  proc getLabel(r, c: int): string =
    for i, (dr, dc) in DPOS:
      let (nr, nc) = (r + dr, c + dc)
      if not lines[nr][nc].isUpperAscii: continue
      var a = lines[nr][nc]
      var b = lines[nr + dr][nc + dc]
      if i == 0 or i == 3: swap(a, b)
      return &"{a}{b}"

  var portalMap = initTable[string, seq[(int, int)]]()
  for lr in 2 ..< rows - 2:
    for lc in 2 ..< cols - 2:
      let (r, c) = (lr - 2, lc - 2)
      if lines[lr][lc] == EMPTY or lines[lr][lc] == WALL:
        result.grid[r][c] = lines[lr][lc]
      if lines[lr][lc] != EMPTY: continue

      let label = getLabel(lr, lc)
      if label.len == 0: continue

      if label == "AA":
        result.start = (r, c)
        continue

      if label == "ZZ":
        result.finish = (r, c)
        continue

      var arr = portalMap.getOrDefault(label, newSeq[(int, int)]())
      arr.add (r, c)
      portalMap[label] = arr

  result.portals = initTable[(int, int), (int, int)]()
  for name, arr in portalMap:
    result.portals[arr[0]] = arr[1]
    result.portals[arr[1]] = arr[0]

when defined(test):
  let input = """
         A           
         A           
  #######.#########  
  #######.........#  
  #######.#######.#  
  #######.#######.#  
  #######.#######.#  
  #####  B    ###.#  
BC...##  C    ###.#  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE..#######...###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       
"""
  block:
    let grid = input.parse
    # echo grid.grid.join("\n")
    doAssert grid.rows == 15
    doAssert grid.cols == 17
    doAssert grid.start == (0, 7)
    doAssert grid.finish == (14, 11)
    for (a, b) in [((6, 0), (4, 7)), ((11, 0), (8, 4)), ((13, 0), (10, 9))]:
      doAssert grid.portals[a] == b
      doAssert grid.portals[b] == a

proc bfs(grid: Grid): int =
  var q = @[grid.start]
  var visited = q.toHashSet
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for (r, c) in q:
      if (r, c) == grid.finish: return steps
      for (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< grid.rows or nc notin 0 ..< grid.cols: continue
        if grid.grid[nr][nc] != EMPTY: continue
        if (nr, nc) in visited: continue
        visited.incl (nr, nc)
        next.add (nr, nc)
      if (r, c) in grid.portals:
        let (nr, nc) = grid.portals[(r, c)]
        if (nr, nc) notin visited:
          visited.incl (nr, nc)
          next.add (nr, nc)
    q = next
    if q.len > 0: steps += 1

when defined(test):
  block:
    doAssert input.parse.bfs == 23

  let input1 = """
                   A               
                   A               
  #################.#############  
  #.#...#...................#.#.#  
  #.#.#.###.###.###.#########.#.#  
  #.#.#.......#...#.....#.#.#...#  
  #.#########.###.#####.#.#.###.#  
  #.............#.#.....#.......#  
  ###.###########.###.#####.#.#.#  
  #.....#        A   C    #.#.#.#  
  #######        S   P    #####.#  
  #.#...#                 #......VT
  #.#.#.#                 #.#####  
  #...#.#               YN....#.#  
  #.###.#                 #####.#  
DI....#.#                 #.....#  
  #####.#                 #.###.#  
ZZ......#               QG....#..AS
  ###.###                 #######  
JO..#.#.#                 #.....#  
  #.#.#.#                 ###.#.#  
  #...#..DI             BU....#..LF
  #####.#                 #.#####  
YN......#               VT..#....QG
  #.###.#                 #.###.#  
  #.#...#                 #.....#  
  ###.###    J L     J    #.#.###  
  #.....#    O F     P    #.#...#  
  #.###.#####.#.#####.#####.###.#  
  #...#.#.#...#.....#.....#.#...#  
  #.#####.###.###.#.#.#########.#  
  #...#.#.....#...#.#.#.#.....#.#  
  #.###.#####.###.###.#.#.#######  
  #.#.........#...#.............#  
  #########.###.###.#############  
           B   J   C               
           U   P   P               
"""
  block:
    doAssert input1.parse.bfs == 58

proc part1(input: string): int =
  input.parse.bfs



proc buildGraph(grid: Grid): (seq[(int, int)], seq[seq[(int, int)]]) =
  let positions = grid.portals.keys.toSeq & grid.start & grid.finish
  var posMap = initTable[(int, int), int]()
  for i, p in positions: posMap[p] = i

  let N = positions.len
  var adjList = newSeqWith(N, newSeq[(int, int)]())
  proc bfs(i: int): seq[int] =
    var dists = newSeq[int](N)
    dists.fill int.high
    var q = @[positions[i]]
    var visited = q.toHashSet
    var steps = 0
    while q.len > 0:
      var next: typeof q = @[]
      for (r, c) in q:
        if (r, c) in posMap: dists[posMap[(r, c)]] = steps
        for (dr, dc) in DPOS:
          let (nr, nc) = (r + dr, c + dc)
          if nr notin 0 ..< grid.rows or nc notin 0 ..< grid.cols: continue
          if grid.grid[nr][nc] != EMPTY: continue
          if (nr, nc) in visited: continue
          visited.incl (nr, nc)
          next.add (nr, nc)
      q = next
      if q.len > 0: steps += 1
    dists

  for u in 0 ..< N:
    let dists = bfs(u)
    for v, w in dists:
      if v <= u: continue
      if w != int.high:
        adjList[u].add (v, w)
        adjList[v].add (u, w)
  (positions, adjList)

when defined(test):
  block:
    let grid = input.parse
    let (positions, adjList) = grid.buildGraph
    var posMap = initTable[(int, int), int]()
    for i, p in positions: posMap[p] = i
    doAssert adjList[posMap[(0, 7)]].len == 3
    doAssert adjList[posMap[(0, 7)]].contains (posMap[(4, 7)], 4)
    doAssert adjList[posMap[(0, 7)]].contains (posMap[(14, 11)], 26)
    doAssert adjList[posMap[(0, 7)]].contains (posMap[(10, 9)], 30)
    doAssert adjList[posMap[(6, 0)]].len == 1
    doAssert adjList[posMap[(6, 0)]].contains (posMap[(8, 4)], 6)
    doAssert adjList[posMap[(11, 0)]].len == 1
    doAssert adjList[posMap[(11, 0)]].contains (posMap[(13, 0)], 4)

proc isOuter(grid: Grid, r, c: int): bool {.inline.} =
  (r, c) notin [grid.start, grid.finish] and (
    r == 0 or r == grid.rows - 1 or c == 0 or c == grid.cols - 1)

proc bfs2(grid: Grid): int =
  let (positions, adjList) = grid.buildGraph
  var posMap = initTable[(int, int), int]()
  for i, p in positions: posMap[p] = i

  let (sr, sc) = grid.start
  # (steps, row, col, level)
  var q = @[(0, sr, sc, 0)].toHeapQueue
  var visited = @[(sr, sc, 0)].toHashSet
  while q.len > 0:
    let (steps, r, c, l) = q.pop
    if l == 0 and (r, c) == grid.finish: return steps
    for (v, w) in adjList[posMap[(r, c)]]:
      let (nr, nc) = positions[v]
      if l == 0 and grid.isOuter(nr, nc): continue
      if l > 0 and (nr, nc) in [grid.start, grid.finish]: continue
      if (nr, nc, l) in visited: continue
      visited.incl (nr, nc, l)
      q.push (steps + w, nr, nc, l)
    if (r, c) in grid.portals:
      let (nr, nc) = grid.portals[(r, c)]
      let nl = if grid.isOuter(r, c): l - 1 else: l + 1
      if (nr, nc, nl) in visited: continue
      visited.incl (nr, nc, nl)
      q.push (steps + 1, nr, nc, nl)
  -1



when defined(test):
  let input2 = """
             Z L X W       C                 
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M                     
"""
  block:
    doAssert input2.parse.bfs2 == 396

proc part2(input: string): int =
  input.parse.bfs2



when isMainModule and not defined(test):
  let input = readFile("input")
  echo part1(input)
  echo part2(input)
