import std/[
  options,
  strutils,
]



const RED = true
const BLACK = false

type
  Node[K, V] = ref object
    key: K
    val: V
    left, right: Node[K, V]
    color: bool # incomming link color
    size: int

proc newNode[K, V](key: K, val: V, color = RED, size = 1): Node[K, V] =
  result.new
  result.key = key
  result.val = val
  result.color = color
  result.size = size

proc search[K, V](self: Node[K, V], key: K): Option[V] =
  var x = self
  while x != nil:
    let c = cmp(key, x.key)
    if c < 0: x = x.left
    elif c > 0: x = x.right
    else: return some(x.val)
  none(V)

proc isRed(self: Node): bool {.inline.} =
  var x = self
  x != nil and x.color == RED

proc len(self: Node): int {.inline.} =
  if self == nil: 0
  else: self.size

proc rotateLeft[K, V](self: Node[K, V]): Node[K, V] =
  var h = self
  var x = h.right
  h.right = x.left
  x.left = h
  x.color = h.color
  h.color = RED
  x.size = h.size
  h.size = h.left.len + h.right.len + 1
  x

proc rotateRight[K, V](self: Node[K, V]): Node[K, V] =
  var h = self
  var x = h.left
  h.left = x.right
  x.right = h
  x.color = h.color
  h.color = RED
  x.size = h.size
  h.size = h.left.len + h.right.len + 1
  x

proc flipColors[K, V](self: Node[K, V]) =
  var h = self
  h.color = not h.color
  h.left.color = not h.left.color
  h.right.color = not h.right.color

proc insert[K, V](self: Node[K, V], key: K, val: V): Node[K, V] =
  var h = self
  if h == nil: return newNode(key, val)

  let c = cmp(key, h.key)
  if c < 0:
    h.left = h.left.insert(key, val)
  elif c > 0:
    h.right = h.right.insert(key, val)
  else:
    h.val = val

  if h.right.isRed and not h.left.isRed:
    h = h.rotateLeft
  if h.left.isRed and h.left.left.isRed:
    h = h.rotateRight
  if h.left.isRed and h.right.isRed:
    h.flipColors
  h.size = h.left.len + h.right.len + 1

  h

proc moveRedLeft[K, V](self: Node[K, V]): Node[K, V] =
  var h = self
  h.flipColors
  if h.right.left.isRed:
    h.right = h.right.rotateRight
    h = h.rotateLeft
    h.flipColors
  h

proc moveRedRight[K, V](self: Node[K, V]): Node[K, V] =
  var h = self
  h.flipColors
  if h.left.left.isRed:
    h = h.rotateRight
    h.flipColors
  h

proc balance[K, V](self: Node[K, V]): Node[K, V] =
  var h = self
  if h.right.isRed and not h.left.isRed:
    h = h.rotateLeft
  if h.left.isRed and h.left.left.isRed:
    h = h.rotateRight
  if h.left.isRed and h.right.isRed:
    h.flipColors
  h.size = h.left.len + h.right.len + 1
  h

proc deleteMin[K, V](self: Node[K, V]): Node[K, V] =
  var h = self
  if h.left == nil: return nil
  if not h.left.isRed and not h.left.left.isRed:
    h = h.moveRedLeft
  h.left = h.left.deleteMin
  h.balance

proc deleteMax[K, V](self: Node[K, V]): Node[K, V] =
  var h = self
  if h.left.isRed:
    h = h.rotateRight
  if h.right == nil: return nil
  if not h.right.isRed and not h.right.left.isRed:
    h = h.moveRedRight
  h.right = h.right.deleteMax
  h.balance

proc min[K, V](self: Node[K, V]): Node[K, V] =
  var x = self
  if x.left == nil: x
  else: x.left.min

proc max[K, V](self: Node[K, V]): Node[K, V] =
  var x = self
  if x.right == nil: x
  else: x.right.max

proc delete[K, V](self: Node[K, V], key: K): Node[K, V] =
  var h = self
  if cmp(key, h.key) < 0:
    if not h.left.isRed and not h.left.left.isRed:
      h = h.moveRedLeft
    h.left = h.left.delete(key)
  else:
    if h.left.isRed:
      h = h.rotateRight
    if cmp(key, h.key) == 0 and h.right == nil: return nil
    if not h.right.isRed and not h.right.left.isRed:
      h = h.moveRedRight
    if cmp(key, h.key) == 0:
      var x = h.right.min
      h.key = x.key
      h.val = x.val
      h.right = h.right.deleteMin
    else:
      h.right = h.right.delete(key)
  h.balance

# lowerbound
proc ceiling[K, V](self: Node[K, V], key: K): Node[K, V] =
  var x = self
  if x == nil: return nil
  let c = cmp(key, x.key)
  if c == 0: return x
  if c > 0: return x.right.ceiling(key)
  var t = x.left.ceiling(key)
  if t != nil: t else: x

