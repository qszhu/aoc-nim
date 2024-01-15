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



const dPos = [(-1, 0), (0, 1), (1, 0), (0, -1)]
const insts = "URDL"

const pad = [[1,2,3],[4,5,6],[7,8,9]]

proc move(p: (int, int), inst: string): (int, int) =
  var (r, c) = p
  for i in inst:
    let (dr, dc) = dPos[insts.find(i)]
    let (nr, nc) = (r + dr, c + dc)
    if nr in 0 ..< 3 and nc in 0 ..< 3:
      (r, c) = (nr, nc)
  (r, c)

when defined(test):
  block:
    var (r, c) = (1, 1)
    (r, c) = move((r, c), "ULL")
    doAssert pad[r][c] == 1

    (r, c) = move((r, c), "RRDDD")
    doAssert pad[r][c] == 9

    (r, c) = move((r, c), "LURDL")
    doAssert pad[r][c] == 8

    (r, c) = move((r, c), "UUUUD")
    doAssert pad[r][c] == 5

proc part1(input: string): string =
  var (r, c) = (1, 1)
  for line in input.split("\n"):
    (r, c) = move((r, c), line)
    result &= $(pad[r][c])

when defined(test):
  block:
    doAssert part1("""
ULL
RRDDD
LURDL
UUUUD
""".strip) == "1985"

const pad2 = [
  "00100",
  "02340",
  "56789",
  "0ABC0",
  "00D00"
]

proc move2(p: (int, int), inst: string): (int, int) =
  var (r, c) = p
  for i in inst:
    let (dr, dc) = dPos[insts.find(i)]
    let (nr, nc) = (r + dr, c + dc)
    if nr in 0 ..< 5 and nc in 0 ..< 5:
      if pad2[nr][nc] != '0':
        (r, c) = (nr, nc)
  (r, c)

when defined(test):
  block:
    var (r, c) = (2, 0)
    (r, c) = move2((r, c), "ULL")
    doAssert pad2[r][c] == '5'

    (r, c) = move2((r, c), "RRDDD")
    doAssert pad2[r][c] == 'D'

    (r, c) = move2((r, c), "LURDL")
    doAssert pad2[r][c] == 'B'

    (r, c) = move2((r, c), "UUUUD")
    doAssert pad2[r][c] == '3'

proc part2(input: string): string =
  var (r, c) = (2, 0)
  for line in input.split("\n"):
    (r, c) = move2((r, c), line)
    result &= $(pad2[r][c])

when defined(test):
  block:
    doAssert part2("""
ULL
RRDDD
LURDL
UUUUD
""".strip) == "5DB3"

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
