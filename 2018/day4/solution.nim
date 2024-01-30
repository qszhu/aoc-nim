import std/[
  algorithm,
  bitops,
  deques,
  intsets,
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



type
  EventType = enum
    Start
    Sleep
    Wakeup

  Event = tuple[minute, second: int, `type`: EventType, id: int]

proc parseLine(line: string): Event =
  if line =~ re"\[\d{4}-\d{2}-\d{2} (\d{2}):(\d{2})\] Guard #(\d+) begins shift":
    (matches[0].parseInt, matches[1].parseInt, Start, matches[2].parseInt)
  elif line =~ re"\[\d{4}-\d{2}-\d{2} (\d{2}):(\d{2})\] falls asleep":
    (matches[0].parseInt, matches[1].parseInt, Sleep, -1)
  elif line =~ re"\[\d{4}-\d{2}-\d{2} (\d{2}):(\d{2})\] wakes up":
    (matches[0].parseInt, matches[1].parseInt, Wakeup, -1)
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): seq[Event] =
  input.split("\n").sorted.mapIt(it.parseLine)

when defined(test):
  let input = """
[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up
""".strip
  block:
    let events = input.parse
    doAssert events[0] == (0, 0, Start, 10)
    doAssert events[1] == (0, 5, Sleep, -1)
    doAssert events[2] == (0, 25, Wakeup, -1)

type
  Guard = tuple[counts: seq[int], total: int]

proc getSleepTable(events: seq[Event]): Table[int, Guard] =
  var curId = -1
  var p = 0
  for (minute, second, eventType, id) in events:
    case eventType:
    of Start:
      curId = id
      if curId notin result:
        result[curId] = (newSeq[int](60), 0)
    of Sleep:
      p = second
    of Wakeup:
      for i in p ..< second:
        result[curId][0][i] += 1
      result[curId][1] += second - p

proc part1(input: string): int =
  let sleeps = getSleepTable(input.parse)
  var maxSleepTime = 0
  var targetId = -1
  for id, (_, total) in sleeps:
    if maxSleepTime < total:
      maxSleepTime = total
      targetId = id
  let targetSleeps = sleeps[targetId][0]
  targetId * targetSleeps.find(targetSleeps.max)

when defined(test):
  block:
    doAssert part1(input) == 240



proc part2(input: string): int =
  let sleeps = getSleepTable(input.parse)
  var mostSleep = 0
  var targetId = -1
  for id, (cnts, _) in sleeps:
    let maxCnt = cnts.max
    if mostSleep < maxCnt:
      mostSleep = maxCnt
      targetId = id
  let targetSleeps = sleeps[targetId][0]
  targetId * targetSleeps.find(mostSleep)

when defined(test):
  block:
    doAssert part2(input) == 4455



when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
