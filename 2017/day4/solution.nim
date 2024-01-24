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



proc isValid(s: string): bool =
  let a = s.split(" ")
  a.toHashSet.len == a.len

when defined(test):
  block:
    doAssert "aa bb cc dd ee".isValid
    doAssert not "aa bb cc dd aa".isValid
    doAssert "aa bb cc dd aaa".isValid

proc part1(input: string): int =
  input.split("\n").countIt(it.isValid)



proc isValid2(s: string): bool =
  let a = s.split(" ").mapIt(it.sorted.join)
  a.toHashSet.len == a.len

when defined(test):
  block:
    doAssert "abcde fghij".isValid2
    doAssert not "abcde xyz ecdab".isValid2
    doAssert "a ab abc abd abf abj".isValid2
    doAssert "iiii oiii ooii oooi oooo".isValid2
    doAssert not "oiii ioii iioi iiio".isValid2

proc part2(input: string): int =
  input.split("\n").countIt(it.isValid2)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
