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



proc take(w: seq[int], target: int): seq[seq[int]] =
  var res = newSeq[seq[int]]()
  var minLen = int.high
  proc search(i, target: int, partial: seq[int]) =
    if target == 0:
      if minLen > partial.len:
        minLen = partial.len
        res = @[partial]
      elif minLen == partial.len:
        res.add partial
      return
    if i >= w.len or target < 0 or partial.len > minLen: return
    search(i + 1, target - w[i], partial & w[i])
    search(i + 1, target, partial)
  search(0, target, @[])
  res

when defined(test):
  block:
    let w = (1 .. 5).toSeq & (7 .. 11).toSeq
    doAssert take(w, w.sum div 3) == @[@[9,11]]

proc calc(w: seq[int]): int =
  take(w, w.sum div 3).mapIt(it.foldl a * b).min

when defined(test):
  block:
    let w = (1 .. 5).toSeq & (7 .. 11).toSeq
    doAssert calc(w) == 99

proc part1(input: string): int =
  let w = input.split("\n").mapIt(it.parseInt)
  calc(w)

proc calc2(w: seq[int]): int =
  take(w, w.sum div 4).mapIt(it.foldl a * b).min

when defined(test):
  block:
    let w = (1 .. 5).toSeq & (7 .. 11).toSeq
    doAssert calc2(w) == 44

proc part2(input: string): int =
  let w = input.split("\n").mapIt(it.parseInt)
  calc2(w)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
