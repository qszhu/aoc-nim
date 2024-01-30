import std/[
  algorithm,
  bitops,
  deques,
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



proc reduce(s: string): string =
  var st = newSeq[char]()
  for c in s:
    if st.len > 0:
      if st[^1].toLowerAscii == c.toLowerAscii:
        if st[^1].isUpperAscii and c.isLowerAscii or st[^1].isLowerAscii and c.isUpperAscii:
          discard st.pop
          continue
    st.add c
  st.join

when defined(test):
  block:
    doAssert "dabAcCaCBAcCcaDA".reduce == "dabCBAcaDA"

proc part1(input: string): int =
  input.reduce.len

proc part2(input: string): int =
  result = int.high
  for t in 'a' .. 'z':
    let s = input.filterIt(it.toLowerAscii != t).join
    result = result.min s.reduce.len

when defined(test):
  block:
    doAssert "dabAcCaCBAcCcaDA".part2 == 4



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
