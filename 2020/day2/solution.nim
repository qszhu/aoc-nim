import ../../lib/imports



proc parseLine(line: string): (int, int, char, string) =
  if line =~ re"(\d+)-(\d+) ([a-z]): (\w+)":
    return (matches[0].parseInt, matches[1].parseInt, matches[2][0], matches[3])
  raise newException(ValueError, "parse error: " & line)

proc parse(input: string): seq[(int, int, char, string)] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
""".strip
  block:
    doAssert input.parse == @[
      (1, 3, 'a', "abcde"),
      (1, 3, 'b', "cdefg"),
      (2, 9, 'c', "ccccccccc")
    ]



proc isValid(lo, hi: int, ch: char, s: string): bool =
  s.countIt(it == ch) in lo .. hi

proc part1(input: string): int =
  input.parse.countIt(isValid(it[0], it[1], it[2], it[3]))

when defined(test):
  block:
    doAssert part1(input) == 2



proc isValid2(lo, hi: int, ch: char, s: string): bool =
  (s[lo - 1] == ch) xor (s[hi - 1] == ch)

proc part2(input: string): int =
  input.parse.countIt(isValid2(it[0], it[1], it[2], it[3]))

when defined(test):
  block:
    doAssert part2(input) == 1



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
