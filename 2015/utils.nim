iterator rle*[T](x: var openArray[T]): (T, int) =
  var c = 0
  for i in 0 ..< x.len:
    c += 1
    if i + 1 == x.len or x[i + 1] != x[i]:
      yield (x[i], c)
      c = 0
