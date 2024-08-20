import ../../lib/imports



proc countDiff(a: seq[int]): CountTable[int] =
  let a = @[0] & a.sorted
  result.inc 3
  for i in 1 ..< a.len:
    result.inc a[i] - a[i - 1]

proc parse(input: string): seq[int] =
  input.split("\n").mapIt(it.parseInt)

when defined(test):
  let input = """
16
10
15
5
1
11
7
19
6
12
4
""".strip
  block:
    let cnts = input.parse.countDiff
    doAssert cnts[1] == 7
    doAssert cnts[3] == 5

  let input1 = """
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
""".strip
  block:
    let cnts = input1.parse.countDiff
    doAssert cnts[1] == 22
    doAssert cnts[3] == 10

proc part1(input: string): int =
  let cnts = input.parse.countDiff
  cnts[1] * cnts[3]



proc part2(input: string): int =
  var a = input.parse.sorted
  a = @[0] & a & @[a.max + 3]
  let N = a.len
  var dp = newSeq[int](N)
  dp[0] = 1
  for i in 0 ..< N:
    for j in i + 1 ..< N:
      if a[j] > a[i] + 3: break
      dp[j] += dp[i]
  dp[^1]

when defined(test):
  block:
    doAssert part2(input) == 8
    doAssert part2(input1) == 19208



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
