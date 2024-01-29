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
  Vec3 = tuple[x, y, z: int]

  Particle = tuple[pos, velocity, acceleration: Vec3]

proc parseVec3(s: string): Vec3 =
  let s = s.split(",").mapIt(it.strip.parseInt)
  (s[0], s[1], s[2])

proc parseLine(line: string): Particle =
  let v = line.split(", ").mapIt(it[3 ..< ^1])
  (v[0].parseVec3, v[1].parseVec3, v[2].parseVec3)

when defined(test):
  block:
    doAssert "p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>".parseLine == ((3, 0, 0), (2, 0, 0), (-1, 0, 0))

proc pos(x, v, a, t: int): int =
  x + v * t + a * t * (t + 1) shr 1

proc pos(self: Particle, t: int): Vec3 =
  let (x, y, z) = self.pos
  let (vx, vy, vz) = self.velocity
  let (ax, ay, az) = self.acceleration
  (pos(x, vx, ax, t), pos(y, vy, ay, t), pos(z, vz, az, t))

when defined(test):
  block:
    let p0 = "p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>".parseLine
    let p1 = "p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>".parseLine
    doAssert p0.pos(1).x == 4
    doAssert p1.pos(1).x == 2
    doAssert p0.pos(2).x == 4
    doAssert p1.pos(2).x == -2
    doAssert p0.pos(3).x == 3

proc part1(input: string): int =
  let particles = input.split("\n").mapIt(it.parseLine)
  var minDist = int.high
  for i, p in particles:
    let p0 = p.pos(1e3.int)
    let d = p0.x.abs + p0.y.abs + p0.z.abs
    if minDist > d:
      minDist = d
      result = i

proc part2(input: string): int =
  var particles = input.split("\n").mapIt(it.parseLine)
  for t in 1 .. 50:
    var positions = initTable[Vec3, seq[int]]()
    for i, p in particles:
      let p0 = p.pos(t)
      var arr = positions.getOrDefault(p0, newSeq[int]())
      arr.add i
      positions[p0] = arr
    var toDelete = initHashSet[int]()
    for v in positions.values:
      if v.len > 1: toDelete = toDelete + v.toHashSet
    var next = newSeq[Particle]()
    for i, p in particles:
      if i in toDelete: continue
      next.add p
    particles = next
  particles.len



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
