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



proc hasABBA(s: string, i: int): bool =
  if i + 4 > s.len: return
  s[i] == s[i + 3] and s[i + 1] == s[i + 2] and s[i] != s[i + 1]

proc supportsTLS(s: string): bool =
  var inBrackets = false
  for i in 0 ..< s.len:
    if s[i] == '[': inBrackets = true
    elif s[i] == ']': inBrackets = false
    elif hasABBA(s, i):
      if inBrackets: return false
      result = true

when defined(test):
  block:
    doAssert supportsTLS("abba[mnop]qrst")
    doAssert not supportsTLS("abcd[bddb]xyyx")
    doAssert not supportsTLS("aaaa[qwer]tyui")
    doAssert supportsTLS("ioxxoj[asdfgh]zxcvbn")

proc part1(input: string): int =
  for line in input.split("\n"):
    if supportsTLS(line):
      result += 1

proc hasABA(s: string, i: int): bool =
  if i + 3 > s.len: return
  s[i] == s[i + 2] and s[i] != s[i + 1]

proc getBAB(aba: string): string =
  &"{aba[1]}{aba[0]}{aba[1]}"

proc supportsSSL(s: string): bool =
  var abas, babs = initHashSet[string]()
  var inBrackets = false
  for i in 0 ..< s.len:
    if s[i] == '[': inBrackets = true
    elif s[i] == ']': inBrackets = false
    elif hasABA(s, i):
      let t = s[i ..< i + 3]
      if inBrackets: babs.incl t
      else: abas.incl t
  abas.anyIt(it.getBAB in babs)

when defined(test):
  block:
    doAssert supportsSSL("aba[bab]xyz")
    doAssert not supportsSSL("xyx[xyx]xyx")
    doAssert supportsSSL("aaa[kek]eke")
    doAssert supportsSSL("zazbz[bzb]cdb")

proc part2(input: string): int =
  for line in input.split("\n"):
    if supportsSSL(line):
      result += 1

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
