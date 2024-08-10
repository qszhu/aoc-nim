import ../../lib/imports
import ../day9/programs


type
  State {.pure.} = enum
    Stationary
    Pulled

const DIM = 50

proc check(input: string, r, c: int): bool =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  queues[0].addLast c
  queues[0].addLast r
  discard p.stepOver
  queues[1].popFirst.State == State.Pulled

proc getMapping(input: string): seq[seq[bool]] =
  result = newSeqWith(DIM, newSeq[bool](DIM))
  for r in 0 ..< 50:
    for c in 0 ..< 50:
      result[r][c] = input.check(r, c)

proc part1(input: string): int =
  let map = getMapping(input)
  for r in 0 ..< DIM:
    for c in 0 ..< DIM:
      if map[r][c]: result += 1



proc part2(input: string): int =
  const width = 100
  var (bottom, left) = (50, 0)
  while not check(input, bottom - width + 1, left + width - 1):
    bottom += 1
    while not check(input, bottom, left):
      left += 1
  let x = left
  let y = bottom - width + 1
  x * 10000 + y



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
