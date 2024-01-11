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
  Item = (int, int, int)

const WEAPONS = [
  (8, 4, 0),
  (10, 5, 0),
  (25, 6, 0),
  (40, 7, 0),
  (74, 8, 0),
]

const ARMORS = [
  (0, 0, 0),
  (13, 0, 1),
  (31, 0, 2),
  (53, 0, 3),
  (75, 0, 4),
  (102, 0, 5),
]

const RINGS = [
  (0, 0, 0),
  (25, 1, 0),
  (50, 2, 0),
  (100, 3, 0),
  (20, 0, 1),
  (40, 0, 2),
  (80, 0, 3),
]

iterator equipments(): (int, int, int) =
  for (wCost, wAtk, wDef) in WEAPONS:
    for (aCost, aAtk, aDef) in ARMORS:
      for (lCost, lAtk, lDef) in RINGS:
        for (rCost, rAtk, rDef) in RINGS:
          if lCost == rCost and lCost != 0: continue
          yield (
            wCost + aCost + lCost + rCost,
            wAtk + aAtk + lAtk + rAtk,
            wDef + aDef + lDef + rDef,
          )

type
  Player = (int, int, int)

proc wins(a, b: Player): bool =
  let (hp1, atk1, def1) = a
  let (hp2, atk2, def2) = b
  let damage1 = max(1, atk1 - def2)
  let damage2 = max(1, atk2 - def1)
  let t1 = (hp1 + damage2 - 1) div damage2
  let t2 = (hp2 + damage1 - 1) div damage1
  t1 >= t2

when defined(test):
  doAssert (8, 5, 5).wins (12, 7, 2)

proc equip(p: Player, e: Item): Player =
  (p[0], p[1] + e[1], p[2] + e[2])

proc parse(input: string): Player =
  let lines = input.split("\n")
  var hp, atk, def: int
  if lines[0] =~ re"Hit Points: (\d+)":
    hp = matches[0].parseInt
  if lines[1] =~ re"Damage: (\d+)":
    atk = matches[0].parseInt
  if lines[2] =~ re"Armor: (\d+)":
    def = matches[0].parseInt
  (hp, atk, def)

when defined(test):
  doAssert parse("""
Hit Points: 103
Damage: 9
Armor: 2
""".strip) == (103, 9, 2)

proc part1(input: string): int =
  let monster = input.parse
  let player = (100, 0, 0)
  result = int.high
  for e in equipments():
    let ep = player.equip(e)
    if ep.wins(monster):
      result = result.min e[0]

proc part2(input: string): int =
  let monster = input.parse
  let player = (100, 0, 0)
  for e in equipments():
    let ep = player.equip(e)
    if not ep.wins(monster):
      result = result.max e[0]



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
