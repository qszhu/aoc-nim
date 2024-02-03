import std/[
  algorithm,
  bitops,
  deques,
  heapqueue,
  intsets,
  json,
  lists,
  math,
  rdstdin,
  re,
  sequtils,
  sets,
  strformat,
  strutils,
  tables,
  sugar,
]



type
  Direction = enum
    UP
    RIGHT
    DOWN
    LEFT

const dPos = [(-1, 0), (0, 1), (1, 0), (0, -1)]

const turnOpts = [-1, 0, 1]

type
  Tracks = seq[string]

  Cart = object
    x, y: int
    dir: Direction
    turn: int
    crashed: bool

proc `<`(a, b: Cart): bool =
  if a.y != b.y: a.y < b.y
  else: a.x < b.x

proc parse(input: string): (Tracks, seq[Cart]) =
  var tracks = input.split("\n")
  var carts = newSeq[Cart]()
  for r in 0 ..< tracks.len:
    for c in 0 ..< tracks[r].len:
      case tracks[r][c]:
      of '^':
        carts.add Cart(x: c, y: r, dir: Direction.UP)
        tracks[r][c] = '|'
      of '>':
        carts.add Cart(x: c, y: r, dir: Direction.RIGHT)
        tracks[r][c] = '-'
      of 'v':
        carts.add Cart(x: c, y: r, dir: Direction.DOWN)
        tracks[r][c] = '|'
      of '<':
        carts.add Cart(x: c, y: r, dir: Direction.LEFT)
        tracks[r][c] = '-'
      else: discard
  (tracks, carts)

when defined(test):
  let input = """
/->-\        
|   |  /----\
| /-+--+-\  |
| | |  | v  |
\-+-/  \-+--/
  \------/   
"""
  block:
    let (tracks, carts) = input.parse
    doAssert carts == @[
      Cart(x: 2, y: 0, dir: Direction.RIGHT),
      Cart(x: 9, y: 3, dir: Direction.DOWN)
    ]

proc move(cart: Cart, tracks: var Tracks): Cart =
  var (x, y, dir, turn) = (cart.x, cart.y, cart.dir, cart.turn)
  let (dr, dc) = dPos[dir.ord]
  (y, x) = (y + dr, x + dc)
  case tracks[y][x]:
  of '+':
    dir = ((dir.ord + turnOpts[turn] + 4) mod 4).Direction
    turn = (turn + 1) mod 3
  of '\\':
    case dir:
    of UP: dir = LEFT
    of LEFT: dir = UP
    of RIGHT: dir = DOWN
    of DOWN: dir = RIGHT
  of '/':
    case dir:
    of UP: dir = RIGHT
    of RIGHT: dir = UP
    of LEFT: dir = DOWN
    of DOWN: dir = LEFT
  else: discard
  Cart(x: x, y: y, dir: dir, turn: turn)

proc step(tracks: var Tracks, carts: var seq[Cart]): (bool, (int, int)) =
  carts.sort
  for i, cart in carts.mpairs:
    cart = cart.move(tracks)
    for j, cart1 in carts:
      if i == j: continue
      if (cart.x, cart.y) == (cart1.x, cart1.y):
        return (true, (cart.x, cart.y))
  (false, (-1, -1))

proc part1(input: string): (int, int) =
  var (tracks, carts) = input.parse
  while true:
    let (res, pos) = step(tracks, carts)
    if res: return pos

when defined(test):
  block:
    doAssert part1(input) == (7, 3)



proc step2(tracks: var Tracks, carts: var seq[Cart]) =
  carts.sort
  for i, cart in carts.mpairs:
    if cart.crashed: continue
    cart = cart.move(tracks)
    for j, cart1 in carts.mpairs:
      if i == j: continue
      if cart1.crashed: continue
      if (cart.x, cart.y) == (cart1.x, cart1.y):
        cart.crashed = true
        cart1.crashed = true
  carts = carts.filterIt(not it.crashed)

proc part2(input: string): (int, int) =
  var (tracks, carts) = input.parse
  while true:
    step2(tracks, carts)
    if carts.len == 1: return (carts[0].x, carts[0].y)

when defined(test):
  block:
    let input = """
/>-<\  
|   |  
| /<+-\
| | | v
\>+</ |
  |   ^
  \<->/
"""
    doAssert part2(input) == (6, 4)



when isMainModule and not defined(test):
  let input = readFile("input")
  echo part1(input)
  echo part2(input)
