import ../../lib/imports



const EMPTY = '.'
const TREE = '#'

type
  Grid = seq[string]

proc parse(input: string): Grid =
  input.split("\n")

proc countTrees(grid: Grid, dr, dc: int): int =
  let cols = grid[0].len
  var r, c = 0
  while r < grid.len:
    if grid[r][c] == TREE:
      result += 1
    (r, c) = (r + dr, (c + dc) mod cols)

when defined(test):
  let input = """
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
""".strip
  block:
    doAssert countTrees(input.parse, 1, 3) == 7

proc part1(input: string): int =
  countTrees(input.parse, 1, 3)



proc part2(input: string): int =
  result = 1
  for (dc, dr) in [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]:
    result *= countTrees(input.parse, dr, dc)

when defined(test):
  block:
    doAssert part2(input) == 336



when isMainModule and not defined(test):
  let input = readFile("input").strip
  echo part1(input)
  echo part2(input)
