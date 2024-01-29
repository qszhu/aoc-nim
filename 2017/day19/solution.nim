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
  Diagram = seq[string]

proc findStart(diag: Diagram): (int, int) =
  (0, diag[0].find('|'))

proc parse(input: string): Diagram =
  input.split("\n")

when defined(test):
  let input = """
     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ 
"""
  block:
    doAssert findStart(input.parse) == (0, 5)

const dPos = [(-1, 0), (0, 1), (1, 0), (0, -1)]

proc walk(diag: seq[string]): (string, int) =
  let (rows, cols) = (diag.len, diag[0].len)
  var path = ""
  var steps = 1
  var (r, c) = diag.findStart
  var dir = 2
  while true:
    let (dr, dc) = dPos[dir]
    (r, c) = (r + dr, c + dc)
    if r notin 0 ..< rows or c notin 0 ..< cols or diag[r][c] == ' ': break
    steps += 1
    if diag[r][c] == '+':
      for i, (dr, dc) in dPos:
        let (nr, nc) = (r + dr, c + dc)
        if nr notin 0 ..< rows or nc notin 0 ..< cols: continue
        if diag[nr][nc] != ' ' and ((i + 1) mod 4 == dir or (i + 3) mod 4 == dir):
          dir = i
          break
    elif diag[r][c].isAlphaAscii:
      path &= diag[r][c]
  (path, steps)

when defined(test):
  block:
    doAssert walk(input.parse) == ("ABCDEF", 38)

proc part1(input: string): string =
  walk(input.parse)[0]

proc part2(input: string): int =
  walk(input.parse)[1]



when isMainModule and not defined(test):
  let input = readAll(stdin)
  echo part1(input)
  echo part2(input)
