import std/[sequtils]



const dPos4 = [(-1, 0), (0, 1), (1, 0), (0, -1)]

iterator neighbors4*(p, dim: (int, int)): (int, int) =
  let
    (r, c) = p
    (maxr, maxc) = dim
  for (dr, dc) in dPos4:
    let (nr, nc) = (r + dr, c + dc)
    if nr in 0 ..< maxr and nc in 0 ..< maxc:
      yield (nr, nc)

proc floodfill*[T](grid: var seq[seq[T]], r, c: int, src, dst: T): int {.discardable.} =
  if src == dst: return 0
  let (rows, cols) = (grid.len, grid[0].len)

  proc fill(grid: var seq[seq[T]], r, c: int): int =
    if grid[r][c] != src: return 0
    grid[r][c] = dst
    result = 1
    for (nr, nc) in neighbors4((r, c), (rows, cols)):
      result += fill(grid, nr, nc)

  fill(grid, r, c)

type PrefixSum2D[T] = seq[seq[T]]

proc prefixSum*[T](grid: var seq[seq[T]]): PrefixSum2D[T] =
  let (rows, cols) = (grid.len, grid[0].len)
  result = newSeqWith(rows + 1, newSeq[T](cols + 1))
  for r in 1 .. rows:
    for c in 1 .. cols:
      result[r][c] = result[r - 1][c] + result[r][c - 1] - result[r - 1][c - 1] + grid[r - 1][c - 1]

proc blockSum*[T](p: var PrefixSum2D[T], r1, c1, r2, c2: int): T =
  p[r2 + 1][c2 + 1] - p[r2 + 1][c1] - p[r1][c2 + 1] + p[r1][c1]
