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
  Deck = seq[int]

proc initDeck(n: int): Deck =
  (0 ..< n).toSeq

proc dealNew(self: var Deck) =
  self.reverse

when defined(test):
  block:
    var deck = initDeck(10)
    deck.dealNew
    doAssert deck == @[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

proc cut(self: var Deck, n: int) =
  let M = self.len
  let i = (n + M) mod M
  self = self[i ..< M] & self[0 ..< i]

when defined(test):
  block:
    var deck = initDeck(10)
    deck.cut(3)
    doAssert deck == @[3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
  block:
    var deck = initDeck(10)
    deck.cut(-4)
    doAssert deck == @[6, 7, 8, 9, 0, 1, 2, 3, 4, 5]

proc dealInc(self: var Deck, n: int) =
  let M = self.len
  var deck = newSeq[int](M)
  for i, x in self:
    deck[i * n mod M] = x
  self = deck

when defined(test):
  block:
    var deck = initDeck(10)
    deck.dealInc(3)
    doAssert deck == @[0, 7, 4, 1, 8, 5, 2, 9, 6, 3]

type
  DealType {.pure.} = enum
    DEAL_NEW
    CUT
    DEAL_INC

proc parseLine(line: string): (DealType, int) =
  if line =~ re"cut (-?\d+)":
    return (CUT, matches[0].parseInt)
  if line =~ re"deal with increment (\d+)":
    return (DEAL_INC, matches[0].parseInt)
  if line == "deal into new stack":
    return (DEAL_NEW, 0)
  raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert "cut 123".parseLine == (CUT, 123)
    doAssert "cut -456".parseLine == (CUT, -456)
    doAssert "deal with increment 789".parseLine == (DEAL_INC, 789)
    doAssert "deal into new stack".parseLine == (DEAL_NEW, 0)

proc parse(input: string): seq[(DealType, int)] {.inline.} =
  input.split("\n").mapIt(it.parseLine)

proc deal(deck: var Deck, deals: seq[(DealType, int)]) =
  for (dt, p) in deals:
    case dt
    of DEAL_NEW: deck.dealNew
    of CUT: deck.cut(p)
    of DEAL_INC: deck.dealInc(p)

when defined(test):
  let input = """
deal with increment 7
deal into new stack
deal into new stack
""".strip
  block:
    var deck = initDeck(10)
    deck.deal(input.parse)
    doAssert deck == @[0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
  let input1 = """
cut 6
deal with increment 7
deal into new stack
""".strip
  block:
    var deck = initDeck(10)
    deck.deal(input1.parse)
    doAssert deck == @[3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
  let input2 = """
deal with increment 7
deal with increment 9
cut -2
""".strip
  block:
    var deck = initDeck(10)
    deck.deal(input2.parse)
    doAssert deck == @[6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
  let input3 = """
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
""".strip
  block:
    var deck = initDeck(10)
    deck.deal(input3.parse)
    doAssert deck == @[9, 2, 5, 8, 1, 4, 7, 0, 3, 6]

proc part1(input: string): int =
  var deck = initDeck(10007)
  deck.deal(input.parse)
  deck.find(2019)



import ../../lib/matrix
import bigints

# const MOD = initBigInt(10)
# const MOD = initBigInt(10007)
const MOD = initBigInt(119315717514047)

type
  mint* = distinct BigInt

proc `+`*(x, y: mint): mint {.inline.} = (((x.BigInt mod MOD) + (y.BigInt mod MOD) + MOD) mod MOD).mint
proc `-`*(x, y: mint): mint {.inline.} = (((x.BigInt mod MOD) - (y.BigInt mod MOD) + MOD) mod MOD).mint
proc `*`*(x, y: mint): mint {.inline.} = ((x.BigInt mod MOD) * (y.BigInt mod MOD) mod MOD).mint
proc `^`*(x, y: mint): mint =
  let zero = 0.initBigInt
  let one = 1.initBigInt
  result = one.mint
  var
    x = x
    y = y.BigInt
  while y > zero:
    if (y and one) != zero: result = result * x
    x = x * x
    y = y shr 1
proc `/`*(x, y: mint): mint =
  x * (y ^ (MOD - 2.initBigInt).mint)

proc initMint(n: int): mint {.inline.} =
  initBigInt(n).mint

type
  DeckPos = SquareMatrix[mint]

proc newDeckPos(p: int): DeckPos {.inline.} =
  newSquareMatrix(@[
    @[initMint(p), initMint(0)],
    @[initMint(0), initMint(1)]
  ])

proc pos(self: DeckPos): int {.inline.} =
  ($(self.a[0][0] + self.a[0][1]).BigInt).parseInt

let DEAL_NEW = newSquareMatrix(@[
  @[initMint(-1), (MOD - initBigInt(1)).mint],
  @[initMint(0), initMint(1)]
])

when defined(test):
  block:
    let a = @[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    for i in 0 ..< 10:
      let dp = DEAL_NEW * newDeckPos(i)
      doAssert a[dp.pos] == i

proc CUT(o: int): SquareMatrix[mint] {.inline.} =
  newSquareMatrix(@[
    @[initMint(1), initMint(-o)],
    @[initMint(0), initMint(1)]
  ])

when defined(test):
  block:
    let t = CUT(3)
    let a = @[3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
    for i in 0 ..< 10:
      let dp = t * newDeckPos(i)
      doAssert a[dp.pos] == i
  block:
    let t = CUT(-4)
    let a = @[6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
    for i in 0 ..< 10:
      let dp = t * newDeckPos(i)
      doAssert a[dp.pos] == i

proc DEAL_INC(o: int): SquareMatrix[mint] {.inline.} =
  newSquareMatrix(@[
    @[initMint(o), initMint(0)],
    @[initMint(0), initMint(1)]
  ])

when defined(test):
  block:
    let t = DEAL_INC(3)
    let a = @[0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
    for i in 0 ..< 10:
      let dp = t * newDeckPos(i)
      doAssert a[dp.pos] == i

proc deal(deals: seq[(DealType, int)]): SquareMatrix[mint] =
  result = identity(2, initMint(1))
  for (dt, p) in deals:
    case dt
    of DEAL_NEW: result = DEAL_NEW * result
    of CUT: result = CUT(p) * result
    of DEAL_INC: result = DEAL_INC(p) * result

when defined(test):
  block:
    let t = input.parse.deal
    let a = @[0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
    for i in 0 ..< 10:
      let dp = t * newDeckPos(i)
      doAssert a[dp.pos] == i
  block:
    let t = input1.parse.deal
    let a = @[3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
    for i in 0 ..< 10:
      let dp = t * newDeckPos(i)
      doAssert a[dp.pos] == i
  block:
    let t = input2.parse.deal
    let a = @[6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
    for i in 0 ..< 10:
      let dp = t * newDeckPos(i)
      doAssert a[dp.pos] == i
  block:
    let t = input3.parse.deal
    let a = @[9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
    for i in 0 ..< 10:
      let dp = t * newDeckPos(i)
      doAssert a[dp.pos] == i

proc inv(t: SquareMatrix[mint]): SquareMatrix[mint] =
  let (a, b) = (t.a[0][0], t.a[0][1])
  let (c, d) = (t.a[1][0], t.a[1][1])
  let p = 1.initBigInt.mint / (a * d - b * c)
  newSquareMatrix(@[
    @[p * d, 0.initBigInt.mint - p * b],
    @[0.initBigInt.mint - p * c, p * a]
  ])

proc part2(input: string): int =
  let repeats = 101741582076661
  var t = input.parse.deal
  t = `^`(t, repeats, initMint(1))
  t = t.inv
  let dp = t * newDeckPos(2020)
  dp.pos

# proc part1(input: string): int =
#   var t = input.parse.deal
#   let dp = t * newDeckPos(2019)
#   dp.pos

when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
