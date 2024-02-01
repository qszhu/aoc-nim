import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
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



proc metaSum(a: seq[int]): int =
  proc dfs(i: var int): int =
    let numChild = a[i]
    let numMeta = a[i + 1]
    i += 2
    for _ in 0 ..< numChild:
      result += dfs(i)
    for j in 0 ..< numMeta:
      result += a[i + j]
    i += numMeta
  var i = 0
  dfs(i)

when defined(test):
  block:
    doAssert metaSum(@[2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]) == 138

proc parse(input: string): seq[int] =
  input.split(" ").mapIt(it.parseInt)

proc part1(input: string): int =
  metaSum(input.parse)



proc metaSum2(a: seq[int]): int =
  proc dfs(i: var int): int =
    let numChild = a[i]
    let numMeta = a[i + 1]
    i += 2
    var children = newSeq[int]()
    for _ in 0 ..< numChild:
      children.add dfs(i)
    if numChild == 0:
      for j in 0 ..< numMeta:
        result += a[i + j]
    else:
      for j in 0 ..< numMeta:
        let c = a[i + j] - 1
        if c in 0 ..< children.len:
          result += children[c]
    i += numMeta
  var i = 0
  dfs(i)

when defined(test):
  block:
    doAssert metaSum2(@[2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]) == 66

proc part2(input: string): int =
  metaSum2(input.parse)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
