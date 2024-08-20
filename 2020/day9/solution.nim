import ../../lib/imports



proc findFirst(a: seq[int], pre: int): int =
  var q = a[0 ..< pre].toDeque
  proc check(x: int): bool =
    for j in 0 ..< pre:
      for k in j + 1 ..< pre:
        if q[j] + q[k] == x: return true
  for i in pre ..< a.len:
    if not check(a[i]): return a[i]
    discard q.popFirst
    q.addLast a[i]

proc parse(input: string): seq[int] =
  input.split("\n").mapIt(it.parseInt)

when defined(test):
  let input = """
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
""".strip
  block:
    doAssert input.parse.findFirst(5) == 127

proc part1(input: string): int =
  input.parse.findFirst(25)



proc findRange(a: seq[int], pre, target: int): (int, int) =
  let N = a.len
  var preSum = newSeq[int](N + 1)
  for i in 1 .. N: preSum[i] = preSum[i - 1] + a[i - 1]
  for i in 0 .. N:
    let j = bisectRangeFirst(i + 1, N + 1, j => preSum[j] - preSum[i] >= target)
    if j <= N and preSum[j] - preSum[i] == target: return (i, j)

proc findWeakness(a: seq[int], pre: int): int =
  let target = a.findFirst(pre)
  let (i, j) = a.findRange(pre, target)
  let a = a[i ..< j]
  a.min + a.max

when defined(test):
  block:
    doAssert input.parse.findWeakness(5) == 62

proc part2(input: string): int =
  input.parse.findWeakness(25)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
