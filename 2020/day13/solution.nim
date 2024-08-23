import ../../lib/imports



proc parse(input: string): (int, seq[int]) =
  let lines = input.split("\n")
  (lines[0].parseInt, lines[1].split(",").filterIt(it != "x").mapIt(it.parseInt))

when defined(test):
  let input = """
939
7,13,x,x,59,x,31,19
""".strip
  block:
    doAssert input.parse == (939, @[7, 13, 59, 31, 19])

proc earliest(i, t: int): int =
  (t + i - 1) div i * i

when defined(test):
  block:
    doAssert earliest(7, 939) == 945
    doAssert earliest(13, 939) == 949
    doAssert earliest(59, 939) == 944

proc part1(input: string): int =
  let (depart, buses) = input.parse
  let (t, i) = buses.mapIt((it.earliest(depart), it)).min
  (t - depart) * i

when defined(test):
  block:
    doAssert part1(input) == 295



proc earliest2(input: string): int =
  var ids = newSeq[int64]()
  var rems = newSeq[int64]()
  for i, s in input.split(",").toSeq:
    if s == "x": continue
    ids.add s.parseInt
    rems.add i
  let (a, b) = crt(ids, rems)
  b - a

when defined(test):
  block:
    doAssert earliest2(input.split("\n")[1]) == 1068781
    doAssert earliest2("17,x,13,19") == 3417
    doAssert earliest2("67,7,59,61") == 754018
    doAssert earliest2("67,x,7,59,61") == 779210
    doAssert earliest2("67,7,x,59,61") == 1261476
    doAssert earliest2("1789,37,47,1889") == 1202161486

proc part2(input: string): int =
  input.split("\n")[1].earliest2



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
