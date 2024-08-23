import ../../lib/imports



proc parse(input: string): seq[int] =
  input.split(",").mapIt(it.parseInt)

proc run(a: var seq[int], sz: int) =
  var map = initTable[int, seq[int]]()
  for i, x in a:
    map[x] = @[i + 1]
  while a.len < sz:
    let last = a[^1]
    if last notin map:
      map[last] = @[a.len]
    else:
      map[last].add a.len
      if map[last].len > 2:
        map[last] = map[last][^2 .. ^1]
    if map[last].len == 1:
      a.add 0
    else:
      a.add map[last][^1] - map[last][^2]

proc part1(input: string): int =
  var a = input.parse
  run(a, 2020)
  a[^1]

when defined(test):
  let input = """
0,3,6
""".strip
  block:
    doAssert part1(input) == 436
    doAssert part1("1,3,2") == 1
    doAssert part1("2,1,3") == 10
    doAssert part1("1,2,3") == 27
    doAssert part1("2,3,1") == 78
    doAssert part1("3,2,1") == 438
    doAssert part1("3,1,2") == 1836



proc part2(input: string): int =
  var a = input.parse
  run(a, 30000000)
  a[^1]

when defined(test):
  block:
    doAssert part2(input) == 175594
    doAssert part2("1,3,2") == 2578
    doAssert part2("2,1,3") == 3544142
    doAssert part2("1,2,3") == 261214
    doAssert part2("2,3,1") == 6895259
    doAssert part2("3,2,1") == 18
    doAssert part2("3,1,2") == 362



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
