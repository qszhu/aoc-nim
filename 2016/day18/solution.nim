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
  Row = string


proc nextRow(self: Row): Row =
  let N = self.len
  for i in 0 ..< N:
    let left = (if i - 1 >= 0 and self[i - 1] == '^': '^' else: '.')
    let center = self[i]
    let right = (if i + 1 < N and self[i + 1] == '^': '^' else: '.')
    let p = &"{left}{center}{right}"
    result &= (if p in ["^^.", ".^^", "^..", "..^"]: '^' else: '.')

when defined(test):
  block:
    doAssert nextRow("..^^.") == ".^^^^"
    doAssert nextRow(".^^^^") == "^^..^"

  block:
    let lines = """
.^^.^.^^^^
^^^...^..^
^.^^.^.^^.
..^^...^^^
.^^^^.^^.^
^^..^.^^..
^^^^..^^^.
^..^^^^.^^
.^^^..^.^^
^^.^^^..^^
""".strip.split("\n")
    for i in 1 ..< lines.len:
      doAssert nextRow(lines[i - 1]) == lines[i]

proc part1(input: string, n: int): int =
  var s = input
  result = s.countIt(it == '.')
  for i in 1 ..< n:
    s = s.nextRow
    result += s.countIt(it == '.')

when defined(test):
  doAssert part1(".^^.^.^^^^", 10) == 38

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input, 40)
  echo part1(input, 400000)
