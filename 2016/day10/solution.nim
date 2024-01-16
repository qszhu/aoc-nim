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
  TargetType = enum
    BotType
    OutputType

  Target = (TargetType, int)

  Bot = ref object
    id: int
    lo, hi: Target
    values: seq[int]

proc newBot(id: int): Bot =
  result.new
  result.id = id

type
  Factory = ref object
    bots: Table[int, Bot]
    outputs: Table[int, int]

proc newFactory(): Factory =
  result.new
  result.bots = initTable[int, Bot]()
  result.outputs = initTable[int, int]()

proc parse(input: string): Factory =
  var factory = newFactory()
  proc createOrGetBot(id: int): Bot =
    if id notin factory.bots:
      factory.bots[id] = newBot(id)
    factory.bots[id]

  for line in input.split("\n"):
    if line =~ re"value (\d+) goes to bot (\d+)":
      let (a, b) = (matches[0].parseInt, matches[1].parseInt)
      var bot = createOrGetBot(b)
      bot.values.add a
    elif line =~ re"bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)":
      let (a, t1, b, t2, c) = (matches[0].parseInt, matches[1], matches[2].parseInt, matches[3], matches[4].parseInt)
      var bot = createOrGetBot(a)
      bot.lo = ((if t1 == "bot": TargetType.BotType else: TargetType.OutputType), b)
      bot.hi = ((if t2 == "bot": TargetType.BotType else: TargetType.OutputType), c)
    else:
      raise newException(CatchableError, "parse error: " & line)

  factory

proc run(self: Factory, ta, tb: int): int =
  var (ta, tb) = (ta, tb)
  if ta > tb: swap(ta, tb)

  var q = newSeq[Bot]()
  for b in self.bots.values:
    if b.values.len == 2:
      q.add b
  while q.len > 0:
    var next: typeof q = @[]
    for bot in q:
      var (a, b) = (bot.values[0], bot.values[1])
      if a > b: swap(a, b)
      bot.values = @[]

      if (a, b) == (ta, tb): result = bot.id

      let (lt, lid) = bot.lo
      if lt == TargetType.BotType:
        self.bots[lid].values.add a
        if self.bots[lid].values.len == 2:
          next.add self.bots[lid]
      else:
        self.outputs[lid] = a

      let (ht, hid) = bot.hi
      if ht == TargetType.BotType:
        self.bots[hid].values.add b
        if self.bots[hid].values.len == 2:
          next.add self.bots[hid]
      else:
        self.outputs[hid] = b

    q = next

when defined(test):
  let input = """
value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2
""".strip
  let factory = parse(input)
  doAssert factory.run(5, 2) == 2
  doAssert factory.outputs[0] == 5
  doAssert factory.outputs[1] == 2
  doAssert factory.outputs[2] == 3

proc part1(input: string): int =
  let factory = parse(input)
  factory.run(61, 17)

proc part2(input: string): int =
  let factory = parse(input)
  discard factory.run(61, 17)
  factory.outputs[0] * factory.outputs[1] * factory.outputs[2]

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
