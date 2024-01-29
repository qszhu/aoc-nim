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
  Block = seq[string]

proc `$`(self: Block): string =
  self.join("/")

proc fromString(s: string): Block =
  s.split("/")

proc parseLine(line: string): (Block, Block) =
  let p = line.split(" => ")
  (p[0].fromString, p[1].fromString)

when defined(test):
  block:
    doAssert "../.. => .##/.##/###".parseLine == (
      @["..", ".."],
      @[".##", ".##", "###"]
    )

proc rotate(self: Block): Block =
  result = self
  let (rows, cols) = (result.len, result[0].len)
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      result[cols - 1 - c][r] = self[r][c]

when defined(test):
  block:
    doAssert ".#./..#/###".fromString.rotate == @[".##", "#.#", "..#"]
    doAssert ".##/#.#/..#".fromString.rotate == @["###", "#..", ".#."]
    doAssert "###/#../.#.".fromString.rotate == @["#..", "#.#", "##."]
    doAssert "#../#.#/##.".fromString.rotate == @[".#.", "..#", "###"]

proc flip(self: Block): Block =
  result = self
  for r in result.mitems:
    r.reverse

when defined(test):
  block:
    doAssert ".#./..#/###".fromString.flip == @[".#.", "#..", "###"]

proc crop(self: Block, r, c, size: int): Block =
  result = newSeq[string]()
  for r1 in 0 ..< size:
    result.add self[r + r1][c ..< c + size]

proc split(self: Block, size: int): seq[seq[Block]] =
  let (rows, cols) = (self.len, self[0].len)
  for r in countup(0, rows - 1, size):
    var row = newSeq[Block]()
    for c in countup(0, cols - 1, size):
      row.add self.crop(r, c, size)
    result.add row

when defined(test):
  block:
    doAssert "#..#/..../..../#..#".fromString.split(2) == @[
      @[@["#.", ".."], @[".#", ".."]],
      @[@["..", "#."], @["..", ".#"]],
    ]

proc merge(blocks: seq[seq[Block]]): Block =
  let (rows, cols) = (blocks.len, blocks[0].len)
  let size = blocks[0][0].len
  result = newSeqWith(rows * size, newString(cols * size))
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      for r1 in 0 ..< size:
        for c1 in 0 ..< size:
          result[r * size + r1][c * size + c1] = blocks[r][c][r1][c1]

when defined(test):
  block:
    doAssert merge(@[
      @[@["#.", ".."], @[".#", ".."]],
      @[@["..", "#."], @["..", ".#"]],
    ]) == @["#..#", "....", "....", "#..#"]

proc parse(input: string): Table[string, string] =
  for line in input.split("\n"):
    var (fromBlock, toBlock) = parseLine(line)
    for _ in 0 ..< 4:
      fromBlock = fromBlock.rotate
      result[$fromBlock] = $toBlock
    fromBlock = fromBlock.flip
    for _ in 0 ..< 4:
      fromBlock = fromBlock.rotate
      result[$fromBlock] = $toBlock

proc step(b: Block, book: Table[string, string]): Block =
  for size in [2, 3]:
    if b.len mod size != 0: continue
    var blocks = b.split(size)
    for r in blocks.mitems:
      for blk in r.mitems:
        blk = book[$blk].fromString
    return blocks.merge

proc countOn(b: Block): int =
  b.map(row => row.countIt(it == '#')).sum

when defined(test):
  let input = """
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
""".strip
  block:
    let book = input.parse
    var b = ".#./..#/###".fromString

    b = b.step(book)
    doAssert $b == "#..#/..../..../#..#"

    b = b.step(book)
    doAssert $b == "##.##./#..#../....../##.##./#..#../......"

    doAssert b.countOn == 12

proc part1(input: string): int =
  let book = input.parse
  var b = ".#./..#/###".fromString
  for _ in 0 ..< 5:
    b = b.step(book)
  b.countOn

proc part2(input: string): int =
  let book = input.parse
  var b = ".#./..#/###".fromString
  for _ in 0 ..< 18:
    b = b.step(book)
  b.countOn



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
