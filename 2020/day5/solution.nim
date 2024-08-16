import ../../lib/imports



proc getRow(s: string): int =
  for i in 0 ..< 7:
    result *= 2
    if s[i] == 'B': result += 1

when defined(test):
  block:
    doAssert "FBFBBFFRLR".getRow == 44

proc getCol(s: string): int =
  for i in 7 ..< 10:
    result *= 2
    if s[i] == 'R': result += 1

when defined(test):
  block:
    doAssert "FBFBBFFRLR".getCol == 5

proc getSeatId(s: string): int =
  s.getRow shl 3 + s.getCol

when defined(test):
  block:
    doAssert "FBFBBFFRLR".getSeatId == 357
    doAssert "BFFFBBFRRR".getSeatId == 567
    doAssert "FFFBBBFRRR".getSeatId == 119
    doAssert "BBFFBBFRLL".getSeatId == 820

proc part1(input: string): int =
  input.split("\n").mapIt(it.getSeatId).max



proc part2(input: string): int =
  let seats = input.split("\n").mapIt(it.getSeatId).sorted
  for i in 1 ..< seats.len:
    if seats[i - 1] + 1 != seats[i]:
      return seats[i - 1] + 1



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
