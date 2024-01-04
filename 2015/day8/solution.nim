import std/[
  algorithm,
  bitops,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]



proc part1(input: string): int =
  for line in input.split("\n"):
    result += line.len - line.unescape.len

proc part2(input: string): int =
  for line in input.split("\n"):
    result += line.escape.len - line.len

when isMainModule:
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
