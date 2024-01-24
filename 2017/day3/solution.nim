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



proc dist(n: int): int =
  var n = n
  var d = 1
  while n > d * d:
    d += 2
  var m = d * d
  result = d - 1
  var i = -1
  for j in countdown(m - 1, n):
    result += i
    if result == ((d - 1) shr 1) or result == d - 1: i = -i

when defined(test):
  block:
    doAssert dist(1) == 0
    doAssert dist(12) == 3
    doAssert dist(23) == 2
    doAssert dist(1024) == 31

proc part1(input: string): int =
  input.parseInt.dist



const dPos = [(-1, 0), (0, -1), (1, 0), (0, 1)]

iterator nextNum(): int =
  var r, c = 0
  var visited = initTable[(int, int), int]()
  visited[(r, c)] = 1
  yield 1
  var l = 0
  while true:
    l += 2
    (r, c) = (r + 1, c + 1)
    for (dr, dc) in dPos:
      for _ in 0 ..< l:
        (r, c) = (r + dr, c + dc)
        var s = 0
        for dr in -1 .. 1:
          for dc in -1 .. 1:
            if (dr, dc) == (0, 0): continue
            s += visited.getOrDefault((r + dr, c + dc), 0)
        visited[(r, c)] = s
        yield s

when defined(test):
  block:
    let a = @[1, 1, 2, 4, 5, 10, 11, 23, 25, 26, 54, 57, 59,
      122, 133, 142, 147, 304, 330, 351, 362, 747, 806]
    var i = 0
    for x in nextNum():
      if i >= a.len: break
      doAssert a[i] == x
      i += 1

proc part2(input: string): int =
  let n = input.parseInt
  for x in nextNum():
    if x > n: return x



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
