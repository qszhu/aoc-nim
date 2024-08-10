import ../../lib/imports



proc fuel(mass: int): int {.inline.} =
  mass div 3 - 2

when defined(test):
  doAssert fuel(12) == 2
  doAssert fuel(14) == 2
  doAssert fuel(1969) == 654
  doAssert fuel(100756) == 33583

proc parse(input: string): seq[int] =
  input.split("\n").mapIt(it.parseInt)

proc part1(input: string): int =
  input.parse.mapIt(it.fuel).sum



proc totalFuel(mass: int): int =
  var mass = mass.fuel
  while mass > 0:
    result += mass
    mass = mass.fuel

when defined(test):
  doAssert totalFuel(14) == 2
  doAssert totalFuel(1969) == 966
  doAssert totalFuel(100756) == 50346

proc part2(input: string): int =
  input.parse.mapIt(it.totalFuel).sum



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
