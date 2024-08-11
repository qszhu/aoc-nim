import ../../lib/imports



type
  Grid = seq[seq[int]]

proc parse(input: string): Grid =
  result = newSeqWith(5, newSeq[int](5))
  for r, row in input.split("\n").toSeq:
    for c in 0 ..< 5:
      if row[c] == '#': result[r][c] = 1
      else: result[r][c] = 0

when defined(test):
  let input = """
....#
#..#.
#..##
..#..
#....
""".strip
  block:
    doAssert input.parse == @[
      @[0, 0, 0, 0, 1],
      @[1, 0, 0, 1, 0],
      @[1, 0, 0, 1, 1],
      @[0, 0, 1, 0, 0],
      @[1, 0, 0, 0, 0],
    ]



proc step(g: Grid): Grid =
  result = newSeqWith(5, newSeq[int](5))
  for r in 0 ..< 5:
    for c in 0 ..< 5:
      result[r][c] = g[r][c]
      var cnt = 0
      for (nr, nc) in neighbors4((r, c), (5, 5)):
        cnt += g[nr][nc]
      if g[r][c] == 1:
        if cnt != 1: result[r][c] = 0
      else:
        if cnt in [1, 2]: result[r][c] = 1

when defined(test):
  block:
    doAssert input.parse.step == @[
      @[1, 0, 0, 1, 0],
      @[1, 1, 1, 1, 0],
      @[1, 1, 1, 0, 1],
      @[1, 1, 0, 1, 1],
      @[0, 1, 1, 0, 0],
    ]



proc rating(g: Grid): int =
  for r in countdown(4, 0):
    for c in countdown(4, 0):
      result = result shl 1 + g[r][c]

when defined(test):
  block:
    doAssert """
.....
.....
.....
#....
.#...
""".strip.parse.rating == 2129920



proc part1(input: string): int =
  var g = input.parse
  var h = g.rating
  var seen = initHashSet[int]()
  while h notin seen:
    seen.incl h
    g = g.step
    h = g.rating
  h

when defined(test):
  block:
    doAssert part1(input) == 2129920



type
  Tile = tuple[lvl: int, r: int, c: int]

  RecurGrid = HashSet[Tile]

proc initRecurGrid(input: string): RecurGrid =
  for r, row in input.split("\n").toSeq:
    for c in 0 ..< 5:
      if (r, c) == (2, 2): continue
      if row[c] == '#':
        result.incl (lvl: 0, r: r, c: c)

when defined(test):
  block:
    doAssert input.initRecurGrid.len == 8



proc neighbors(self: Tile): seq[Tile] =
  let (lvl, r, c) = self

  # top
  if r == 0: # ABCDE
    result.add (lvl: lvl + 1, r: 1, c: 2) # 8
  elif (r, c) == (3, 2): # 18
    for c in 0 ..< 5:
      result.add (lvl: lvl - 1, r: 4, c: c) # UVWXY
  else:
    result.add (lvl: lvl, r: r - 1, c: c)

  # right
  if c == 4: # EJOTY
    result.add (lvl: lvl + 1, r: 2, c: 3) # 14
  elif (r, c) == (2, 1): # 12
    for r in 0 ..< 5:
      result.add (lvl: lvl - 1, r: r, c: 0) #AFKPU
  else:
    result.add (lvl: lvl, r: r, c: c + 1)

  # bottom
  if r == 4: # UVWXY
    result.add (lvl: lvl + 1, r: 3, c: 2) # 18
  elif (r, c) == (1, 2): # 8
    for c in 0 ..< 5:
      result.add (lvl: lvl - 1, r: 0, c: c) # ABCDE
  else:
    result.add (lvl: lvl, r: r + 1, c: c)

  # left
  if c == 0: # AFKPU
    result.add (lvl: lvl + 1, r: 2, c: 1) # 12
  elif (r, c) == (2, 3): # 14
    for r in 0 ..< 5:
      result.add (lvl: lvl - 1, r: r, c: 4) # EJOTY
  else:
    result.add (lvl: lvl, r: r, c: c - 1)

proc adjBugs(g: var RecurGrid, t: Tile): int {.inline.} =
  t.neighbors.filterIt(it in g).len

proc step(g: var RecurGrid): RecurGrid =
  result = g.toSeq.filterIt(adjBugs(g, it) == 1).toHashSet
  var newTiles = initHashSet[Tile]()
  for t in g:
    for n in t.neighbors:
      if n notin g:
        newTiles.incl n
  for t in newTiles:
    if adjBugs(g, t) in [1, 2]:
      result.incl t

proc run(g: var RecurGrid, iters: int): int =
  for _ in 0 ..< iters:
    g = g.step
  g.len

when defined(test):
  block:
    var g = input.initRecurGrid
    doAssert g.run(10) == 99



proc part2(input: string): int =
  var g = input.initRecurGrid
  g.run(200)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
