const dPos4 = [(-1, 0), (0, 1), (1, 0), (0, -1)]

iterator neighbors4*(p, dim: (int, int)): (int, int) =
  let
    (r, c) = p
    (maxr, maxc) = dim
  for (dr, dc) in dPos4:
    let (nr, nc) = (r + dr, c + dc)
    if nr in 0 ..< maxr and nc in 0 ..< maxc:
      yield (nr, nc)
