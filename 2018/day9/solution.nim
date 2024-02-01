import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



proc run(players, marbles: int): int =
  var scores = newSeq[int](players)
  var list = initDoublyLinkedRing[int]()
  var cur = newDoublyLinkedNode[int](0)
  list.add cur
  var player = 0
  for marble in 1 .. marbles:
    if marble mod 23 != 0:
      cur = cur.next
      let n = newDoublyLinkedNode[int](marble)
      n.next = cur.next
      n.next.prev = n
      n.prev = cur
      cur.next = n
      if cur.prev == cur: cur.prev = n
      cur = cur.next
    else:
      scores[player] += marble
      for _ in 0 ..< 7: cur = cur.prev
      scores[player] += cur.value
      let next = cur.next
      cur.prev.next = cur.next
      cur.next.prev = cur.prev
      cur = next
    player = (player + 1) mod players
  scores.max

when defined(test):
  block:
    doAssert run(9, 25) == 32
    doAssert run(10, 1618) == 8317
    doAssert run(13, 7999) == 146373
    doAssert run(17, 1104) == 2764
    doAssert run(21, 6111) == 54718
    doAssert run(30, 5807) == 37305

proc parse(input: string): (int, int) =
  if input =~ re"(\d+) players; last marble is worth (\d+) points":
    (matches[0].parseInt, matches[1].parseInt)
  else:
    raise newException(ValueError, "parse error: " & input)

when defined(test):
  block:
    doAssert parse("10 players; last marble is worth 1618 points") == (10, 1618)

proc part1(input: string): int =
  let (players, marbles) = input.parse
  run(players, marbles)



proc part2(input: string): int =
  let (players, marbles) = input.parse
  run(players, marbles * 100)



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
