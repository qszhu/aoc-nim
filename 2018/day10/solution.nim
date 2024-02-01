import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



type
  Point = tuple[position: (int, int), velocity: (int, int)]

proc parseLine(line: string): Point =
  if line =~ re"position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>":
    let m = matches[0 ..< 4].mapIt(it.parseInt)
    ((m[0], m[1]), (m[2], m[3]))
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): seq[Point] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
""".strip
  block:
    let points = input.parse
    doAssert points[0] == ((9, 1), (0, 2))
    doAssert points[1] == ((7, 0), (-1, 0))

proc move(p: Point, t: int): Point =
  let (pos, vec) = p
  let (x, y) = pos
  let (vx, vy) = vec
  ((x + vx * t, y + vy * t), vec)

proc move(points: seq[Point], t: int): seq[Point] =
  points.mapIt(it.move(t))

proc print(points: seq[Point]): bool =
  var minX, minY = int.high
  var maxX, maxY = int.low
  for (pos, vec) in points:
    let (x, y) = pos
    minX = minX.min x
    maxX = maxX.max x
    minY = minY.min y
    maxY = maxY.max y
  let cols = maxX - minX + 1
  let rows = maxY - minY + 1
  if rows > 100 or cols > 100: return false
  var grid = newSeqWith(rows, ".".repeat(cols))
  for (pos, vec) in points:
    let (x, y) = pos
    grid[y - minY][x - minX] = '#'
  echo grid.join("\n")
  true

when defined(test):
  block:
    let points = input.parse
    print(points.move(3))

proc part1(input: string) =
  let points = input.parse
  var t = 0
  while true:
    t += 1
    if print(points.move(t)):
      echo t
      var line = ""
      let ok = readLineFromStdin("", line)
      if not ok: break



when isMainModule and not defined(test):
  let input = readFile("input").strip
  part1(input)
#   echo part2(input)
