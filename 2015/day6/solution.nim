import std/[
  algorithm,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
]



type Op = enum
  TURN_ON
  TURN_OFF
  TOOGLE

type Inst = (Op, int, int, int, int)

proc parseInst(line: string): Inst =
  if line =~ re"turn on (\d+),(\d+) through (\d+),(\d+)":
    let m = matches[0 ..< 4].mapIt(it.parseInt)
    (TURN_ON, m[0], m[1], m[2], m[3])
  elif line =~ re"turn off (\d+),(\d+) through (\d+),(\d+)":
    let m = matches[0 ..< 4].mapIt(it.parseInt)
    (TURN_OFF, m[0], m[1], m[2], m[3])
  elif line =~ re"toggle (\d+),(\d+) through (\d+),(\d+)":
    let m = matches[0 ..< 4].mapIt(it.parseInt)
    (TOOGLE, m[0], m[1], m[2], m[3])
  else:
    raise newException(ValueError, "parse error")

proc parse(input: string): seq[Inst] =
  input.split("\n").mapIt(it.parseInst)

const N = 1000

proc part1(input: string): int =
  var grid = newSeqWith(N, newSeq[int](N))
  for (op, r1, c1, r2, c2) in input.parse:
    case op:
    of TURN_ON:
      for r in r1 .. r2:
        for c in c1 .. c2:
          grid[r][c] = 1
    of TURN_OFF:
      for r in r1 .. r2:
        for c in c1 .. c2:
          grid[r][c] = 0
    of TOOGLE:
      for r in r1 .. r2:
        for c in c1 .. c2:
          grid[r][c] = grid[r][c] xor 1
  for r in 0 ..< N:
    for c in 0 ..< N:
      result += grid[r][c]

proc part2(input: string): int =
  var grid = newSeqWith(N, newSeq[int](N))
  for (op, r1, c1, r2, c2) in input.parse:
    case op:
    of TURN_ON:
      for r in r1 .. r2:
        for c in c1 .. c2:
          grid[r][c] += 1
    of TURN_OFF:
      for r in r1 .. r2:
        for c in c1 .. c2:
          grid[r][c] = max(0, grid[r][c] - 1)
    of TOOGLE:
      for r in r1 .. r2:
        for c in c1 .. c2:
          grid[r][c] += 2
  for r in 0 ..< N:
    for c in 0 ..< N:
      result += grid[r][c]

when isMainModule:
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
