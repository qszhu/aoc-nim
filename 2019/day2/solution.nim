import ../../lib/imports



type
  Program = seq[int]

proc parse(input: string): Program =
  input.split(",").mapIt(it.parseInt)

proc run(prog: Program): Program =
  result = prog
  for i in countup(0, result.len - 1, 4):
    if result[i] == 99: return
    let (op, a, b, c) = (result[i], result[i + 1], result[i + 2], result[i + 3])
    if op == 1:
      result[c] = result[a] + result[b]
    elif op == 2:
      result[c] = result[a] * result[b]

when defined(test):
  let input = """
1,9,10,3,2,3,11,0,99,30,40,50
""".strip
  block:
    doAssert input.parse.run == @[3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50]
    doAssert "1,0,0,0,99".parse.run == @[2,0,0,0,99]
    doAssert "2,3,0,3,99".parse.run == @[2,3,0,6,99]
    doAssert "2,4,4,5,99,0".parse.run == @[2,4,4,5,99,9801]
    doAssert "1,1,1,4,99,5,6,0,99".parse.run == @[30,1,1,4,2,5,6,0,99]

proc part1(input: string): int =
  var prog = input.parse
  prog[1] = 12
  prog[2] = 2
  prog.run[0]



proc part2(input: string): int =
  for noun in 0 .. 99:
    for verb in 0 .. 99:
      var prog = input.parse
      prog[1] = noun
      prog[2] = verb
      if prog.run[0] == 19690720:
        return noun * 100 + verb



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
