import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  options,
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]

import ../day19/solution



proc part1(input: string): int =
  let c = input.parse
  # disassemble(c)
  while true:
    discard c.step
    if c.ip == 28: return c.regs[5]

proc part2(input: string): int =
  let c = input.parse
  var seen = initIntSet()
  var seenList = newSeq[int]()
  while c.step:
    if c.ip == 28:
      let t = c.regs[5]
      if t in seen: break
      seen.incl t
      seenList.add t
  seenList[^1]



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
