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
  Group = tuple[left, right, depth: int]

iterator groups(s: string): Group =
  var st = newSeq[int]()
  var depth, i = 0
  var garbage = false
  while i < s.len:
    case s[i]:
    of '{':
      if not garbage:
        st.add i
        depth += 1
    of '}':
      if not garbage:
        let left = st.pop
        yield (left, i, depth)
        depth -= 1
    of '<':
      if not garbage:
        garbage = true
    of '>':
      if garbage:
        garbage = false
    of '!':
      i += 1
    else:
      discard
    i += 1

when defined(test):
  block:
    doAssert "{}".groups.toSeq == @[(0, 1, 1)]
    doAssert "{{{}}}".groups.toSeq == @[(2, 3, 3), (1, 4, 2), (0, 5, 1)]
    doAssert "{{},{}}".groups.toSeq == @[(1, 2, 2), (4, 5, 2), (0, 6, 1)]
    doAssert "{{{},{},{{}}}}".groups.toSeq == @[(2, 3, 3), (5, 6, 3),
      (9, 10, 4), (8, 11, 3), (1, 12, 2), (0, 13, 1)]
    doAssert "{<{},{},{{}}>}".groups.toSeq == @[(0, 13, 1)]
    doAssert "{<a>,<a>,<a>,<a>}".groups.toSeq == @[(0, 16, 1)]
    doAssert "{{<a>},{<a>},{<a>},{<a>}}".groups.toSeq == @[(1, 5, 2),
      (7, 11, 2), (13, 17, 2), (19, 23, 2), (0, 24, 1)]
    doAssert "{{<!>},{<!>},{<!>},{<a>}}".groups.toSeq == @[(1, 23, 2),
      (0, 24, 1)]

proc score(s: string): int =
  for (left, right, depth) in s.groups:
    result += depth

when defined(test):
  block:
    doAssert "{}".score == 1
    doAssert "{{{}}}".score == 6
    doAssert "{{},{}}".score == 5
    doAssert "{{{},{},{{}}}}".score == 16
    doAssert "{<a>,<a>,<a>,<a>}".score == 1
    doAssert "{{<ab>},{<ab>},{<ab>},{<ab>}}".score == 9
    doAssert "{{<!!>},{<!!>},{<!!>},{<!!>}}".score == 9
    doAssert "{{<a!>},{<a!>},{<a!>},{<ab>}}".score == 3

proc part1(input: string): int =
  input.score



iterator garbages(s: string): string =
  var i = 0
  var garbage = false
  var res = ""
  while i < s.len:
    if s[i] == '!':
      i += 2
      continue
    if garbage:
      if s[i] == '>':
        garbage = false
        yield res
      else:
        res &= s[i]
    else:
      if s[i] == '<':
        garbage = true
        res = ""
    i += 1

when defined(test):
  block:
    doAssert "<>".garbages.toSeq == @[""]
    doAssert "<random characters>".garbages.toSeq == @["random characters"]
    doAssert "<<<<>".garbages.toSeq == @["<<<"]
    doAssert "<{!>}>".garbages.toSeq == @["{}"]
    doAssert "<!!>".garbages.toSeq == @[""]
    doAssert "<!!!>>".garbages.toSeq == @[""]
    doAssert "<{o\"i!a,<{i<a>".garbages.toSeq == @["{o\"i,<{i<a"]

proc part2(input: string): int =
  for g in input.garbages:
    result += g.len



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
