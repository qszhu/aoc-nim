import std/[
  sequtils
]



proc exGcd*(a, b, x, y: int64): (int64, int64, int64) =
  if b == 0: return (1'i64, 0'i64, a)
  var (nx, ny, d) = exGcd(b, a mod b, x, y)
  (nx, ny) = (ny, nx - a div b * ny)
  return (nx, ny, d)

proc crt*(r, a: sink seq[int64]): (int64, int64) =
  var res = 0'i64
  var n = r.foldl a * b
  for i in 0 ..< r.len:
    let m = n div r[i]
    let (nb, _, _) = exGcd(m, r[i], 0, 0)
    res = (res + a[i] * m * nb mod n) mod n
  res = (res mod n + n) mod n
  (res, n)
