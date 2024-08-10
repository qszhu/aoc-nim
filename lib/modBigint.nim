import pkg/[
  bigints
]



template modBigint*(m: untyped) =
  const MOD* {.inject.} = m.initBigInt
  const Zero* {.inject.} = 0.initBigInt
  const One* {.inject.} = 1.initBigInt
  const Two* {.inject.} = 2.initBigInt

  type
    mint* {.inject.} = distinct BigInt

  proc `+`*(x, y: mint): mint {.inline.} =
    (((x.BigInt mod MOD) + (y.BigInt mod MOD) + MOD) mod MOD).mint

  proc `-`*(x, y: mint): mint {.inline.} =
    (((x.BigInt mod MOD) - (y.BigInt mod MOD) + MOD) mod MOD).mint

  proc `*`*(x, y: mint): mint {.inline.} =
    ((x.BigInt mod MOD) * (y.BigInt mod MOD) mod MOD).mint

  proc `**`*(x, y: mint): mint =
    result = One.mint
    var x = x
    var y = y.BigInt
    while y > Zero:
      if (y and One) != Zero: result = result * x
      x = x * x
      y = y shr 1

  proc `/`*(x, y: mint): mint =
    x * (y ** ((MOD - Two).mint))

  proc initMint*(n: int): mint {.inline.} =
    initBigInt(n).mint
