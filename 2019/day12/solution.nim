import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  options,
  os,
  rdstdin,
  re,
  sequtils,
  sets,
  streams,
  strformat,
  strutils,
  tables,
  threadpool,
  sugar,
]



type
  Vec3 = tuple[x, y, z: int]

  Moon = tuple[pos, vel: Vec3]

  System = seq[Moon]

proc parseLine(line: string): Moon =
  if line =~ re"<x=([^,]+), y=([^,]+), z=([^>]+)>":
    ((matches[0].parseInt, matches[1].parseInt, matches[2].parseInt), (0, 0, 0))
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
      ((-1, 0, 2), (0, 0, 0)),
      ((2, -10, -7), (0, 0, 0)),
      ((4, -8, 8), (0, 0, 0)),
      ((3, 5, -1), (0, 0, 0)),
    ]

proc apply(s: System, i: int): Moon =
  var (pos, vel) = s[i]
  for j in 0 ..< s.len:
    if j == i: continue
    let (otherPos, _) = s[j]
    if pos[0] != otherPos[0]:
      vel[0] += (if pos[0] > otherPos[0]: -1 else: 1)
    if pos[1] != otherPos[1]:
      vel[1] += (if pos[1] > otherPos[1]: -1 else: 1)
    if pos[2] != otherPos[2]:
      vel[2] += (if pos[2] > otherPos[2]: -1 else: 1)
  pos[0] += vel[0]
  pos[1] += vel[1]
  pos[2] += vel[2]
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
      ((2, -1, 1), (3, -1, -1)),
      ((3, -7, -4), (1, 3, 3)),
      ((1, -7, 5), (-3, 1, -3)),
      ((2, 2, 0), (-1, -3, 1)),
    ]
    for _ in 1 .. 9:
      s = s.step
    doAssert s == @[
      ((2, 1, -3), (-3, -2, 1)),
      ((1, -8, 0), (-1, 1, 3)),
      ((3, -6, 1), (3, 2, -3)),
      ((2, 0, 4), (1, -1, -1)),
    ]

proc energy(m: Moon): int =
  let (pos, vel) = m
  (pos[0].abs + pos[1].abs + pos[2].abs) * (vel[0].abs + vel[1].abs + vel[2].abs)

proc energy(s: System): int =
  s.mapIt(it.energy).sum

proc totalEnergy(s: System, steps: int): int =
  var s = s
  for _ in 0 ..< steps:
    s = s.step
  s.energy

when defined(test):
  block:
    doAssert input.parse.totalEnergy(10) == 179

  let input1 = """
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
""".strip
  block:
    doAssert input1.parse.totalEnergy(100) == 1940

proc part1(input: string): int =
  input.parse.totalEnergy(1000)



type
  State = ((int, int), (int, int), (int, int), (int, int))

template getState(s: System, axis: int): State =
  (
    (s[0].pos[axis], s[0].vel[axis]),
    (s[1].pos[axis], s[1].vel[axis]),
    (s[2].pos[axis], s[2].vel[axis]),
    (s[3].pos[axis], s[3].vel[axis]),
  )

proc findPeriods(s: System): (int, int, int) =
  var s = s
  let x0 = s.getState(0)
  let y0 = s.getState(1)
  let z0 = s.getState(2)
  var px, py, pz = -1
  var steps = 0
  while px == -1 or py == -1 or pz == -1:
    s = s.step
    steps += 1
    if px == -1 and s.getState(0) == x0:
      px = steps
    if py == -1 and s.getState(1) == y0:
      py = steps
    if pz == -1 and s.getState(2) == z0:
      pz = steps
  (px, py, pz)

proc part2(input: string): int =
  let (px, py, pz) = input.parse.findPeriods
  lcm(@[px, py, pz])

when defined(test):
  block:
    doAssert part2(input) == 2772
    doAssert part2(input1) == 4686774924



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
