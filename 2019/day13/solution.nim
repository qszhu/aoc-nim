import ../../lib/imports
import ../day9/programs



type
  Tile {.pure.} = enum
    Empty
    Wall
    Block
    Paddle
    Ball

proc part1(input: string): int =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  while p.step != StatusFinished: discard
  while queues[1].len >= 3:
    discard queues[1].popFirst
    discard queues[1].popFirst
    let t = queues[1].popFirst
    if t.Tile == Tile.Block: result += 1



type
  JoystickPos {.pure.} = enum
    Left = -1
    Neutral = 0
    Right = 1

type
  JoyStick = ref object
    paddleX: int

proc newJoyStick(): JoyStick =
  result.new
  result.paddleX = -1

proc stepOver(self: JoyStick) =
  while queues[1].len >= 3:
    let x = queues[1].popFirst
    let y = queues[1].popFirst
    let t = queues[1].popFirst

    if (x, y) == (-1.Value, 0.Value):
      echo t
    elif t == Tile.Paddle.ord:
      self.paddleX = x
    elif t == Tile.Ball.ord:
      if self.paddleX == -1:
        queues[0].addLast JoystickPos.Neutral.ord
      else:
        queues[0].addLast (if self.paddleX < x: JoystickPos.Right.ord else: JoystickPos.Left.ord)

proc part2(input: string) =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  p.mem[0] = 2
  let j = newJoyStick()
  var stop = false
  while not stop:
    stop = p.stepOver == StatusFinished
    j.stepOver



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  part2(input)
