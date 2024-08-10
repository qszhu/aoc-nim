import ../../lib/imports
import programs



when defined(test):
  block:
    let input = """
109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99
""".strip
    initQueues(2)
    let p = newProgram(input, 0, 1)
    while p.step != StatusFinished: discard
    doAssert queues[1].toSeq == input.split(",").mapIt(it.parseBiggestInt)
  block:
    let input = """
1102,34915192,34915192,7,4,7,99,0
""".strip
    initQueues(2)
    let p = newProgram(input, 0, 1)
    while p.step != StatusFinished: discard
    doAssert ($(queues[1].popFirst)).len == 16
  block:
    let input = """
104,1125899906842624,99
""".strip
    initQueues(2)
    let p = newProgram(input, 0, 1)
    while p.step != StatusFinished: discard
    doAssert queues[1].popFirst == input.split(",")[1].parseBiggestInt

proc run(input: string, i: int) =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  queues[0].addLast i
  while p.step != StatusFinished: discard
  while queues[1].len > 0:
    echo queues[1].popFirst

proc part1(input: string) =
  run(input, 1)



proc part2(input: string) =
  run(input, 2)



when isMainModule and not defined(test):
  let input = readFile("input").strip
  part1(input)
  part2(input)
