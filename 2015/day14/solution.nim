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



proc parseLine(line: string): (int, int, int) =
  if line =~ re"(\w+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds.":
    (matches[1].parseInt, matches[2].parseInt, matches[3].parseInt)
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  doAssert parseLine("Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.") == (14, 10, 127)

proc dist(r: (int, int, int), s: int): int =
  let (speed, fly, rest) = r
  result = s div (fly + rest) * (speed * fly)
  result += min(s mod (fly + rest), fly) * speed

when defined(test):
  let c = (14, 10, 127)
  let d = (16, 11, 162)
  doAssert dist(c, 1) == 14
  doAssert dist(d, 1) == 16
  doAssert dist(c, 10) == 140
  doAssert dist(d, 10) == 160
  doAssert dist(c, 11) == 140
  doAssert dist(d, 11) == 176
  doAssert dist(c, 12) == 140
  doAssert dist(d, 12) == 176
  doAssert dist(c, 1000) == 1120
  doAssert dist(d, 1000) == 1056

proc part1(input: string): int =
  for line in input.split("\n"):
    let r = parseLine(line)
    result = result.max dist(r, 2503)

proc scores(rs: var seq[(int, int, int)], t: int): seq[int] =
  let N = rs.len
  result = newSeq[int](N)
  for i in 1 .. t:
    let ds = rs.mapIt(dist(it, i))
    let maxDist = ds.max
    let maxIndices = (0 ..< N).toSeq.filterIt(ds[it] == maxDist)
    for j in maxIndices: result[j] += 1

when defined(test):
  var rs = @[(14, 10, 127), (16, 11, 162)]
  doAssert scores(rs, 1) == @[0, 1]
  doAssert scores(rs, 140) == @[1, 139]
  doAssert scores(rs, 1000) == @[312, 689]

proc part2(input: string): int =
  var rs = input.split("\n").mapIt(it.parseLine)
  scores(rs, 2503).max

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
