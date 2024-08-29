import ../../lib/imports



type
  Food = (seq[string], seq[string])

proc parseLine(line: string): Food =
  if line =~ re"([^\(]+) \(contains ([^)]+)\)":
    return (matches[0].split(" "), matches[1].split(", "))
  else:
    raise newException(ValueError, "parse error: " & line)

proc parse(input: string): seq[Food] =
  input.split("\n").mapIt(it.parseLine)

when defined(test):
  let input = """
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
""".strip
  block:
    doAssert input.parse == @[
      (@["mxmxvkd", "kfcds", "sqjhc", "nhms"], @["dairy", "fish"]),
      (@["trh", "fvjkl", "sbzzf", "mxmxvkd"], @["dairy"]),
      (@["sqjhc", "fvjkl"], @["soy"]),
      (@["sqjhc", "mxmxvkd", "sbzzf"], @["fish"])
    ]

proc match(foods: seq[Food]): Table[string, HashSet[string]] =
  for (ings, alls) in foods:
    for all in alls:
      if all notin result:
        result[all] = ings.toHashSet
      else:
        result[all] = result[all] * ings.toHashSet

proc part1(input: string): int =
  let foods = input.parse
  let cands = match(foods)
  let allIngs = cands.values.toSeq.foldl a + b
  for (ings, _) in foods:
    result += ings.countIt(it notin allIngs)

when defined(test):
  block:
    doAssert part1(input) == 5



proc part2(input: string): string =
  let foods = input.parse
  var cands = match(foods)
  var mapping = initTable[string, string]()
  var mapped = initHashSet[string]()
  let N = cands.len
  while mapping.len < N:
    var toDelete = newSeq[string]()
    for k, v in cands.mpairs:
      if v.len == 1:
        mapping[k] = v.toSeq[0]
        mapped.incl mapping[k]
        toDelete.add k
    for k in toDelete:
      cands.del k
    for v in cands.mvalues:
      v = v - mapped
  mapping.pairs.toSeq.sortedByIt(it[0]).mapIt(it[1]).join(",")

when defined(test):
  block:
    doAssert part2(input) == "mxmxvkd,sqjhc,fvjkl"



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
