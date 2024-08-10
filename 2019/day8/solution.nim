import ../../lib/imports



type
  Layer = seq[seq[int]]

type
  Image = ref object
    rows, cols: int
    layers: seq[Layer]

proc parse(input: string, rows, cols: int): Image =
  result.new
  result.rows = rows
  result.cols = cols
  let numLayers = input.len div rows div cols
  var i = 0
  for _ in 0 ..< numLayers:
    var layer = newSeqWith(rows, newSeq[int](cols))
    for r in 0 ..< rows:
      for c in 0 ..< cols:
        layer[r][c] = input[i].ord - '0'.ord
        i += 1
    result.layers.add layer

when defined(test):
  block:
    let input = """
123456789012
""".strip
    let img = input.parse(2, 3)
    doAssert img.layers == @[
      @[@[1,2,3],@[4,5,6]],
      @[@[7,8,9],@[0,1,2]]
    ]

proc countDigit(l: Layer, d: int): int {.inline.} =
  l.map(row => row.countIt(it == d)).sum

proc part1(input: string): int =
  let img = input.parse(6, 25)
  let zeros = img.layers.mapIt(it.countDigit(0))
  let i = zeros.find(zeros.min)
  img.layers[i].countDigit(1) * img.layers[i].countDigit(2)



proc merge(img: Image): Layer =
  result = newSeqWith(img.rows, newSeq[int](img.cols))
  for r in 0 ..< img.rows:
    for c in 0 ..< img.cols:
      for layer in img.layers:
        if layer[r][c] != 2:
          result[r][c] = layer[r][c]
          break

when defined(test):
  block:
    let input = """
0222112222120000
""".strip
    let img = input.parse(2, 2)
    doAssert img.merge == @[@[0,1],@[1,0]]

proc `$`(self: Layer): string =
  self.mapIt(it.join.replace("1", "#").replace("0", " ")).join("\n")

proc part2(input: string): string =
  let img = input.parse(6, 25)
  let layer = img.merge
  $layer



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
