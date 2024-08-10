import ../../lib/imports



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
    (CUT, matches[0].parseInt)
  elif line =~ re"deal with increment (\d+)":
    (DEAL_INC, matches[0].parseInt)
  elif line == "deal into new stack":
    (DEAL_NEW, 0)
  else:
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



when defined(test):
  modBigint(10)
else:
  modBigInt(119315717514047)

type
  DeckPos = SquareMatrix[mint]

#[
[p, 0]
[0, 1]
]#
proc newDeckPos(p: int): DeckPos {.inline.} =
  newSquareMatrix(@[
    @[initMint(p), initMint(0)],
    @[initMint(0), initMint(1)]
  ])

proc pos(self: DeckPos): int {.inline.} =
  ($(self[0][0] + self[0][1]).BigInt).parseInt



#[
[-1, N - 1]
[0, 1]
]#
let DEAL_NEW = newSquareMatrix(@[
  @[initMint(-1), (MOD - One).mint],
  @[initMint(0), initMint(1)]
])

when defined(test):
  block:
    let a = @[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    for i in 0 ..< 10:
      let dp = DEAL_NEW * newDeckPos(i)
      doAssert a[dp.pos] == i



#[
[1, -o]
[0, 1]
]#
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



#[
[o, 0]
[0, 1]
]#
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
  let (a, b) = (t[0][0], t[0][1])
  let (c, d) = (t[1][0], t[1][1])
  let p = One.mint / (a * d - b * c)
  newSquareMatrix(@[
    @[p * d, initMint(0) - p * b],
    @[initMint(0) - p * c, p * a]
  ])

proc part2(input: string): int =
  const repeats = 101741582076661
  var t = input.parse.deal
  t = t.`**`(repeats, initMint(1))
  t = t.inv
  (t * newDeckPos(2020)).pos



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
