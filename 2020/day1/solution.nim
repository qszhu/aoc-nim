import ../../lib/imports



proc parse(input: string): seq[int] =
  input.split("\n").mapIt(it.parseInt)

proc findTarget(a: sink seq[int], target: int): int =
  let N = a.len
  var (i, j) = (0, N - 1)
  while i < j:
    if a[i] + a[j] == target: return a[i] * a[j]
    if a[i] + a[j] > target: j -= 1
    else: i += 1

proc part1(input: string): int =
  findTarget(input.parse.sorted, 2020)

when defined(test):
  let input = """
1721
979
366
299
675
1456
""".strip
  block:
    doAssert part1(input) == 514579



proc part2(input: string): int =
  let nums = input.parse.sorted
  for i, x in nums:
    let r = findTarget(nums[i + 1 ..< nums.len], 2020 - x)
    if r != 0: return r * x

when defined(test):
  block:
    doAssert part2(input) == 241861950



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
