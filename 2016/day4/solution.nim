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

type
  Room = object
    name: string
    id: int
    checksum: string

proc calcChecksum(self: Room): string =
  var cnts = initCountTable[char]()
  for c in self.name:
    if c.isLowerAscii:
      cnts.inc c
  var letters = cnts.keys.toSeq
  letters.sort (a, b) => (
    if cnts[a] == cnts[b]: a.cmp(b)
    else: cnts[b].cmp(cnts[a])
  )
  letters[0 ..< 5].join

proc isReal(self: Room): bool =
  self.calcChecksum == self.checksum

proc parseRoom(line: string): Room =
  if line =~ re"([-a-z]+)(\d+)\[([a-z]+)\]":
    Room(name: matches[0], id: matches[1].parseInt, checksum: matches[2])
  else:
    raise newException(ValueError, "parse error: " & line)

when defined(test):
  block:
    doAssert parseRoom("aaaaa-bbb-z-y-x-123[abxyz]").isReal
    doAssert parseRoom("a-b-c-d-e-f-g-h-987[abcde]").isReal
    doAssert parseRoom("not-a-real-room-404[oarel]").isReal
    doAssert not parseRoom("totally-real-room-200[decoy]").isReal

proc part1(input: string): int =
  for line in input.split("\n"):
    let room = parseRoom(line)
    if room.isReal: result += room.id

when defined(test):
  block:
    doAssert part1("""
aaaaa-bbb-z-y-x-123[abxyz]
a-b-c-d-e-f-g-h-987[abcde]
not-a-real-room-404[oarel]
totally-real-room-200[decoy]
""".strip) == 1514

proc decrypt(name: string, id: int): string =
  var name = name
  for i, c in name.mpairs:
    if c == '-': c = ' '
    else:
      let d = (c.ord - 'a'.ord + id) mod 26
      c = ('a'.ord + d).char
  name

when defined(test):
  block:
    doAssert decrypt("qzmt-zixmtkozy-ivhz", 343) == "very encrypted name"

proc decrypt(self: Room): string =
  decrypt(self.name, self.id)

proc part2(input: string): int =
  for line in input.split("\n"):
    let room = line.parseRoom
    if room.decrypt.startsWith("north"):
      return room.id

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
