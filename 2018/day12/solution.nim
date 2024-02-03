import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



type
  State = tuple[left: int, pos: string]

proc parseInitialState(line: string): State =
  if line =~ re"initial state: ([.#]+)":
    (0, matches[0])
  else:
    raise newException(ValueError, "parse error " & line)

proc parseTransitions(lines: seq[string]): Table[string, char] =
  proc parseLine(line: string): (string, char) =
    if line =~ re"([.#]{5}) => ([.#])":
      (matches[0], matches[1][0])
    else:
      raise newException(ValueError, "parse error " & line)
  for line in lines:
    let (s, t) = line.parseLine
    result[s] = t

proc parse(input: string): (State, Table[string, char]) =
  let p = input.split("\n\n")
  let init = p[0].parseInitialState
  let trans = p[1].split("\n").parseTransitions
  (init, trans)

when defined(test):
  let input = """
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
""".strip
  block:
    let (init, trans) = input.parse
    doAssert init == (0, "#..#.#..##......###...###")
    doAssert trans["...##"] == '#'

proc step(state: State, trans: Table[string, char]): State =
  var (left, pos) = state
  pos = &"....{pos}...."
  left -= 2
  var res = ""
  for i in 2 ..< pos.len:
    if i + 2 >= pos.len: break
    let cur = pos[i - 2 .. i + 2]
    if cur in trans:
      res &= trans[cur]
    else:
      res &= '.'
  let i = res.find('#')
  let j = res.rfind('#')
  (left + i, res[i .. j])

when defined(test):
  block:
    let a = @[
      (0, "#..#.#..##......###...###"),
      (0, "#...#....#.....#..#..#..#"),
      (0, "##..##...##....#..#..#..##"),
      (-1, "#.#...#..#.#....#..#..#...#"),
      (0, "#.#..#...#.#...#..#..##..##"),
      (1, "#...##...#.#..#..#...#...#"),
      (1, "##.#.#....#...#..##..##..##"),
      (0, "#..###.#...##..#...#...#...#"),
      (0, "#....##.#.#.#..##..##..##..##"),
      (0, "##..#..#####....#...#...#...#"),
      (-1, "#.#..#...#.##....##..##..##..##"),
      (0, "#...##...#.#...#.#...#...#...#"),
      (0, "##.#.#....#.#...#.#..##..##..##"),
      (-1, "#..###.#....#.#...#....#...#...#"),
      (-1, "#....##.#....#.#..##...##..##..##"),
      (-1, "##..#..#.#....#....#..#.#...#...#"),
      (-2, "#.#..#...#.#...##...#...#.#..##..##"),
      (-1, "#...##...#.#.#.#...##...#....#...#"),
      (-1, "##.#.#....#####.#.#.#...##...##..##"),
      (-2, "#..###.#..#.#.#######.#.#.#..#.#...#"),
      (-2, "#....##....#####...#######....#.#..##"),
    ]
    var (state, trans) = input.parse
    doAssert state == a[0]
    for i in 1 ..< a.len:
      state = state.step(trans)
      doAssert state == a[i]

proc calc(state: State): int =
  let (left, pos) = state
  for i, c in pos:
    if c == '#': result += left + i

when defined(test):
  block:
    doAssert calc((-2, "#....##....#####...#######....#.#..##")) == 325

proc part1(input: string): int =
  var (state, trans) = input.parse
  for _ in 0 ..< 20:
    state = state.step(trans)
  calc(state)

proc part2(input: string): int =
  let N = 5e10.int
  var seenPos = initTable[string, (int, int)]()
  var seenList = newSeq[string]()
  var (state, trans) = input.parse
  while state.pos notin seenPos:
    seenPos[state.pos] = (seenPos.len, state.left)
    seenList.add state.pos
    state = state.step(trans)
  let (start, prev) = seenPos[state.pos]
  let offset = state.left - prev
  let cycleLen = seenPos.len - start
  let cycles = (N - start) div cycleLen
  let remain = (N - start) mod cycleLen
  let pos = seenList[start + remain]
  let left = prev + offset * cycles
  calc((left, pos))



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
