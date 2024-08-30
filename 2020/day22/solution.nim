import ../../lib/imports



proc parsePlayer(s: string): seq[int] =
  s.split("\n")[1 .. ^1].mapIt(it.parseInt)

proc parse(input: string): (seq[int], seq[int]) =
  let parts = input.split("\n\n")
  (parts[0].parsePlayer, parts[1].parsePlayer)

when defined(test):
  let input = """
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
""".strip
  block:
    doAssert input.parse == (@[9, 2, 6, 3, 1], @[5, 8, 4, 7, 10])

proc score(a: seq[int]): int  =
  let N = a.len
  for i in 0 ..< N:
    result += a[i] * (N - i)

proc part1(input: string): int =
  let players = input.parse
  var p1 = players[0].toDeque
  var p2 = players[1].toDeque
  while p1.len > 0 and p2.len > 0:
    if p1[0] > p2[0]:
      p1.addLast p1.popFirst
      p1.addLast p2.popFirst
    else:
      p2.addLast p2.popFirst
      p2.addLast p1.popFirst
  let winner = if p1.len > 0: p1 else: p2
  winner.toSeq.score

when defined(test):
  block:
    doAssert part1(input) == 306



proc winner(p1, p2: seq[int]): (int, seq[int]) =
  var seen1 = initHashSet[string]()
  var seen2 = initHashSet[string]()
  var d1 = p1.toDeque
  var d2 = p2.toDeque
  while d1.len > 0 and d2.len > 0:
    let s1 = d1.toSeq.join(",")
    if s1 in seen1: return (0, d1.toSeq)
    let s2 = d2.toSeq.join(",")
    if s2 in seen2: return (0, d1.toSeq)
    seen1.incl s1
    seen2.incl s2

    let (a, b) = (d1[0], d2[0])
    let w =
      if d1.len > a and d2.len > b:
        winner(d1.toSeq[1 .. a], d2.toSeq[1 .. b])[0]
      else:
        if a > b: 0 else: 1
    if w == 0:
      d1.addLast d1.popFirst
      d1.addLast d2.popFirst
    else:
      d2.addLast d2.popFirst
      d2.addLast d1.popFirst
  if d1.len > 0: (0, d1.toSeq)
  else: (1, d2.toSeq)

proc part2(input: string): int =
  let (p1, p2) = input.parse
  let (_, d) = winner(p1, p2)
  d.score

when defined(test):
  block:
    doAssert part2(input) == 291



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
