import ../../lib/imports
import ../day9/programs



proc waitKey(prompt = "") {.inline.} =
  discard readLineFromStdin(prompt)

proc getOutput(): string =
  while queues[1].len > 0:
    result &= queues[1].popFirst.char

proc writeInput(s: string) =
  for ch in s:
    queues[0].addLast ch.ord
  queues[0].addLast '\n'.ord

proc walkInteractive(input: string) =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  while true:
    discard p.stepOver
    echo getOutput()
    writeInput readLineFromStdin("")

when defined(interactive):
  block:
    let input = readFile("input").strip
    input.walkInteractive
    quit()



type
  CellInfo = object
    name: string
    dirs: seq[string]
    item: string

var hasAlert: bool

proc getCellInfo(output: string): CellInfo =
  var name = ""
  var dirs = newSeq[string]()
  var item = ""
  var items = newSeq[string]()
  var readDoors, readItems = false
  for line in output.split("\n"):
    if line.startsWith("== "):
      name = line[3 ..< ^3]
    elif line == "Doors here lead:":
      readDoors = true
    elif line == "Items here:":
      readItems = true
    elif line.strip.len == 0:
      readDoors = false
      readItems = false
    elif line.startsWith("A loud, robotic voice says") and ("lighter" in line or "heavier" in line):
      hasAlert = true
    else:
      if readDoors:
        dirs.add line[2 .. ^1]
      elif readItems:
        items.add line[2 .. ^1]
  if items.len == 1: item = items[0]
  CellInfo(name: name, dirs: dirs, item: item)

const DIRS = @["north", "east", "south", "west"]

proc rev(dir: string): string {.inline.} =
  DIRS[(DIRS.find(dir) + 2) mod 4]

const ignoredItems = @[
  # You're launched into space! Bye!
  "escape pod",

  "infinite loop",

  # It is suddenly completely dark! You are eaten by a Grue!
  "photons",

  # The giant electromagnet is stuck to you.  You can't move!!
  "giant electromagnet",

  # The molten lava is way too hot! You melt!
  "molten lava",
].toHashSet

proc collectItems(input: string): seq[string] =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  # (dir, visiting)
  var st = newSeq[(string, bool)]()
  var firstVisit = true
  while true:
    discard p.stepOver
    let cellInfo = getOutput().getCellInfo
    # echo cellInfo
    if cellInfo.name == "": break

    if cellInfo.item != "":
      let item = cellInfo.item
      if item notin ignoredItems:
        writeInput &"take {item}"
        result.add item
        discard p.stepOver
        discard getOutput()

    let fromDir = if st.len > 0: st[^1][0].rev else: ""
    for dir in cellInfo.dirs:
      if dir == fromDir: continue
      st.add (dir, false)

    if cellInfo.name == "Security Checkpoint":
      if firstVisit:
        firstVisit = false
        discard st.pop
      else:
        discard p.stepOver
        return

    while st.len > 0 and st[^1][1]:
      let (dir, _) = st.pop
      let ndir = dir.rev
      writeInput ndir
      if st.len == 0: continue
      discard p.stepOver
      discard getOutput()

    if st.len > 0:
      let dir = st[^1][0]
      st[^1][1] = true
      writeInput dir

when defined(collect):
  block:
    let input = readFile("input").strip
    echo input.collectItems
    quit()



proc tryItems(input: string, targetItems: seq[string]) =
  initQueues(2)
  let p = newProgram(input, 0, 1)
  # (dir, visiting)
  var st = newSeq[(string, bool)]()
  var firstVisit = true
  while true:
    discard p.stepOver
    let output = getOutput()
    echo output
    let cellInfo = output.getCellInfo
    # echo cellInfo
    if cellInfo.name == "": break

    if cellInfo.item != "":
      let item = cellInfo.item
      if item in targetItems:
        writeInput &"take {item}"
        discard p.stepOver
        discard getOutput()

    let fromDir = if st.len > 0: st[^1][0].rev else: ""
    for dir in cellInfo.dirs:
      if dir == fromDir: continue
      st.add (dir, false)

    if cellInfo.name == "Security Checkpoint":
      if firstVisit:
        firstVisit = false
        discard st.pop
      else:
        discard p.stepOver
        discard getOutput()
        if hasAlert: return

    while st.len > 0 and st[^1][1]:
      let (dir, _) = st.pop
      let ndir = dir.rev
      writeInput ndir
      if st.len == 0: continue
      discard p.stepOver
      discard getOutput()

    if st.len > 0:
      let dir = st[^1][0]
      st[^1][1] = true
      writeInput dir

proc part1(input: string) =
  let input = readFile("input").strip
  let items = input.collectItems
  for i in 0 ..< (1 shl items.len):
    var targetItems = newSeq[string]()
    for j in 0 ..< items.len:
      if i.testBit(j): targetItems.add items[j]
    hasAlert = false
    tryItems(input, targetItems)
    if not hasAlert:
      echo targetItems
      break



when isMainModule and not defined(test):
  let input = readFile("input").strip
  part1(input)
