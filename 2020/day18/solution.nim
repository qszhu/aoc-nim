import ../../lib/imports



iterator tokens(s: string): char =
  for ch in s:
    if ch != ' ': yield ch

proc eval(s: string, prec = ""): int =
  var nums = newSeq[int]()
  var ops = newSeq[char]()
  proc resolve(): int =
    let b = nums.pop
    let a = nums.pop
    let op = ops.pop
    case op
    of '+': a + b
    of '*': a * b
    else: raise newException(ValueError, "unknown op: " & op)

  for t in s.tokens:
    if t.isDigit:
      nums.add t.ord - '0'.ord
    elif t == '(':
      ops.add t
    elif t == ')':
      while ops[^1] != '(':
        nums.add resolve()
      discard ops.pop
    else:
      while ops.len > 0 and ops[^1] != '(' and (prec.len == 0 or prec.find(ops[^1]) >= prec.find(t)):
        nums.add resolve()
      ops.add t
  while ops.len > 0:
    nums.add resolve()
  nums[0]

when defined(test):
  block:
    doAssert eval("1 + 2 * 3 + 4 * 5 + 6") == 71
    doAssert eval("1 + (2 * 3) + (4 * (5 + 6))") == 51
    doAssert eval("2 * 3 + (4 * 5)") == 26
    doAssert eval("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437
    doAssert eval("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240
    doAssert eval("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632

proc part1(input: string): int =
  for line in input.split("\n"):
    result += eval(line)



proc eval2(s: string): int =
  eval(s, "*+")

when defined(test):
  block:
    doAssert eval2("1 + 2 * 3 + 4 * 5 + 6") == 231
    doAssert eval2("1 + (2 * 3) + (4 * (5 + 6))") == 51
    doAssert eval2("2 * 3 + (4 * 5)") == 46
    doAssert eval2("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 1445
    doAssert eval2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 669060
    doAssert eval2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340

proc part2(input: string): int =
  for line in input.split("\n"):
    result += eval2(line)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
