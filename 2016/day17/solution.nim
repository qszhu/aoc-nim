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


type
  State = object
    r, c: int
    passcode, path: string

const dPos = [(-1, 0), (1, 0), (0, -1), (0, 1)]

iterator next(s: State): State =
  let h = (&"{s.passcode}{s.path}").getMD5
  for i, (dr, dc) in dPos:
    if h[i] notin 'b' .. 'f': continue
    let (nr, nc) = (s.r + dr, s.c + dc)
    if nr notin 0 .. 3 or nc notin 0 .. 3: continue
    var t = s
    t.r = nr
    t.c = nc
    t.path &= "UDLR"[i]
    yield t

proc bfs(s: State): State =
  var q = @[s]
  while q.len > 0:
    var next: typeof q = @[]
    for s in q:
      if (s.r, s.c) == (3, 3): return s
      for ns in s.next:
        next.add ns
    q = next

when defined(test):
  block:
    doAssert bfs(State(passcode: "ihgpwlah")).path == "DDRRRD"
    doAssert bfs(State(passcode: "kglvqrro")).path == "DDUDRLRRUDRD"
    doAssert bfs(State(passcode: "ulqzkmiv")).path == "DRURDRUDDLLDLUURRDULRLDUUDDDRR"

proc part1(input: string): string =
  let s = State(passcode: input)
  bfs(s).path

proc bfs2(s: State): int =
  var q = @[s]
  while q.len > 0:
    var next: typeof q = @[]
    for s in q:
      if (s.r, s.c) == (3, 3):
        result = result.max s.path.len
        continue
      for ns in s.next:
        next.add ns
    q = next

when defined(test):
  block:
    doAssert bfs2(State(passcode: "ihgpwlah")) == 370
    doAssert bfs2(State(passcode: "kglvqrro")) == 492
    doAssert bfs2(State(passcode: "ulqzkmiv")) == 830

proc part2(input: string): int =
  let s = State(passcode: input)
  bfs2(s)

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
