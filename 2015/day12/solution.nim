import std/[
  algorithm,
  bitops,
  json,
  math,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
]



proc nums(jso: JsonNode, filterVal = ""): seq[int] =
  if jso.kind == JArray:
    for n in jso:
      result &= nums(n, filterVal)
  elif jso.kind == JObject:
    var shouldIgnore = false
    if filterVal.len > 0:
      for k in jso.keys:
        if jso[k].kind == JString and jso[k].getStr == filterVal:
          shouldIgnore = true
          break
    if shouldIgnore: return
    for k in jso.keys:
      result &= nums(jso[k], filterVal)
  elif jso.kind == JInt:
    result.add jso.getInt

when defined(test):
  doAssert nums("[1,2,3]".parseJson).toSeq == @[1, 2, 3]
  doAssert nums(r"{""a"":2,""b"":4}".parseJson).toSeq == @[2, 4]
  doAssert nums("[[[3]]]".parseJson).toSeq == @[3]
  doAssert nums(r"{""a"":{""b"":4},""c"":-1}".parseJson).toSeq == @[4, -1]
  doAssert nums(r"{""a"":[-1,1]}".parseJson).toSeq == @[-1, 1]
  doAssert nums(r"[-1,{""a"":1}]".parseJson).toSeq == @[-1, 1]
  doAssert nums("[]".parseJson).toSeq == @[]
  doAssert nums("{}".parseJson).toSeq == @[]

proc part1(s: string): int =
  nums(s.parseJson).sum

when defined(test):
  doAssert nums("[1,2,3]".parseJson, "red").toSeq == @[1, 2, 3]
  doAssert nums(r"[1,{""c"":""red"",""b"":2},3]".parseJson, "red").toSeq == @[1, 3]
  doAssert nums(r"{""d"":""red"",""e"":[1,2,3,4],""f"":5}".parseJson, "red").toSeq == @[]
  doAssert nums(r"[1,""red"",5]".parseJson, "red") == @[1, 5]

proc part2(s: string): int =
  nums(s.parseJson, "red").sum

when isMainModule and not defined(test):
  let input = readAll(stdin).strip
  echo part1(input)
  echo part2(input)
