import std/[
  algorithm,
  sequtils,
  sets,
  strutils,
]



proc walk(input: string): HashSet[(int, int)] =
  result = initHashSet[(int, int)]()
  var r, c = 0
  result.incl (r, c)
  for d in input:
    case d:
    of '^': r -= 1
    of '>': c += 1
    of 'v': r += 1
    of '<': c -= 1
    else: discard
    result.incl (r, c)

proc part1(input: string): int =
  walk(input).len

when defined(test):
  doAssert part1(">") == 2
  doAssert part1("^>v<") == 4
  doAssert part1("^v^v^v^v^v") == 2

proc part2(input: string): int =
  let r1 = countup(0, input.len - 1, 2).toSeq.mapIt(input[it]).join
  let r2 = countup(1, input.len - 1, 2).toSeq.mapIt(input[it]).join
  (walk(r1) + walk(r2)).len

when defined(test):
  doAssert part2("^v") == 3
  doAssert part2("^>v<") == 3
  doAssert part2("^v^v^v^v^v") == 11

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
