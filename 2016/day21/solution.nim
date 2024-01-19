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
  InstType = enum
    SwapPos
    SwapLetter
    Rotate
    RotateFrom
    Reverse
    Move

  Inst = (InstType, string, string)

proc parseLine(line: string): Inst =
  if line =~ re"swap position (\d+) with position (\d+)":
    (SwapPos, matches[0], matches[1])
  elif line =~ re"swap letter (\w+) with letter (\w+)":
    (SwapLetter, matches[0], matches[1])
  elif line =~ re"rotate (left|right) (\d) steps?":
    (Rotate, matches[0], matches[1])
  elif line =~ re"rotate based on position of letter (\w+)":
    (RotateFrom, matches[0], "")
  elif line =~ re"reverse positions (\d+) through (\d+)":
    (Reverse, matches[0], matches[1])
  elif line =~ re"move position (\d+) to position (\d+)":
    (Move, matches[0], matches[1])
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  let input = """
swap position 4 with position 0
swap letter d with letter b
reverse positions 0 through 4
rotate left 1 step
move position 1 to position 4
move position 3 to position 0
rotate based on position of letter b
rotate based on position of letter d
""".strip
  block:
    let lines = input.split("\n")
    doAssert lines[0].parseLine == (SwapPos, "4", "0")
    doAssert lines[1].parseLine == (SwapLetter, "d", "b")
    doAssert lines[2].parseLine == (Reverse, "0", "4")
    doAssert lines[3].parseLine == (Rotate, "left", "1")
    doAssert lines[4].parseLine == (Move, "1", "4")
    doAssert lines[5].parseLine == (Move, "3", "0")
    doAssert lines[6].parseLine == (RotateFrom, "b", "")
    doAssert lines[7].parseLine == (RotateFrom, "d", "")

proc apply(s: string, inst: Inst): string =
  result = s
  case inst[0]:
  of SwapPos:
    let (x, y) = (inst[1].parseInt, inst[2].parseInt)
    swap(result[x], result[y])
  of SwapLetter:
    let (x, y) = (inst[1][0], inst[2][0])
    for i, c in s:
      if c == x: result[i] = y
      elif c == y: result[i] = x
  of Rotate:
    var x = inst[2].parseInt
    if inst[1] == "left": x = -x
    for i, c in s:
      result[(i + x + s.len) mod s.len] = c
  of RotateFrom:
    var x = s.find(inst[1][0])
    x = 1 + x + (if x >= 4: 1 else: 0)
    for i, c in s:
      result[(i + x) mod s.len] = c
  of Reverse:
    let (x, y) = (inst[1].parseInt, inst[2].parseInt)
    result.reverse(x, y)
  of Move:
    let (x, y) = (inst[1].parseInt, inst[2].parseInt)
    let t = result[x]
    if x < y:
      for i in x ..< y:
        result[i] = result[i + 1]
    else:
      for i in countdown(x, y + 1):
        result[i] = result[i - 1]
    result[y] = t

when defined(test):
  let insts = input.split("\n").mapIt(it.parseLine)
  block:
    let s = @[
      "abcde",
      "ebcda",
      "edcba",
      "abcde",
      "bcdea",
      "bdeac",
      "abdec",
      "ecabd",
      "decab",
    ]
    for i, inst in insts:
      doAssert s[i].apply(inst) == s[i + 1]

proc scramble(s: string, insts: seq[Inst]): string =
  result = s
  for inst in insts:
    result = result.apply(inst)

proc part1(input: string): string =
  let insts = input.split("\n").mapIt(it.parseLine)
  scramble("abcdefgh", insts)

proc part2(input: string): string =
  let insts = input.split("\n").mapIt(it.parseLine)
  var s = "abcdefgh"
  while s.scramble(insts) != "fbgdceah":
    s.nextPermutation
  s

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
