import ../../lib/imports



proc parse(input: string): (int, int) =
  let a = input.split("\n").mapIt(it.parseInt)
  (a[0], a[1])

when defined(test):
  let input = """
5764801
17807724
""".strip
  block:
    doAssert input.parse == (5764801, 17807724)

iterator transform(s: int): int =
  var v = 1
  while true:
    v = v * s mod 20201227
    yield v

proc findLoopSize(target: int): int =
  for x in transform(7):
    result += 1
    if x == target: return

when defined(test):
  block:
    let (k1, k2) = input.parse
    doAssert k1.findLoopSize == 8
    doAssert k2.findLoopSize == 11

proc part1(input: string): int =
  let (k1, k2) = input.parse
  let l2 = k2.findLoopSize
  var c = 0
  for x in k1.transform:
    c += 1
    if c == l2: return x

when defined(test):
  block:
    doAssert part1(input) == 14897079



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
