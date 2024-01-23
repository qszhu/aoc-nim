import std/[
  algorithm,
  bitops,
  deques,
  json,
  math,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



type
  Equipments = (int, int)

proc parseLine(line: string): Equipments =
  var chips, generators = 0
  for m in line.findAll(re"\b\w+(\-compatible microchip| generator)"):
    if m =~ re"(\w+)-compatible microchip":
      chips += 1
    elif m =~ re"(\w+) generator":
      generators += 1
  (chips, generators)

when defined(test):
  let input = """
The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
The second floor contains a hydrogen generator.
The third floor contains a lithium generator.
The fourth floor contains nothing relevant.
""".strip
  block:
    let lines = input.split("\n")
    doAssert parseLine(lines[0]) == (2, 0)
    doAssert parseLine(lines[1]) == (0, 1)
    doAssert parseLine(lines[2]) == (0, 1)
    doAssert parseLine(lines[3]) == (0, 0)

type
  Facility = object
    elevator: int
    floors: array[4, Equipments]

proc parse(input: string): Facility =
  var floors: array[4, Equipments]
  for i, line in input.split("\n").toSeq:
    floors[i] = parseLine(line)
  Facility(floors: floors)

when defined(test):
  block:
    let f = parse(input)
    doAssert f.elevator == 0
    doAssert f.floors == [(2, 0), (0, 1), (0, 1), (0, 0)]

proc finished(self: Facility): bool =
  for i in 0 .. 2:
    if self.floors[i] != (0, 0): return false
  true

proc isValid(floor: Equipments): bool =
  let (cs, gs) = floor
  if cs < 0 or gs < 0: return false
  gs == 0 or cs <= gs

proc `+`(a, b: Equipments): Equipments =
  (a[0] + b[0], a[1] + b[1])

proc `-`(a, b: Equipments): Equipments =
  (a[0] - b[0], a[1] - b[1])

proc move(self: Facility, equipments: Equipments, target: int): (bool, Facility) =
  let fromFloor = self.floors[self.elevator] - equipments
  if not fromFloor.isValid: return (false, self)

  let toFloor = self.floors[target] + equipments
  if not toFloor.isValid: return (false, self)

  var floors = self.floors
  floors[self.elevator] = fromFloor
  floors[target] = toFloor
  (true, Facility(elevator: target, floors: floors))

iterator next(self: Facility): Facility =
  for target in 0 .. 3:
    if (self.elevator - target).abs != 1: continue
    for i in 0 .. 2:
      for j in 0 .. 2:
        if i + j in 1 .. 2:
          let (ok, nf) = self.move((i, j), target)
          if ok: yield nf

proc bfs(f: Facility): int =
  var q = @[f]
  var visited = initHashSet[Facility]()
  visited.incl f
  var steps = 0
  while q.len > 0:
    var next: typeof q = @[]
    for f in q:
      if f.finished: return steps
      for nf in f.next:
        if nf in visited: continue
        visited.incl nf
        next.add nf
    q = next
    steps += 1

proc part1(input: string): int =
  let f = parse(input)
  bfs(f)

when defined(test):
  block:
    doAssert part1(input) == 11

proc part2(input: string): int =
  var f = parse(input)
  let (cs, gs) = f.floors[0]
  f.floors[0] = (cs + 2, gs + 2)
  bfs(f)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)