import ../../lib/imports



type
  RuleKind {.pure.} = enum
    Char
    Seqs

  Rule = object
    id: int
    case kind: RuleKind
    of RuleKind.Char:
      ch: char
    of RuleKind.Seqs:
      seqs: seq[seq[int]]

proc parseLine(line: string): Rule =
  var parts = line.split(": ")
  let id = parts[0].parseInt
  if parts.len == 2 and parts[1].startsWith("\""):
    let ch = parts[1][1]
    return Rule(kind: RuleKind.Char, id: id, ch: ch)
  var seqs = newSeq[seq[int]]()
  for p in parts[1].split(" | "):
    seqs.add p.split(" ").mapIt(it.parseInt)
  Rule(kind: RuleKind.Seqs, id: id, seqs: seqs)

proc parse(input: string): (Table[int, Rule], seq[string]) =
  let parts = input.split("\n\n")
  let rules = parts[0].split("\n").mapIt(it.parseLine)
  let msgs = parts[1].split("\n")
  var rulesMap = initTable[int, Rule]()
  for rule in rules: rulesMap[rule.id] = rule
  (rulesMap, msgs)

when defined(test):
  let input = """
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
""".strip
  block:
    let (rules, msgs) = input.parse
    doAssert rules[0].seqs == @[@[4, 1, 5]]
    doAssert rules[1].seqs == @[@[2, 3], @[3, 2]]
    doAssert rules[2].seqs == @[@[4, 4], @[5, 5]]
    doAssert rules[3].seqs == @[@[4, 5], @[5, 4]]
    doAssert rules[4].ch == 'a'
    doAssert rules[5].ch == 'b'
    doAssert msgs.len == 5

#[
0
4    1    5
a  3   2  b
  5 4 5 5
  b a b b
]#
proc matches(s: string, rulesMap: sink Table[int, Rule], start: int): bool =
  proc matches(r, i: int): (bool, int) =
    if i >= s.len: return (false, i)
    let rule = rulesMap[r]
    if rule.kind == RuleKind.Char:
      if rule.ch == s[i]: return (true, i + 1)
      return (false, i)
    else: # RuleKind.Seqs
      for altRules in rule.seqs:
        var allMatched = true
        var j = i
        var matched: bool
        for r in altRules:
          (matched, j) = matches(r, j)
          if not matched:
            allMatched = false
            break
        if allMatched:
          return (true, j)
      return (false, i)

  let (matched, i) = matches(start, 0)
  matched and i == s.len

when defined(test):
  block:
    let (rules, msgs) = input.parse
    for i, e in [true, false, true, false, false]:
      doAssert msgs[i].matches(rules, 0) == e

proc part1(input: string): int =
  let (rules, msgs) = input.parse
  msgs.countIt(it.matches(rules, 0))

when defined(test):
  block:
    doAssert part1(input) == 2



when defined(test):
  let input2 = """
42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
""".strip
  block:
    doAssert part1(input2) == 3

proc canMatch(msg: string, rules: sink Table[int, Rule], thres: int): bool =
  for i in 1 .. thres:
    for j in 1 .. thres:
      block:
        var res = newSeq[seq[int]]()
        var r = newSeq[int]()
        for _ in 0 ..< i: r.add 42
        res.add r
        rules[8] = Rule(id: 8, kind: RuleKind.Seqs, seqs: res)
      block:
        var res = newSeq[seq[int]]()
        var r = newSeq[int]()
        for _ in 0 ..< j: r.add 42
        for _ in 0 ..< j: r.add 31
        res.add r
        rules[11] = Rule(id: 11, kind: RuleKind.Seqs, seqs: res)
      if msg.matches(rules, 0): return true

proc part2(input: string): int =
  let (rules, msgs) = input.parse
  const thres = 10
  for msg in msgs:
    if canMatch(msg, rules, thres):
      result += 1

when defined(test):
  block:
    doAssert part2(input2) == 12



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
