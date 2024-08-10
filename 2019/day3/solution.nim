import ../../lib/imports



const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]
const DIRS = "URDL"

type
  INST = tuple[dir, steps: int]

proc parseLine(line: string): seq[INST] =
  line.split(",").mapIt (DIRS.find(it[0]), it[1 .. ^1].parseInt)

proc parse(input: string): seq[seq[INST]] =
  input.split("\n").mapIt(it.parseLine)

proc part1(input: string): int =
  let wires = input.parse

  var visited = initHashSet[(int, int)]()
  var r, c = 0
  for (dir, steps) in wires[0]:
    let (dr, dc) = DPOS[dir]
    for _ in 0 ..< steps:
      (r, c) = (r + dr, c + dc)
      visited.incl (r, c)

  (r, c) = (0, 0)
  result = int.high
  for (dir, steps) in wires[1]:
    let (dr, dc) = DPOS[dir]
    for _ in 0 ..< steps:
      (r, c) = (r + dr, c + dc)
      if (r, c) in visited:
        result = result.min r.abs + c.abs



when defined(test):
  let input = """
R8,U5,L5,D3
U7,R6,D4,L4
""".strip
  let input1 = """
R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83
""".strip
  let input2 = """
R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
""".strip
  block:
    doAssert part1(input) == 6
    doAssert part1(input1) == 159
    doAssert part1(input2) == 135



proc part2(input: string): int =
  let wires = input.parse

  var visited = initTable[(int, int), int]()
  var r, c, s = 0
  for (dir, steps) in wires[0]:
    let (dr, dc) = DPOS[dir]
    for _ in 0 ..< steps:
      (r, c, s) = (r + dr, c + dc, s + 1)
      if (r, c) notin visited:
        visited[(r, c)] = s

  (r, c, s) = (0, 0, 0)
  result = int.high
  for (dir, steps) in wires[1]:
    let (dr, dc) = DPOS[dir]
    for _ in 0 ..< steps:
      (r, c, s) = (r + dr, c + dc, s + 1)
      if (r, c) in visited:
        result = result.min visited[(r, c)] + s

when defined(test):
  block:
    doAssert part2(input) == 30
    doAssert part2(input1) == 610
    doAssert part2(input2) == 410



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
