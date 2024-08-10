import ../../lib/imports
import ../day9/programs



const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

type
  Color {.pure.} = enum
    Black
    White

  Turn {.pure.} = enum
    Left
    Right

  Robot = ref object
    panel: Table[(int, int), Color]
    r, c: int
    dir: int
    initColor: Color

proc newRobot(initColor: Color): Robot =
  result.new
  result.initColor = initColor

proc step(self: Robot) =
  if queues[1].len == 0:
    let color = self.panel.getOrDefault((self.r, self.c), self.initColor)
    queues[0].addLast color.ord
  elif queues[1].len >= 2:
    let color = queues[1].popFirst.Color
    self.panel[(self.r, self.c)] = color
    let turn = queues[1].popFirst.Turn
    if turn == Turn.Left: self.dir = (self.dir - 1 + 4) mod 4
    else: self.dir = (self.dir + 1) mod 4
    let (dr, dc) = DPOS[self.dir]
    self.r += dr
    self.c += dc

proc part1(input: string): int =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  let r = newRobot(Color.Black)
  while true:
    if p.stepOver == StatusFinished: break
    r.step
  r.panel.len



proc output(panel: Table[(int, int), Color]): string =
  var minR, minC = int.high
  var maxR, maxC = int.low
  for (r, c) in panel.keys:
    minR = minR.min r
    minC = minC.min c
    maxR = maxR.max r
    maxC = maxC.max c
  var rows = maxR - minR + 1
  var cols = maxC - minC + 1
  var grid = newSeqWith(rows, "#".repeat(cols))
  for (r, c) in panel.keys:
    let color = panel[(r, c)]
    if color == Color.Black: grid[r - minR][c - minC] = ' '
    else: grid[r - minR][c - minC] = '#'
  grid.join("\n")

proc part2(input: string): string =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  let r = newRobot(Color.White)
  while true:
    if p.stepOver == StatusFinished: break
    r.step
  r.panel.output



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
