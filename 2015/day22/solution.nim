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
  Effect = enum
    Shield = 0
    Poison
    Recharge

  Spell = enum
    Missile = 0
    Drain
    Shield
    Poison
    Recharge

  State = object
    mana, hp, def: int
    effects: array[3, int]
    totalCast: int
    oHp, oAtk: int

const SPELLS = [
  (Missile, 53),
  (Drain, 73),
  (Shield, 113),
  (Poison, 173),
  (Recharge, 229),
]

proc hasWon(s: State): bool =
  s.oHp <= 0

proc hasLost(s: State): bool =
  s.hp <= 0

proc turnStart(s: State, debuff = 0): State =
  result = s
  result.hp -= debuff
  if s.effects[Effect.Shield.ord] > 0:
    result.effects[Effect.Shield.ord] -= 1
    if result.effects[Effect.Shield.ord] == 0:
      result.def = 0
  if s.effects[Effect.Poison.ord] > 0:
    result.ohp -= 3
    result.effects[Effect.Poison.ord] -= 1
  if s.effects[Effect.Recharge.ord] > 0:
    result.mana += 101
    result.effects[Effect.Recharge.ord] -= 1

proc bossTurn(s: State): State =
  result = s
  let dmg = max(1, s.oAtk - s.def)
  result.hp -= dmg

proc playerTurn(s: State, sp: Spell): (bool, State) =
  var res = s
  let (sp, m) = SPELLS[sp.ord]
  if res.mana < m: return (false, res)

  res.mana -= m
  res.totalCast += m
  case sp:
  of Missile:
    res.oHp -= 4
  of Drain:
    res.oHp -= 2
    res.hp += 2
  of Shield:
    if res.effects[Effect.Shield.ord] > 0: return (false, res)
    res.def += 7
    res.effects[Effect.Shield.ord] = 6
  of Poison:
    if res.effects[Effect.Poison.ord] > 0: return (false, res)
    res.effects[Effect.Poison.ord] = 6
  of Recharge:
    if res.effects[Effect.Recharge.ord] > 0: return (false, res)
    res.effects[Effect.Recharge.ord] = 5
  (true, res)

when defined(test):
  block:
    var s = State(hp: 10, mana: 250, oHp: 13, oAtk: 8)

    doAssert (s.hp, s.def, s.mana) == (10, 0, 250)
    doAssert s.oHp == 13
    s = s.turnStart
    block:
      let (ok, t) = s.playerTurn(Poison)
      doAssert ok
      s = t

    doAssert (s.hp, s.def, s.mana) == (10, 0, 77)
    doAssert s.oHp == 13
    s = s.turnStart
    s = s.bossTurn

    doAssert (s.hp, s.def, s.mana) == (2, 0, 77)
    doAssert s.oHp == 10
    s = s.turnStart
    block:
      let (ok, t) = s.playerTurn(Missile)
      doAssert ok
      s = t

    doAssert (s.hp, s.def, s.mana) == (2, 0, 24)
    doAssert s.oHp == 3
    s = s.turnStart
    doAssert s.hasWon
    echo s

  block:
    var s = State(hp: 10, mana: 250, oHp: 14, oAtk: 8)

    doAssert (s.hp, s.def, s.mana) == (10, 0, 250)
    doAssert s.oHp == 14
    s = s.turnStart
    block:
      let (ok, t) = s.playerTurn(Recharge)
      doAssert ok
      s = t

    doAssert (s.hp, s.def, s.mana) == (10, 0, 21)
    doAssert s.oHp == 14
    s = s.turnStart
    s = s.bossTurn

    doAssert (s.hp, s.def, s.mana) == (2, 0, 122)
    doAssert s.oHp == 14
    s = s.turnStart
    block:
      let (ok, t) = s.playerTurn(Shield)
      doAssert ok
      s = t

    doAssert (s.hp, s.def, s.mana) == (2, 7, 110)
    doAssert s.oHp == 14
    s = s.turnStart
    s = s.bossTurn

    doAssert (s.hp, s.def, s.mana) == (1, 7, 211)
    doAssert s.oHp == 14
    s = s.turnStart
    block:
      let (ok, t) = s.playerTurn(Drain)
      doAssert ok
      s = t

    doAssert (s.hp, s.def, s.mana) == (3, 7, 239)
    doAssert s.oHp == 12
    s = s.turnStart
    s = s.bossTurn

    doAssert (s.hp, s.def, s.mana) == (2, 7, 340)
    doAssert s.oHp == 12
    s = s.turnStart
    block:
      let (ok, t) = s.playerTurn(Poison)
      doAssert ok
      s = t

    doAssert (s.hp, s.def, s.mana) == (2, 7, 167)
    doAssert s.oHp == 12
    s = s.turnStart
    s = s.bossTurn

    doAssert (s.hp, s.def, s.mana) == (1, 7, 167)
    doAssert s.oHp == 9
    s = s.turnStart
    block:
      let (ok, t) = s.playerTurn(Missile)
      doAssert ok
      s = t

    doAssert (s.hp, s.def, s.mana) == (1, 0, 114)
    doAssert s.oHp == 2
    s = s.turnStart
    doAssert s.hasWon
    echo s

proc parse(input: string): (int, int) =
  let lines = input.split("\n")
  var hp, atk: int
  if lines[0] =~ re"Hit Points: (\d+)":
    hp = matches[0].parseInt
  if lines[1] =~ re"Damage: (\d+)":
    atk = matches[0].parseInt
  (hp, atk)

when defined(test):
  doAssert parse("""
Hit Points: 71
Damage: 10
""".strip) == (71, 10)

proc calc(s: State, hard = false): int =
  var q = @[s]
  var playerTurn = true
  var res = int.high
  while q.len > 0 and res == int.high:
    var next: typeof q = @[]
    for s in q:
      let t = s.turnStart(if hard and playerTurn: 1 else: 0)
      if t.hasWon:
        res = res.min t.totalCast
        continue
      if playerTurn:
        for (sp, _) in SPELLS:
          let (ok, t1) = t.playerTurn(sp)
          if not ok: continue
          if t1.hasWon:
            res = res.min t1.totalCast
          else:
            next.add t1
      else:
        let t1 = t.bossTurn
        if not t1.hasLost:
          next.add t1
    q = next
    playerTurn = not playerTurn
  res

proc part1(input: string): int =
  let (oHp, oAtk) = input.parse
  let s = State(hp: 50, mana: 500, oHp: oHp, oAtk: oAtk)
  calc(s)

proc part2(input: string): int =
  let (oHp, oAtk) = input.parse
  let s = State(hp: 50, mana: 500, oHp: oHp, oAtk: oAtk)
  calc(s, true)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
