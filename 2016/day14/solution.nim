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

import checksums/md5



proc findThree(s: string): int =
  var m: array[1, string]
  if s.find(re"([0-9a-f])\1{2}", m) == -1: return -1
  fromHex[int](m[0])

proc findFives(s: string): seq[int] =
  s.findAll(re"([0-9a-f])\1{4}").mapIt(fromHex[int]($it[0]))

when defined(test):
  block:
    let t = "122333444455555666666"
    doAssert t.findThree == 3
    doAssert t.findFives == @[5, 6]

iterator genKeys(prefix: string, hfunc: proc (s: string): string): int =
  var threes = initDeque[(int, int)]()
  var fives: array[16, Deque[int]]

  proc addHash(i: int, h: string) =
    let t = h.findThree
    if t != -1:
      threes.addLast (i, t)
    for f in h.findFives:
      fives[f].addLast i

  for i in 0 .. 1000:
    let h = hfunc(&"{prefix}{i}")
    addHash(i, h)

  var i = 0
  while true:
    while threes.len > 0 and threes[0][0] < i:
      discard threes.popFirst
    if threes.len > 0 and threes[0][0] == i:
      let t = threes[0][1]
      while fives[t].len > 0 and fives[t][0] <= i:
        discard fives[t].popFirst
      if fives[t].len > 0 and fives[t][0] <= i + 1000:
        yield i

    i += 1
    let h = hfunc(&"{prefix}{i + 1000}")
    addHash(i + 1000, h)

when defined(test):
  block:
    var indices = newSeq[int]()
    for i in genKeys("abc", getMD5):
      indices.add i
      if indices.len == 64: break
    doAssert indices[0] == 39
    doAssert indices[1] == 92
    doAssert indices[^1] == 22728

proc part1(input: string): int =
  var c = 0
  for i in genKeys(input, getMD5):
    c += 1
    if c == 64: return i

proc stretch(s: string): string =
  result = getMD5(s)
  for _ in 1 .. 2016:
    result = getMD5(result)

when defined(test):
  block:
    doAssert stretch("abc0") == "a107ff634856bb300138cac6568c0f24"

  block:
    var indices = newSeq[int]()
    for i in genKeys("abc", stretch):
      indices.add i
      if indices.len == 64: break
    doAssert indices[0] == 10
    doAssert indices[^1] == 22551

proc part2(input: string): int =
  var c = 0
  for i in genKeys(input, stretch):
    c += 1
    if c == 64: return i



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
