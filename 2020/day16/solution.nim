import ../../lib/imports



type
  Field = object
    name: string
    range1: (int, int)
    range2: (int, int)

proc parseFields(s: string): seq[Field] =
  proc parseField(line: string): Field =
    if line =~ re"([^:]+): (\d+)-(\d+) or (\d+)-(\d+)":
      Field(name: matches[0],
        range1: (matches[1].parseInt, matches[2].parseInt),
        range2: (matches[3].parseInt, matches[4].parseInt))
    else:
      raise newException(ValueError, "parse error: " & line)
  s.split("\n").mapIt(it.parseField)

proc parseTicket(line: string): seq[int] =
  line.split(",").mapIt(it.parseInt)

proc parse(input: string): (seq[Field], seq[int], seq[seq[int]]) =
  let parts = input.split("\n\n")
  (
    parts[0].parseFields,
    parts[1].split("\n")[1].parseTicket,
    parts[2].split("\n")[1 .. ^1].mapIt(it.parseTicket)
  )

when defined(test):
  let input = """
class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
""".strip
  block:
    let (fields, yours, nearbys) = input.parse
    doAssert fields == @[
      Field(name: "class", range1: (1, 3), range2: (5, 7)),
      Field(name: "row", range1: (6, 11), range2: (33, 44)),
      Field(name: "seat", range1: (13, 40), range2: (45, 50))
    ]
    doAssert yours == @[7, 1, 14]
    doAssert nearbys == @[
      @[7, 3, 47],
      @[40, 4, 50],
      @[55, 2, 20],
      @[38, 6, 12]
    ]

proc isValid(x: int, fields: sink seq[Field]): bool =
  for field in fields.mitems:
    var (a, b) = field.range1
    if x in a .. b: return true
    (a, b) = field.range2
    if x in a .. b: return true

proc part1(input: string): int =
  let (fields, _, nearbys) = input.parse
  for ticket in nearbys:
    result += ticket.filterIt(not it.isValid(fields)).sum

when defined(test):
  block:
    doAssert part1(input) == 71



proc isValid(ticket: sink seq[int], fields: sink seq[Field]): bool =
  ticket.allIt(it.isValid(fields))

proc validFields(x: int, fields: sink seq[Field]): seq[string] =
  for field in fields.mitems:
    var (a, b) = field.range1
    if x in a .. b:
      result.add field.name
      continue
    (a, b) = field.range2
    if x in a .. b:
      result.add field.name

proc getFields(input: string): seq[string] =
  var (fields, yours, nearbys) = input.parse
  nearbys = nearbys.filterIt(it.isValid(fields))
  var cands = newSeq[(int, Hashset[string])]()
  for i in 0 ..< yours.len:
    var cand = nearbys[0][i].validFields(fields).toHashSet
    for j in 1 ..< nearbys.len:
      cand = cand * nearbys[j][i].validFields(fields).toHashSet
    cands.add (i, cand)
  cands = cands.sortedByIt(it[1].len)
  for i in countdown(cands.len - 1, 1):
    cands[i][1] = cands[i][1] - cands[i - 1][1]
  result = newSeq[string](yours.len)
  for (i, cand) in cands:
    result[i] = cand.toSeq[0]

when defined(test):
  let input2 = """
class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9
""".strip
  block:
    doAssert input2.getFields == @["row", "class", "seat"]

proc part2(input: string): int =
  let fields = input.getFields
  var (_, yours, _) = input.parse
  result = 1
  for field in fields.filterIt(it.startsWith("departure")):
    result *= yours[fields.find(field)]



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
