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



const IMMUNE = 0
const INFECTION = 1

type
  Group = ref object
    units: int
    hp: int
    atk: int
    atkType: string
    initiative: int
    weaknesses: seq[string]
    immunities: seq[string]
    army: int

proc parseGroup(line: string): Group =
  if line =~ re"(\d+) units each with (\d+) hit points (?:\((.+)\) )?with an attack that does (\d+) (\w+) damage at initiative (\d+)":
    let
      units = matches[0].parseInt
      hp = matches[1].parseInt
      wis = matches[2]
      atk = matches[3].parseInt
      atkType = matches[4]
      initiative = matches[5].parseInt
    var weaknesses, immunities = newSeq[string]()
    for wi in wis.split("; "):
      if wi.startsWith("weak to "):
        weaknesses = wi[8 .. ^1].split(", ")
      elif wi.startsWith("immune to "):
        immunities = wi[10 .. ^1].split(", ")
    return Group(
      units: units,
      hp: hp,
      atk: atk,
      atkType: atkType,
      initiative: initiative,
      weaknesses: weaknesses,
      immunities: immunities,
    )

  raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    let line = "18 units each with 729 hit points (weak to fire; immune to cold, slashing) with an attack that does 8 radiation damage at initiative 10"
    let g = line.parseGroup
    doAssert g.units == 18
    doAssert g.hp == 729
    doAssert g.atk == 8
    doAssert g.atkType == "radiation"
    doAssert g.initiative == 10
    doAssert g.weaknesses == @["fire"]
    doAssert g.immunities == @["cold", "slashing"]

  block:
    let line = "933 units each with 3691 hit points with an attack that does 37 cold damage at initiative 15"
    let g = line.parseGroup
    doAssert g.units == 933
    doAssert g.hp == 3691
    doAssert g.atk == 37
    doAssert g.atkType == "cold"
    doAssert g.initiative == 15
    doAssert g.weaknesses == @[]
    doAssert g.immunities == @[]


proc parse(input: string): seq[Group] =
  let blocks = input.split("\n\n")
  for i, blk in blocks:
    let lines = blk.split("\n")
    for j, line in lines:
      if j == 0: continue
      var g = line.parseGroup
      g.army = i
      result.add g

when defined(test):
  let input = """
Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
""".strip
  block:
    let groups = input.parse
    doAssert groups.len == 4
    doAssert groups.countIt(it.army == 0) == 2

proc effectivePower(self: Group): int {.inline.} =
  self.units * self.atk

proc `<`(a, b: Group): bool =
  if a.effectivePower != b.effectivePower: a.effectivePower > b.effectivePower
  else: a.initiative > b.initiative

proc calcDamage(a, b: Group): int =
  if a.atkType in b.immunities: 0
  elif a.atkType in b.weaknesses: a.effectivePower * 2
  else: a.effectivePower

proc selectTargets(groups: seq[Group]): seq[int] =
  let N = groups.len
  result = newSeq[int](N)
  result.fill -1

  var attacked = newSeq[bool](N)
  for i, group in groups:
    var cands = newSeq[int]()
    for j, other in groups:
      if i == j: continue
      if group.army == other.army: continue
      if attacked[j]: continue
      cands.add j
    if cands.len == 0: continue
    let maxDamage = cands.mapIt(group.calcDamage(groups[it])).max
    if maxDamage == 0: continue
    cands = cands.filterIt group.calcDamage(groups[it]) == maxDamage
    if cands.len == 0: continue
    cands.sort
    let j = cands[0]
    result[i] = j
    attacked[j] = true

proc attack(a, b: Group): bool =
  let dmg = a.calcDamage(b)
  let decrease = dmg div b.hp
  b.units = max(0, b.units - decrease)
  decrease > 0

proc fight(groups: seq[Group]): (bool, seq[Group]) =
  let groups = groups.sorted
  let targets = groups.selectTargets
  let attackOrder = (0 ..< groups.len).toSeq.sortedByIt(-groups[it].initiative)
  var changed = false
  for i in attackOrder:
    let group = groups[i]
    if group.units == 0: continue
    let j = targets[i]
    if j == -1: continue
    let other = groups[j]
    if group.attack(other):
      changed = true
  (changed, groups.filterIt(it.units > 0))

proc combatEnded(groups: seq[Group]): bool =
  groups.countIt(it.army == IMMUNE) == 0 or groups.countIt(it.army == INFECTION) == 0

proc combat(groups: seq[Group]): seq[Group] =
  var groups = groups
  var changed = true
  while not groups.combatEnded and changed:
    (changed, groups) = groups.fight
  groups

proc totalUnits(groups: seq[Group]): int =
  groups.mapIt(it.units).sum

proc part1(input: string): int =
  var groups = input.parse
  groups = groups.combat
  groups.totalUnits

when defined(test):
  block:
    doAssert part1(input) == 5216



proc combat(groups: var seq[Group], boost: int): bool =
  for group in groups.mitems:
    if group.army == IMMUNE:
      group.atk += boost
  var changed = true
  while not groups.combatEnded and changed:
    (changed, groups) = groups.fight
  changed and groups.countIt(it.army == IMMUNE) > 0

when defined(test):
  block:
    var groups = input.parse
    doAssert groups.combat(1570)
    doAssert groups.totalUnits == 51

proc part2(input: string): int =
  var boost = 0
  var groups = input.parse
  while not combat(groups, boost):
    boost += 1
    groups = input.parse
  groups.totalUnits

when defined(test):
  block:
    doAssert part2(input) == 51



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
