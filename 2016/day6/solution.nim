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



proc correct(msgs: seq[string]): string =
  for c in 0 ..< msgs[0].len:
    var cnts = initCountTable[char]()
    for r in 0 ..< msgs.len:
      cnts.inc msgs[r][c]
    let maxFreq = cnts.values.toSeq.max
    for k, v in cnts:
      if v == maxFreq:
        result &= k
        break

proc part1(input: string): string =
  correct(input.split("\n"))

when defined(test):
  let input = """
eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar
""".strip
  doAssert part1(input) == "easter"

proc correct2(msgs: seq[string]): string =
  for c in 0 ..< msgs[0].len:
    var cnts = initCountTable[char]()
    for r in 0 ..< msgs.len:
      cnts.inc msgs[r][c]
    let minFreq = cnts.values.toSeq.min
    for k, v in cnts:
      if v == minFreq:
        result &= k
        break

proc part2(input: string): string =
  correct2(input.split("\n"))

when defined(test):
  doAssert part2(input) == "advent"

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
