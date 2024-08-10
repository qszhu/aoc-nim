import ../../lib/imports
import ../day9/programs



type
  Grid = seq[string]

proc getOutput(): string =
  while queues[1].len > 0:
    result &= queues[1].popFirst.char

proc getMap(input: string): Grid =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  discard p.stepOver
  getOutput().strip.split('\n')

const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

const WALL = '#'
const EMTPY = '.'

proc sumAlign(grid: seq[string]): int =
  let (rows, cols) = (grid.len, grid[0].len)
  for r in 1 ..< rows - 1:
    for c in 1 ..< cols - 1:
      if grid[r][c] != WALL: continue
      var s = 0
      for (dr, dc) in DPOS:
        let (nr, nc) = (r + dr, c + dc)
        if grid[nr][nc] == WALL: s += 1
      if s == 4: result += r * c

when defined(test):
  block:
    let grid = """
..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^..
""".strip.split("\n")
    doAssert sumAlign(grid) == 76

proc part1(input: string): int =
  input.getMap.sumAlign



const DIRS = "^>v<"

proc findStart(grid: Grid): (int, int, int) =
  let (rows, cols) = (grid.len, grid[0].len)
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      if grid[r][c] in DIRS:
        let dir = DIRS.find(grid[r][c])
        return (r, c, dir)

proc walk(grid: Grid): string =
  let (rows, cols) = (grid.len, grid[0].len)
  var (r, c, dir) = grid.findStart

  proc move(o: int): bool =
    let ndir = (dir + o + 4) mod 4
    let (dr, dc) = DPOS[ndir]
    let (nr, nc) = (r + dr, c + dc)
    if nr notin 0 ..< rows: return
    if nc notin 0 ..< cols: return
    if grid[nr][nc] != WALL: return
    (r, c, dir) = (nr, nc, ndir)
    true

  while true:
    if move(0):
      result &= "F"
    elif move(1):
      result &= "RF"
    elif move(-1):
      result &= "LF"
    else:
      break

proc rle(s: string): string =
  var res = newSeq[(char, int)]()
  var cnt = 1
  var ch = s[0]
  for i in 1 ..< s.len:
    if s[i] != ch:
      res.add (ch, cnt)
      ch = s[i]
      cnt = 1
    else:
      cnt += 1
  res.add (ch, cnt)
  res.mapIt((if it[0] == 'F': $it[1] else: $it[0])).join(",")

when defined(test):
  let grid = """
#######...#####
#.....#...#...#
#.....#...#...#
......#...#...#
......#...###.#
......#.....#.#
^########...#.#
......#.#...#.#
......#########
........#...#..
....#########..
....#...#......
....#...#......
....#...#......
....#####......
""".strip.split("\n")
  block:
    doAssert grid.walk.rle == "R,8,R,8,R,4,R,4,R,8,L,6,L,2,R,4,R,4,R,8,R,8,R,8,L,6,L,2"

const MAX_CHARS = 20

proc compress(route: string): (seq[string], seq[int]) =
  var res: (seq[string], seq[int])
  proc search(i: int, dict: seq[string], sofar: seq[int]): bool =
    if sofar.len >= MAX_CHARS: return false
    if i > route.len: return false

    if i == route.len:
      res = (dict, sofar)
      return true

    for j, pat in dict:
      if i + pat.len <= route.len and route[i ..< i + pat.len] == pat:
        if search(i + pat.len, dict, sofar & j): return true

    if dict.len == 3: return false
    for j in i + 1 .. route.len:
      let pat = route[i ..< j]
      if pat.rle.len > MAX_CHARS: break
      if search(i + pat.len, dict & pat, sofar & dict.len): return true

  doAssert search(0, newSeq[string](), newSeq[int]())
  res

when defined(test):
  block:
    let route = grid.walk
    let (dict, routine) = route.compress
    doAssert route == routine.mapIt(dict[it]).join

proc runController(p: Program, grid: Grid) =
  let (dict, routine) = grid.walk.compress
  doAssert dict.len == 3
  let A = dict[0].rle
  let B = dict[1].rle
  let C = dict[2].rle
  let r = routine.mapIt((it + 'A'.ord).char).join(",")
  # echo (r, A, B, C)
  for m in [r, A, B, C]:
    for ch in m:
      queues[0].addLast ch.ord
    queues[0].addLast '\n'.ord
  queues[0].addLast 'n'.ord
  queues[0].addLast '\n'.ord
  discard p.stepOver

proc part2(input: string): int =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  p.mem[0] = 2
  let grid = input.getMap
  runController(p, grid)

  var output = ""
  while queues[1].len > 0:
    let r = queues[1].popFirst
    if r < 256: output &= r.char
    else:
      # echo output
      return r



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
