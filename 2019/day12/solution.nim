import ../../lib/imports



type
  Vec3 = seq[int]

  Moon = tuple[pos, vel: Vec3]

  System = seq[Moon]

proc parseLine(line: string): Moon =
  if line =~ re"<x=([^,]+), y=([^,]+), z=([^>]+)>":
    (matches[0 .. 2].mapIt(it.parseInt), @[0, 0, 0])
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): System =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
""".strip
  block:
    doAssert input.parse == @[
      (@[-1, 0, 2], @[0, 0, 0]),
      (@[2, -10, -7], @[0, 0, 0]),
      (@[4, -8, 8], @[0, 0, 0]),
      (@[3, 5, -1], @[0, 0, 0]),
    ]

proc apply(s: System, i: int): Moon =
  var (pos, vel) = s[i]
  for j in 0 ..< s.len:
    if j == i: continue
    let (otherPos, _) = s[j]
    for k in 0 .. 2:
      if pos[k] != otherPos[k]:
        vel[k] += (if pos[k] > otherPos[k]: -1 else: 1)
  for k in 0 .. 2:
    pos[k] += vel[k]
  (pos, vel)

proc step(s: System): System =
  result = newSeq[Moon](s.len)
  for i in 0 ..< s.len:
    result[i] = s.apply(i)

when defined(test):
  block:
    var s = input.parse
    s = s.step
    doAssert s == @[
      (@[2, -1, 1], @[3, -1, -1]),
      (@[3, -7, -4], @[1, 3, 3]),
      (@[1, -7, 5], @[-3, 1, -3]),
      (@[2, 2, 0], @[-1, -3, 1]),
    ]
    for _ in 2 .. 10:
      s = s.step
    doAssert s == @[
      (@[2, 1, -3], @[-3, -2, 1]),
      (@[1, -8, 0], @[-1, 1, 3]),
      (@[3, -6, 1], @[3, 2, -3]),
      (@[2, 0, 4], @[1, -1, -1]),
    ]

proc energy(m: Moon): int =
  let (pos, vel) = m
  result = (0 .. 2).mapIt(pos[it].abs).sum
  result *= (0 .. 2).mapIt(vel[it].abs).sum

proc energy(s: System): int =
  s.mapIt(it.energy).sum

proc energy(s: System, steps: int): int =
  var s = s
  for _ in 0 ..< steps:
    s = s.step
  s.energy

when defined(test):
  block:
    doAssert input.parse.energy(10) == 179

  let input1 = """
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
""".strip
  block:
    doAssert input1.parse.energy(100) == 1940

proc part1(input: string): int =
  input.parse.energy(1000)



type
  State = ((int, int), (int, int), (int, int), (int, int))

template getState(s: System, axis: int): State =
  (
    (s[0].pos[axis], s[0].vel[axis]),
    (s[1].pos[axis], s[1].vel[axis]),
    (s[2].pos[axis], s[2].vel[axis]),
    (s[3].pos[axis], s[3].vel[axis]),
  )

proc findPeriods(s: System): seq[int] =
  var s = s
  var start = (0 .. 2).mapIt(s.getState(it))
  result = @[-1, -1, -1]
  var steps = 0
  while result.anyIt(it == -1):
    s = s.step
    steps += 1
    for i in 0 .. 2:
      if result[i] == -1 and s.getState(i) == start[i]:
        result[i] = steps

proc part2(input: string): int =
  input.parse.findPeriods.lcm

when defined(test):
  block:
    doAssert part2(input) == 2772
    doAssert part2(input1) == 4686774924



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
