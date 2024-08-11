import ../../lib/imports
import ../day9/programs



proc networkStep(): Value =
  for i in 0 ..< 50:
    let oc = 50 + i
    if queues[oc].len < 3: continue
    let a = queues[oc].popFirst
    let x = queues[oc].popFirst
    let y = queues[oc].popFirst
    if a == 255: return y
    queues[a].addLast x
    queues[a].addLast y
  for i in 0 ..< 50:
    if queues[i].len == 0: queues[i].addLast -1

proc part1(input: string): int =
  initQueues(100)
  for i in 0 ..< 50:
    queues[i].addLast i

  var programs = newSeq[Program]()
  for i in 0 ..< 50:
    programs.add newProgram(input, i, 50 + i)

  while true:
    for p in programs: discard p.step
    result = networkStep()
    if result != 0: break



proc networkStep2(): int =
  var cp: (Value, Value) = (Value.low, Value.low)
  for i in 0 ..< 50:
    let oc = 50 + i
    if queues[oc].len < 3: continue
    let a = queues[oc].popFirst
    let x = queues[oc].popFirst
    let y = queues[oc].popFirst
    if a == 255:
      cp = (x, y)
    else:
      queues[a].addLast x
      queues[a].addLast y
  for i in 0 ..< 50:
    if queues[i].len == 0: queues[i].addLast -1

  let idle = (0 ..< 50).allIt(queues[it][0] == -1)
  if idle and cp[1] != Value.low:
    result = cp[1]
    queues[0].addLast cp[0]
    queues[0].addLast cp[1]

proc part2(input: string): int =
  initQueues(100)
  for i in 0 ..< 50:
    queues[i].addLast i

  var programs = newSeq[Program]()
  for i in 0 ..< 50:
    programs.add newProgram(input, i, 50 + i)

  while true:
    for p in programs: discard p.stepOver
    let res = networkStep2()
    if res == 0: continue
    if result == res: return
    result = res



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
