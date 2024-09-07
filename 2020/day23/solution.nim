import ../../lib/imports



type
  Cups = ref object
    head: int
    next: Table[int, int]

proc parse(input: string): Cups =
  result.new
  let a = input.toSeq.mapIt(it.ord - '0'.ord)
  for i in 0 ..< a.len:
    result.next[a[i]] = a[(i + 1) mod a.len]
  result.head = a[0]

when defined(test):
  let input = """
389125467
""".strip
  block:
    let cups = input.parse
    doAssert cups.head == 3
    doAssert cups.next == { 3: 8, 8: 9, 9: 1, 1: 2, 2: 5, 5: 4, 4: 6, 6: 7, 7: 3 }.toTable

proc step(cups: Cups) =
  let N = cups.next.len
  proc minus1(x: int): int =
    (x - 1 - 1 + N) mod N + 1

  let pickupFirst = cups.next[cups.head]
  var pickupLast = cups.head
  var pickups = newSeq[int]()
  for _ in 0 ..< 3:
    pickupLast = cups.next[pickupLast]
    pickups.add pickupLast
  cups.next[cups.head] = cups.next[pickupLast]

  var dst = cups.head.minus1
  while dst in pickups:
    dst = dst.minus1

  block:
    let t = cups.next[dst]
    cups.next[dst] = pickupFirst
    cups.next[pickupLast] = t

  cups.head = cups.next[cups.head]

proc toSeq(cups: Cups): seq[int] =
  var p = cups.head
  result.add p
  p = cups.next[p]
  while p != cups.head:
    result.add p
    p = cups.next[p]

when defined(test):
  block:
    var cups = input.parse
    for e in @[
      @[2, 8, 9, 1, 5, 4, 6, 7, 3],
      @[5, 4, 6, 7, 8, 9, 1, 3, 2],
      @[8, 9, 1, 3, 4, 6, 7, 2, 5],
      @[4, 6, 7, 9, 1, 3, 2, 5, 8],
      @[1, 3, 6, 7, 9, 2, 5, 8, 4],
      @[9, 3, 6, 7, 2, 5, 8, 4, 1],
      @[2, 5, 8, 3, 6, 7, 4, 1, 9],
      @[6, 7, 4, 1, 5, 8, 3, 9, 2],
      @[5, 7, 4, 1, 8, 3, 9, 2, 6]
    ]:
      cups.step
      doAssert cups.toSeq == e

proc `$`(cups: Cups): string =
  var p = cups.next[1]
  while p != 1:
    result &= ('0'.ord + p).char
    p = cups.next[p]

proc move(cups: Cups, repeat: int) =
  for _ in 0 ..< repeat:
    cups.step

when defined(test):
  block:
    let cups = input.parse
    cups.move(10)
    doAssert $cups == "92658374"
  block:
    let cups = input.parse
    cups.move(100)
    doAssert $cups == "67384529"

proc part1(input: string): string =
  let cups = input.parse
  cups.move(100)
  $cups



proc parse2(input: string): Cups =
  result.new
  let a = input.toSeq.mapIt(it.ord - '0'.ord)
  for i in 0 ..< a.len - 1:
    result.next[a[i]] = a[i + 1]
  var p = a.len + 1
  result.next[a[^1]] = p
  while p < 1e6.int:
    result.next[p] = p + 1
    p += 1
  result.next[p] = a[0]
  result.head = a[0]

proc part2(input: string): int =
  let cups = input.parse2
  cups.move(1e7.int)
  let p = cups.next[1]
  let q = cups.next[p]
  p * q

when defined(test):
  block:
    doAssert part2(input) == 149245887792



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
