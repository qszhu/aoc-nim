import std/[
  algorithm,
  bitops,
  json,
  math,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]



proc parseLine(line: string): (int, int, int, int, int) =
  if line =~ re"(\w+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)":
    let m = matches[1 .. 5].mapIt(it.parseInt)
    (m[0], m[1], m[2], m[3], m[4])
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  doAssert parseLine("Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8") == (-1, -2, 6, 3, 8)
  doAssert parseLine("Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3") == (2, 3, -2, -1, 3)

proc score(a, b: seq[int]): int =
  for i, x in a:
    result += x * b[i]
  result = result.max 0

proc score(ings: seq[(int, int, int, int, int)], dist: seq[int]): int =
  result = 1
  result *= score(ings.mapIt(it[0]), dist)
  result *= score(ings.mapIt(it[1]), dist)
  result *= score(ings.mapIt(it[2]), dist)
  result *= score(ings.mapIt(it[3]), dist)

when defined(test):
  let ings = @[
    (-1, -2, 6, 3, 8),
    (2, 3, -2, -1, 3)
  ]
  doAssert score(ings, @[44, 56]) == 62842880

proc distributions(n, t: int): seq[seq[int]] =
  var res = newSeq[seq[int]]()
  var partial = newSeq[int]()
  proc dfs() =
    let s = partial.sum
    if partial.len == n - 1:
      res.add partial & (t - s)
      return
    for i in 1 ..< t - s:
      partial.add i
      dfs()
      discard partial.pop
  dfs()
  res

when defined(test):
  doAssert distributions(1, 5) == @[@[5]]
  doAssert distributions(2, 5) == @[@[1, 4], @[2, 3], @[3, 2], @[4, 1]]
  doAssert distributions(3, 4) == @[@[1, 1, 2], @[1, 2, 1], @[2, 1, 1]]

proc part1(input: string): int =
  let ings = input.split("\n").mapIt(it.parseLine)
  let N = ings.len
  distributions(N, 100).mapIt(score(ings, it)).max

proc calories(ings: seq[(int, int, int, int, int)], dist: seq[int]): int =
  score(ings.mapIt(it[4]), dist)

proc part2(input: string): int =
  let ings = input.split("\n").mapIt(it.parseLine)
  let N = ings.len
  distributions(N, 100)
    .filterIt(calories(ings, it) == 500)
    .mapIt(score(ings, it))
    .max

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
