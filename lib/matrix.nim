import std/[
  sequtils,
]



type SquareMatrix*[T] = ref object
  a*: seq[seq[T]]

proc newSquareMatrix*[T](dim: int): SquareMatrix[T] =
  result.new
  result.a = newSeqWith(dim, newSeq[T](dim))

proc newSquareMatrix*[T](a: seq[seq[T]]): SquareMatrix[T] =
  result.new
  result.a = a

proc identity*[T](dim: int, one: T): SquareMatrix[T] =
  result = newSquareMatrix[T](dim)
  for i in 0 ..< dim:
    result.a[i][i] = one

proc `*`*[T](a, b: SquareMatrix[T]): SquareMatrix[T] =
  let d = a.a.len
  result = newSquareMatrix[T](d)
  for i in 0 ..< d:
    for k in 0 ..< d:
      for j in 0 ..< d:
        result.a[i][j] = result.a[i][j] + a.a[i][k] * b.a[k][j]
template `*=`*[T](x, y: SquareMatrix[T]): void = x = x * y

proc `^`*[T](x: SquareMatrix[T], p: int64, one: T): SquareMatrix[T] =
  result = identity[T](x.a.len, one)
  var x = x
  var p = p
  while p > 0:
    if (p and 1) != 0: result *= x
    x *= x
    p = p shr 1
template `^=`*[T](x: SquareMatrix[T], p: int64): void = x = x ^ y
