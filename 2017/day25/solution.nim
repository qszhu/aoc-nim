import std/[
  algorithm,
  bitops,
  deques,
  intsets,
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
  Action = tuple[write, move: int, next: string]

proc parseAction(lines: seq[string]): Action =
  var write: int
  if lines[0] =~ re"    - Write the value (\d+).":
    write = matches[0].parseInt
  else:
    raise newException(ValueError, "parse error: " & lines[0])

  var move: int
  if lines[1] =~ re"    - Move one slot to the (\w+).":
    move = if matches[0] == "left": -1 else: 1
  else:
    raise newException(ValueError, "parse error: " & lines[1])

  var next: string
  if lines[2] =~ re"    - Continue with state (\w+).":
    next = matches[0]
  else:
    raise newException(ValueError, "parse error: " & lines[2])
  (write, move, next)

type
  State = tuple[name: string, actions: array[2, Action]]

proc parseState(s: string): State =
  let lines = s.split("\n")

  var name: string
  if lines[0] =~ re"In state (\w+):":
    name = matches[0]
  else:
    raise newException(ValueError, "parse error: " & lines[0])

  (name, [
    lines[2 .. 4].parseAction,
    lines[6 .. 8].parseAction
  ])

proc parse(input: string): (string, int, seq[State]) =
  let blocks = input.split("\n\n")

  let header = blocks[0].split("\n")

  var ss: string
  if header[0] =~ re"Begin in state (\w+).":
    ss = matches[0]
  else:
    raise newException(ValueError, "parse error: " & header[0])

  var steps: int
  if header[1] =~ re"Perform a diagnostic checksum after (\d+) steps.":
    steps = matches[0].parseInt
  else:
    raise newException(ValueError, "parse error: " & header[1])

  let states = blocks[1 .. ^1].mapIt(it.parseState)
  (ss, steps, states)

when defined(test):
  let input = """
Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state B.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
""".strip
  block:
    doAssert input.parse == ("A", 6, @[
      ("A", [(1, 1, "B"), (0, -1, "B")]),
      ("B", [(1, -1, "A"), (1, 1, "A")])
    ])

proc part1(input: string): int =
  let (start, steps, states) = input.parse
  var cur = start
  var pos = 0
  var ones = initIntSet()
  for _ in 0 ..< steps:
    let state = states.filterIt(it.name == cur)[0]
    let val = if pos in ones: 1 else: 0
    let (write, move, next) = state.actions[val]
    if write == 1:
      ones.incl pos
    else:
      if pos in ones: ones.excl pos
    pos += move
    cur = next
  ones.len

when defined(test):
  block:
    doAssert part1(input) == 3



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
