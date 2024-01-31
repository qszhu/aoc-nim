import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
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



proc parseLine(line: string): (string, string) =
  if line =~ re"Step (\w+) must be finished before step (\w+) can begin.":
    (matches[0], matches[1])
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): Table[string, seq[string]] =
  let lines = input.split("\n")
  var names = initHashSet[string]()
  for line in lines:
    let (a, b) = line.parseLine
    names.incl a
    names.incl b

  for name in names:
    result[name] = newSeq[string]()

  for line in lines:
    let (a, b) = line.parseLine
    result[a].add b

when defined(test):
  let input = """
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
""".strip
  block:
    doAssert input.parse == {
      "A": @["B", "D"],
      "B": @["E"],
      "C": @["A", "F"],
      "D": @["E"],
      "E": @[],
      "F": @["E"]
    }.toTable

proc part1(input: string): string =
  let next = input.parse
  var prev = initTable[string, HashSet[string]]()
  for u in next.keys: prev[u] = initHashSet[string]()
  for u, vs in next:
    for v in vs:
      prev[v].incl u
  var cands = initHeapQueue[string]()
  for k, v in prev:
    if v.len == 0:
      cands.push k
  while cands.len > 0:
    let c = cands.pop
    result &= c
    for v in next[c]:
      prev[v].excl c
      if prev[v].len == 0:
        cands.push v

when defined(test):
  block:
    doAssert part1(input) == "CABDFE"



proc part2(input: string, numWorkers, cap: int): int =
  let next = input.parse

  var prev = initTable[string, HashSet[string]]()
  for u in next.keys: prev[u] = initHashSet[string]()
  for u, vs in next:
    for v in vs:
      prev[v].incl u

  var cands = initHeapQueue[string]()
  for k, v in prev:
    if v.len == 0:
      cands.push k

  proc workTime(s: string): int =
    s[0].ord - 'A'.ord + 1 + cap

  var workers = initHeapQueue[(int, string)]()

  var t = 0
  while cands.len > 0 or workers.len > 0:
    if cands.len == 0 or workers.len == numWorkers:
      let (nextAvail, completed) = workers.pop
      t = t.max nextAvail
      for v in next[completed]:
        prev[v].excl completed
        if prev[v].len == 0:
          cands.push v
    if cands.len > 0:
      let task = cands.pop
      workers.push (t + task.workTime, task)

  t

when defined(test):
  block:
    doAssert part2(input, 2, 0) == 15



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input, 5, 60)
