import std/[
  algorithm,
  bitops,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]



proc step(s: string): string =
  result = s
  var c = 1
  for i in countdown(result.len - 1, 0):
    if c == 0: break
    result[i] = (result[i].ord + c).char
    if result[i].ord > 'z'.ord:
      result[i] = 'a'
    else:
      c = 0

when defined(test):
  doAssert step("xx") == "xy"
  doAssert step("xy") == "xz"
  doAssert step("xz") == "ya"
  doAssert step("ya") == "yb"

proc isValid1(s: string): bool =
  for i in 0 .. s.len - 3:
    var valid = true
    for j in i + 1 ..< i + 3:
      if s[j - 1].ord + 1 != s[j].ord:
        valid = false
        break
    if valid: return true

when defined(test):
  doAssert isValid1("hijklmmn")
  doAssert not isValid1("abbceffg")

proc isValid2(s: string): bool =
  re"[iol]" notin s

when defined(test):
  doAssert not isValid2("hijklmmn")

proc isValid3(s: string): bool =
  s.findAll(re"(.)\1").toHashSet.len > 1

when defined(test):
  doAssert isValid3("abbceffg")
  doAssert not isValid3("abbcegjk")

proc isValid(s: string): bool =
  isValid1(s) and isValid2(s) and isValid3(s)

when defined(test):
  doAssert not isValid("hijklmmn")
  doAssert not isValid("abbceffg")
  doAssert not isValid("abbcegjk")

proc next(s: string): string =
  result = s.step
  while not result.isValid:
    result = result.step

when defined(test):
  doAssert next("abcdefgh") == "abcdffaa"
  doAssert next("ghijklmn") == "ghjaabcc"

proc part1(s: string): string =
  s.next

proc part2(s: string): string =
  s.next.next

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
