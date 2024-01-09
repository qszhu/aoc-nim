import std/[
  algorithm,
  sequtils,
  sets,
  strformat,
  strutils,
]

import checksums/md5



proc mine(prefix: string, zeros: int): int =
  while not getMD5(&"{prefix}{result}").startsWith("0".repeat(zeros)):
    result += 1

proc part1(input: string): int =
  mine(input, 5)

when defined(test):
  doAssert part1("abcdef") == 609043
  doAssert part1("pqrstuv") == 1048970

proc part2(input: string): int =
  mine(input, 6)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
