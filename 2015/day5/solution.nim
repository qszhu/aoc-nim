import std/[
  algorithm,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
]



proc isNice(s: string): bool =
  if not s.contains(re"([aeiou].*){3}"): return
  if not s.contains(re"(.)\1"): return
  if s.contains(re"(ab|cd|pq|xy)"): return
  true

when defined(test):
  doAssert isNice("ugknbfddgicrmopn")
  doAssert isNice("aaa")
  doAssert not isNice("jchzalrnumimnmhp")
  doAssert not isNice("haegwjzuvuyypxyu")
  doAssert not isNice("dvszwmarrgswjxmb")

proc part1(input: string): int =
  input.split("\n").countIt(it.isNice)

proc isNice2(s: string): bool =
  if not s.contains(re"(..).*\1"): return
  if not s.contains(re"(.).\1"): return
  true

when defined(test):
  doAssert isNice2("qjhvhtzxzqqjkmpb")
  doAssert isNice2("xxyxx")
  doAssert not isNice2("uurcxstgmygtbstg")
  doAssert not isNice2("ieodomkazucvgmuy")

proc part2(input: string): int =
  input.split("\n").countIt(it.isNice2)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
