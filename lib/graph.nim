proc topologicalSort*(adjList: seq[seq[int]]): seq[int] =
  let N = adjList.len
  var visiting = newSeq[bool](N)
  var visited = newSeq[bool](N)
  var res = newSeq[int]()
  proc visit(u: int) =
    if visited[u]: return
    if visiting[u]: raise newException(CatchableError, "loop")

    visiting[u] = true
    for v in adjList[u]: visit(v)
    visiting[u] = false

    visited[u] = true
    res.add u

  for u in 0 ..< N:
    if visited[u]: continue
    visit(u)
  res