proc floor[K, V](self: Node[K, V], key: K): Node[K, V] =
  var x = self
  if x == nil: return nil
  let c = cmp(key, x.key)
  if c == 0: return x
  if c < 0: return x.left.floor(key)
  var t = x.right.floor(key)
  if t != nil: t else: x

proc keys[K, V](self: Node[K, V], queue: var seq[K], lo, hi: K) =
  var x = self
  if x == nil: return
  let clo = cmp(lo, x.key)
  let chi = cmp(hi, x.key)
  if clo < 0: keys(x.left, queue, lo, hi)
  if clo <= 0 and chi >= 0: queue.add x.key
  if chi > 0: keys(x.right, queue, lo, hi)

proc select[K, V](self: Node[K, V], rank: int): Node[K, V] =
  var x = self
  if x == nil: return
  let leftSize = x.left.len
  if leftSize > rank: return x.left.select(rank)
  if leftSize < rank: return x.right.select(rank - leftSize - 1)
  x

proc rank[K, V](self: Node[K, V], key: K): int =
  var x = self
  if x == nil: return
  let c = cmp(key, x.key)
  if c < 0: return x.left.rank(key)
  if c > 0: return x.left.len + 1 + x.right.rank(key)
  x.left.len



type TreeMap[K, V] = ref object
  root: Node[K, V]

proc newTreeMap*[K, V](): TreeMap[K, V] =
  result.new

proc len*[K, V](self: TreeMap[K, V]): int {.inline.} =
  self.root.len

proc get*[K, V](self: TreeMap[K, V], key: K): Option[V] =
  self.root.search(key)

proc put*[K, V](self: TreeMap[K, V], key: K, val: V) =
  self.root = self.root.insert(key, val)
  self.root.color = BLACK

proc remove*[K, V](self: TreeMap[K, V], key: K) =
  if not self.root.left.isRed and not self.root.right.isRed:
    self.root.color = RED
  self.root = self.root.delete(key)
  if self.len > 0: self.root.color = BLACK

proc ceilingEntry*[K, V](self: TreeMap[K, V], key: K): Option[(K, V)] =
  if self.len == 0: return none((K, V))
  var x = self.root.ceiling(key)
  if x == nil: none((K, V))
  else: some((x.key, x.val))

proc floorEntry*[K, V](self: TreeMap[K, V], key: K): Option[(K, V)] =
  if self.len == 0: return none((K, V))
  var x = self.root.floor(key)
  if x == nil: none((K, V))
  else: some((x.key, x.val))

proc minEntry*[K, V](self: TreeMap[K, V]): Option[(K, V)] =
  var x = self.root.min
  if x == nil: none((K, V))
  else: some((x.key, x.val))

proc maxEntry*[K, V](self: TreeMap[K, V]): Option[(K, V)] =
  var x = self.root.max
  if x == nil: none((K, V))
  else: some((x.key, x.val))

proc keys*[K, V](self: TreeMap[K, V], lo, hi: K): seq[K] =
  result = newSeq[K]()
  keys(self.root, result, lo, hi)

proc keys*[K, V](self: TreeMap[K, V]): seq[K] =
  if self.len == 0: return
  self.keys(self.minEntry.get()[0], self.maxEntry.get()[0])

proc selectEntry*[K, V](self: TreeMap[K, V], rank: int): Option[(K, V)] =
  let x = self.root.select(rank)
  if x == nil: none((K, V))
  else: some((x.key, x.val))

proc rank*[K, V](self: TreeMap[K, V], key: K): int =
  self.root.rank(key)



type OrderedList[K] = ref object
  tm: TreeMap[K, bool]

proc newOrderedList*[K](): OrderedList[K] =
  result.new
  result.tm = newTreeMap[K, bool]()

proc insert*[K](self: OrderedList[K], key: K) =
  self.tm.put(key, true)

proc delete*[K](self: OrderedList[K], key: K) =
  self.tm.remove(key)

proc getAt*[K](self: OrderedList[K], i: int): K =
  let e = self.tm.selectEntry(i)
  if e.isSome: e.get[0]
  else: raise newException(ValueError, "Index out of range: " & $i)

proc deleteAt*[K](self: OrderedList[K], i: int) =
  self.tm.remove(self.getAt(i))

proc find*[K](self: OrderedList[K], key: K): int =
  if key notin self: return -1
  else: self.tm.rank(key)

proc len*[K](self: OrderedList[K]): int =
  self.tm.len

proc contains*[K](self: OrderedList[K], key: K): bool =
  self.tm.get(key).isSome

proc next*[K](self: OrderedList[K], key: K): Option[K] =
  let e = self.tm.ceilingEntry(key.succ)
  if e.isSome: some(e.get[0])
  else: none(K)

iterator items*[K](self: OrderedList[K]): K =
  if self.len >= 0:
    var k = self.getAt(0)
    yield k
    var e = self.next(k)
    while e.isSome:
      k = e.get
      yield k
      e = self.next(k)
