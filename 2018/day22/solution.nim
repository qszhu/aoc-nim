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
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



proc parse(input: string): (int, (int, int)) =
  let lines = input.split("\n")
  if lines[0] =~ re"depth: (\d+)":
    let depth = matches[0].parseInt
    if lines[1] =~ re"target: (\d+),(\d+)":
      let (x, y) = (matches[0].parseInt, matches[1].parseInt)
      return (depth, (x, y))
  raise newException(ValueError, "parse error: " & input)

when defined(test):
  let input = """
depth: 510
target: 10,10
""".strip
  block:
    doAssert input.parse == (510, (10, 10))

type
  RegionType {.pure.} = enum
    Rocky
    Wet
    Narrow

type
  Cave = ref object
    depth: int
    target: (int, int)
    geologicIndices, erosionLevels: Table[(int, int), int]
    regionTypes: Table[(int, int), RegionType]

proc newCave(depth: int, target: (int, int)): Cave =
  result.new
  result.depth = depth
  result.target = target

proc getErosionLevel(self: Cave, x, y: int): int
proc getGeologicIndex(self: Cave, x, y: int): int =
  if (x, y) in self.geologicIndices: return self.geologicIndices[(x, y)]
  result =
    if (x, y) == (0, 0): 0
    elif (x, y) == (self.target): 0
    elif y == 0: x * 16807
    elif x == 0: y * 48271
    else: self.getErosionLevel(x - 1, y) * self.getErosionLevel(x, y - 1)
  self.geologicIndices[(x, y)] = result

proc getErosionLevel(self: Cave, x, y: int): int =
  if (x, y) in self.erosionLevels: return self.erosionLevels[(x, y)]
  result = (self.getGeologicIndex(x, y) + self.depth) mod 20183
  self.erosionLevels[(x, y)] = result

proc getRegionType(self: Cave, x, y: int): RegionType =
  if (x, y) in self.regionTypes: return self.regionTypes[(x, y)]
  result = (self.getErosionLevel(x, y) mod 3).RegionType
  self.regionTypes[(x, y)] = result

proc riskLevel(self: Cave): int =
  for x in 0 .. self.target[0]:
    for y in 0 .. self.target[1]:
      result += self.getRegionType(x, y).int

proc part1(input: string): int =
  let (depth, target) = input.parse
  let cave = newCave(depth, target)
  cave.riskLevel

when defined(test):
  block:
    doAssert part1(input) == 114



const CLIMBING_GEAR = 0b10
const TORCH = 0b01
const NEITHER = 0b00

const VALID_TOOLS = [
  @[CLIMBING_GEAR, TORCH],    # rocky
  @[CLIMBING_GEAR, NEITHER],  # wet
  @[TORCH, NEITHER],          # narrow
]

proc isToolValid(self: Cave, x, y, tool: int): bool =
  let rt = self.getRegionType(x, y)
  tool in VALID_TOOLS[rt.ord]

const DPOS = [(-1, 0), (0, 1), (1, 0), (0, -1)]
const MOVE = 1
const CHANGE_GEAR = 7

proc bfs(cave: Cave): int =
  # steps, x, y, tool
  var q = initHeapQueue[(int, int, int, int)]()
  q.push (0, 0, 0, TORCH)
  # x, y, tool
  var visited = initHashSet[(int, int, int)]()
  while q.len > 0:
    let (steps, x, y, tool) = q.pop
    if (x, y, tool) in visited: continue
    visited.incl (x, y, tool)

    if (x, y, tool) == (cave.target[0], cave.target[1], TORCH): return steps
    for nextTool in [CLIMBING_GEAR, TORCH, NEITHER]:
      if not cave.isToolValid(x, y, nextTool): continue
      q.push (steps + CHANGE_GEAR, x, y, nextTool)

    for (dx, dy) in DPOS:
      let (nx, ny) = (x + dx, y + dy)
      if nx < 0 or ny < 0: continue
      if not cave.isToolValid(nx, ny, tool): continue
      q.push (steps + MOVE, nx, ny, tool)

proc part2(input: string): int =
  let (depth, target) = input.parse
  let cave = newCave(depth, target)
  cave.bfs

when defined(test):
  block:
    doAssert part2(input) == 45



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
