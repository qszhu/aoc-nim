import ../../lib/imports



type
  Component = tuple[quantity: int, name: string]

  Reaction = tuple[left: seq[Component], right: Component]

proc parseComponent(s: string): Component =
  let parts = s.split(" ")
  let quantity = parts[0].parseInt
  let name = parts[1]
  (quantity, name)

proc parseLine(line: string): Reaction =
  let parts = line.split(" => ")
  let left = parts[0].split(", ").mapIt(it.parseComponent)
  let right = parts[1].parseComponent
  (left, right)

proc parse(input: string): seq[Reaction] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL
""".strip
  block:
    let rs = input.parse
    doAssert rs == @[
      (@[(10, "ORE")], (10, "A")),
      (@[(1, "ORE")], (1, "B")),
      (@[(7, "A"), (1, "B")], (1, "C")),
      (@[(7, "A"), (1, "C")], (1, "D")),
      (@[(7, "A"), (1, "D")], (1, "E")),
      (@[(7, "A"), (1, "E")], (1, "FUEL")),
    ]

proc calcReq(rs: seq[Reaction], req = 1): int =
  var mapping = initTable[string, int]()
  proc getIdx(s: string): int =
    if s notin mapping:
      mapping[s] = mapping.len
    mapping[s]

  for (left, right) in rs:
    for (_, name) in left:
      discard getIdx(name)
    let (_, name) = right
    discard getIdx(name)

  let N = mapping.len
  var adjList = newSeqWith(N, newSeq[int]())
  for (left, right) in rs:
    let (_, rname) = right
    for (_, lname) in left:
      adjList[lname.getIdx].add rname.getIdx

  let order = topologicalSort(adjList)
  var reqs = newSeq[int](N)
  reqs["FUEL".getIdx] = req
  for i in order:
    if i == "ORE".getIdx: break
    let (left, right) = rs.filterIt(it.right.name.getIdx == i)[0]
    let mul = (reqs[i] + right.quantity - 1) div right.quantity
    for (quantity, name) in left:
      reqs[name.getIdx] += quantity * mul
  reqs["ORE".getIdx]

when defined(test):
  block:
    doAssert input.parse.calcReq == 31
  let input2 = """
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL
""".strip
  block:
    doAssert input2.parse.calcReq == 165
  let input3 = """
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
""".strip
  block:
    doAssert input3.parse.calcReq == 13312
  let input4 = """
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF
""".strip
  block:
    doAssert input4.parse.calcReq == 180697
  let input5 = """
171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX
""".strip
  block:
    doAssert input5.parse.calcReq == 2210736

proc part1(input: string): int =
  input.parse.calcReq



proc part2(input: string): int =
  let rs = input.parse
  bisectRangeLast(0, 1e12.int, i => rs.calcReq(i) <= 1e12.int)

when defined(test):
  block:
    doAssert part2(input3) == 82892753
    doAssert part2(input4) == 5586022
    doAssert part2(input5) == 460664



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
