import ../../lib/imports



proc isValid(s: string): bool =
  var hasSame = false
  for i in 1 ..< s.len:
    if s[i - 1].ord > s[i].ord: return false
    if s[i - 1] == s[i]: hasSame = true
  hasSame

when defined(test):
  block:
    doAssert isValid("111111")
    doAssert not isValid("223450")
    doAssert not isValid("123789")

proc parse(input: string): (int, int) =
  let parts = input.split("-")
  (parts[0].parseInt, parts[1].parseInt)

proc part1(input: string): int =
  let (a, b) = input.parse
  for i in a .. b:
    if ($i).isValid:
      result += 1



proc isValid2(s: string): bool =
  var hasSame = false
  var cnt = 1
  for i in 1 ..< s.len:
    if s[i - 1].ord > s[i].ord: return false
    if s[i - 1] == s[i]:
      cnt += 1
    else:
      if cnt == 2: hasSame = true
      cnt = 1
  if cnt == 2: hasSame = true
  hasSame

when defined(test):
  block:
    doAssert isValid2("112233")
    doAssert not isValid2("123444")
    doAssert isValid2("111122")

proc part2(input: string): int =
  let (a, b) = input.parse
  for i in a .. b:
    if ($i).isValid2:
      result += 1



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
