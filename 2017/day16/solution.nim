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



proc dance(s, cmd: string): string =
  case cmd[0]:
  of 's':
    let x = cmd[1 .. ^1].parseInt
    result = s[^x .. ^1] & s[0 ..< ^x]
  of 'x':
    let p = cmd[1 .. ^1].split("/")
    let a = p[0].parseInt
    let b = p[1].parseInt
    result = s
    swap(result[a], result[b])
  of 'p':
    let (a, b) = (cmd[1], cmd[3])
    let i = s.find(a)
    let j = s.find(b)
    result = s
    swap(result[i], result[j])
  else:
    raise newException(ValueError, "unknown dance: " & cmd)

when defined(test):
  block:
    var s = "abcde".dance("s1")
    doAssert s == "eabcd"
    s = s.dance("x3/4")
    doAssert s == "eabdc"
    s = s.dance("pe/b")
    doAssert s == "baedc"

proc parse(input: string): seq[string] =
  input.split(",")

proc part1(input: string): string =
  var s = ('a' .. 'p').toSeq.join
  for cmd in input.parse:
    s = s.dance(cmd)
  s

proc part2(input: string): string =
  let cmds = input.parse
  var s = ('a' .. 'p').toSeq.join
  var seen = initTable[string, int]()
  var seenList = newSeq[string]()
  while s notin seen:
    seen[s] = seen.len
    seenList.add s
    for cmd in cmds:
      s = s.dance(cmd)
  let start = seen[s]
  let cycle = seen.len - start
  let N = 1e9.int
  seenList[start + (N - start) mod cycle]



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
