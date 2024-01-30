import std/[
  sequtils,
]



type
  Imos*[T] = seq[seq[T]]

proc initImos*[T](rows, cols: int): Imos[T] =
  newSeqWith(rows + 1, newSeq[T](cols + 1))

proc addRect*[T](im: var Imos[T], r1, c1, r2, c2: int, c = 1) =
  im[r1][c1] += c
  im[r1][c2 + 1] -= c
  im[r2 + 1][c1] -= c
  im[r2 + 1][c2 + 1] += c

proc restore*[T](im: var Imos[T]): seq[seq[T]] =
  let (rows, cols) = (im.len - 1, im[0].len - 1)
  result = newSeqWith(rows, newSeq[T](cols))
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      result[r][c] = im[r][c]

  for r in 0 ..< rows:
    for c in 1 ..< cols:
      result[r][c] += result[r][c - 1]
  for c in 0 ..< cols:
    for r in 1 ..< rows:
      result[r][c] += result[r - 1][c]
