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

proc mine(id: string, start = 0): (int, string) =
  var i = start
  var hash = getMD5(&"{id}{i}")
  let prefix = "0".repeat(5)
  while not hash.startsWith(prefix):
    i += 1
    hash = getMD5(&"{id}{i}")
  (i, hash)

when defined(test):
  block:
    var (idx, hash) = mine("abc")
    doAssert idx == 3231929
    doAssert hash[5] == '1'

    (idx, hash) = mine("abc", idx + 1)
    doAssert idx == 5017308
    doAssert hash[5] == '8'

    (idx, hash) = mine("abc", idx + 1)
    doAssert idx == 5278568
    doAssert hash[5] == 'f'

proc part1(input: string): string =
  var (idx, hash) = mine(input)
  result &= hash[5]
  while true:
    (idx, hash) = mine(input, idx + 1)
    result &= hash[5]
    if result.len >= 8: return

when defined(test):
  block:
    doAssert part1("abc") == "18f47a30"

proc part2(input: string): string =
  result = "_".repeat(8)
  var idx = -1
  var hash: string
  while true:
    (idx, hash) = mine(input, idx + 1)
    let p = hash[5].ord - '0'.ord
    if p in 0 .. 7 and result[p] == '_':
      result[p] = hash[6]
    if "_" notin result: return

when defined(test):
  block:
    doAssert part2("abc") == "05ace8e3"

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
