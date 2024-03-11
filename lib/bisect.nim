proc bisectRangeFirst*(
  lo, hi: int,
  pred: proc (i: int): bool
): int =
  var
    lo = lo
    hi = hi
  while lo < hi:
    let mid = lo + ((hi - lo) shr 1)
    if not pred(mid): lo = mid + 1
    else: hi = mid
  lo
