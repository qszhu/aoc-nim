const dPos4 = [(-1, 0), (0, 1), (1, 0), (0, -1)]

iterator neighbors4*(p, dim: (int, int)): (int, int) =
  let
    (r, c) = p
    (maxr, maxc) = dim
  for (dr, dc) in dPos4:
    let (nr, nc) = (r + dr, c + dc)
    if nr in 0 ..< maxr and nc in 0 ..< maxc:
      yield (nr, nc)

proc floodfill*[T](grid: var seq[seq[T]], r, c: int, src, dst: T) =
  if src == dst: return
  let (rows, cols) = (grid.len, grid[0].len)

  proc fill(grid: var seq[seq[T]], r, c: int) =
    if grid[r][c] != src: return
    grid[r][c] = dst
    for (nr, nc) in neighbors4((r, c), (rows, cols)):
      fill(grid, nr, nc)

  fill(grid, r, c)
