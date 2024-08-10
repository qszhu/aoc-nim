import ../../lib/imports
import ../day9/programs



proc run(input, insts: string, debug = false): int =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  for ch in insts:
    queues[0].addLast ch.ord
  while p.stepOver != StatusFinished: discard
  p.runToEnd
  var output = ""
  while queues[1].len > 0:
    let r = queues[1].popFirst
    if r > 0xff: return r
    output &= r.char
  if debug: echo output

# bit 0: NOT
# bit 1: AND/OR
iterator operations(vars: int): seq[int] =
  var m = 1
  for _ in 0 ..< vars: m *= 4
  for s in 0 ..< m:
    var res = newSeq[int]()
    var x = s
    for _ in 0 ..< vars:
      res.add x mod 4
      x = x div 4
    yield res

iterator perms(chars: string): string =
  var a = chars.mapIt(it).sorted
  yield a.join
  while a.nextPermutation:
    yield a.join

proc total(vars: int): int =
  result = 1
  for i in 1 .. vars: result *= i
  for i in 0 ..< vars:
    result *= 4

iterator genInsts(chars: string): seq[string] =
  for op in operations(chars.len):
      for chars in perms(chars):
        var res = newSeq[string]()
        var first = true
        for i in 0 ..< chars.len:
          let ch = chars[i]
          if first:
            first = false
            if not op[i].testBit(1): res.add &"NOT {ch} J"
            else: res.add &"OR {ch} J"
          else:
            if not op[i].testBit(0):
              res.add &"NOT {ch} T"
              if not op[i].testBit(1): res.add "AND T J"
              else: res.add "OR T J"
            else:
              if not op[i].testBit(1): res.add &"AND {ch} J"
              else: res.add &"OR {ch} J"
        yield res

proc part1(input: string): int =
  for insts in genInsts("ABCD"):
    let insts = insts & "WALK\n"
    result = run(input, insts.join("\n"))
    if result != 0:
      echo insts.join("\n")
      return



proc part2(input: string): int =
  let s = total(5)
  var t = 0
  for insts in genInsts("ABCDH"):
    t += 1
    stderr.write &"\r{t}/{s}     "
    let insts = insts & "RUN\n"
    result = run(input, insts.join("\n"))
    if result != 0:
      echo ""
      echo insts.join("\n")
      return



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
