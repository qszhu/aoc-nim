# Advent of Code Solutions in Nim

> `*` denotes tricky problems

## 2020

Day | Tags | Memo
--- | --- | ---
[25](2020/day25/solution.nim) | implementation |
[24](2020/day24/solution.nim) | hexagon, simulation | See 2017 day 11
[23](2020/day23/solution.nim)* | simulation, table | part2: use hash table to implement circular linked list
[22](2020/day22/solution.nim) | simulation, deque |
[21](2020/day21/solution.nim) | set |
[20](2020/day20/solution.nim)* | implementation | borders are unique; monsters won't overlap
[19](2020/day19/solution.nim)* | dfs, grammar | part2: brute force rules
[18](2020/day18/solution.nim) | expression, stack | [Shunting yard algorithm](https://en.wikipedia.org/wiki/Shunting_yard_algorithm)
[17](2020/day17/solution.nim) | simulation |
[16](2020/day16/solution.nim) | implementation, set |
[15](2020/day15/solution.nim) | simulation |
[14](2020/day14/solution.nim) | implementation |
[13](2020/day13/solution.nim) | math, chinese remainder theorem | implement [crt](lib/maths.nim)
[12](2020/day12/solution.nim) | implementation | turning degrees are multiples of 90
[11](2020/day11/solution.nim) | simulation |
[10](2020/day10/solution.nim) | implementation, sort, counter, dp |
[9](2020/day9/solution.nim) | implementation, prefix sum, bisect |
[8](2020/day8/solution.nim) | simulation, brute force |
[7](2020/day7/solution.nim) | regex, graph, dfs |
[6](2020/day6/solution.nim) | implementation, set |
[5](2020/day5/solution.nim) | implementation |
[4](2020/day4/solution.nim) | implementation, regex |
[3](2020/day3/solution.nim) | implementation |
[2](2020/day2/solution.nim) | implementation |
[1](2020/day1/solution.nim) | two pointers |

## 2019

Day | Tags | Memo
--- | --- | ---
[25](2019/day25/solution.nim) | simulation, dfs, interactive, brute force | solve day 9 first; the map is a tree not a grid
[24](2019/day24/solution.nim) | simulation |
[23](2019/day23/solution.nim) | simulation | solve day 9 first
[22](2019/day22/solution.nim)* | matrix, modint, bigint | implement [matrix](lib/matrix.nim), [modint](lib/modBigint.nim)
[21](2019/day21/solution.nim)* | simulation, brute force | solve day 9 first; only needs an additional "H"; slow
[20](2019/day20/solution.nim) | parsing, bfs | labels are read either left-to-right or top-to-bottom; part2: compress states by building graph
[19](2019/day19/solution.nim) | simulation, brute force | solve day 9 first
[18](2019/day18/solution.nim)* | bfs, bitmask | part1: [same problem on leetcode](https://leetcode.com/problems/shortest-path-to-get-all-keys/); part2: compress states by skipping empty cells; slow
[17](2019/day17/solution.nim) | simulation, dfs, brute force, rle | solve day 9 first
[16](2019/day16/solution.nim)* | simulation, suffix sum | part2: the offset is guaranteed at second half
[15](2019/day15/solution.nim)* | simulation, backtracking, bfs | solve day 9 first; get a map first
[14](2019/day14/solution.nim) | graph, topological sorting, bisect |
[13](2019/day13/solution.nim) | simulation | solve day 9 first
[12](2019/day12/solution.nim) | simulation, period | part2: find peroid for each axis independently
[11](2019/day11/solution.nim) | simulation | solve day 9 first
[10](2019/day10/solution.nim) | math, simulation |
[9](2019/day9/solution.nim) | implementation | solve day 5 first
[8](2019/day8/solution.nim) | implementation |
[7](2019/day7/solution.nim) | simulation, permutation | solve day 5 first
[6](2019/day6/solution.nim) | tree, dfs |
[5](2019/day5/solution.nim) | simulation | solve day 2 first
[4](2019/day4/solution.nim) | brute force |
[3](2019/day3/solution.nim) | simulation, hash |
[2](2019/day2/solution.nim) | implementation, brute force |
[1](2019/day1/solution.nim) | implementation |

## 2018

Day | Tags | Memo
--- | --- | ---
[25](2018/day25/solution.nim) | disjoint set |
[24](2018/day24/solution.nim) | simulation | look out for draw states that would make combats unable to proceed 
[23](2018/day23/solution.nim)* | graph, clique, bisect | add a new bot at the origin, and find the shortest range of it that would make it into a largest clique
[22](2018/day22/solution.nim) | implementation, bfs |
[21](2018/day21/solution.nim) | reverse engineering, period | solve day 19 first
[20](2018/day20/solution.nim)* | dfs, bfs | regex implementation
[19](2018/day19/solution.nim) | simulation, reverse engineering | sum of divisors
[18](2018/day18/solution.nim) | simulation, grid, period |
[17](2018/day17/solution.nim)* | simulation, dfs |
[16](2018/day16/solution.nim) | backtracking, simulation |
[15](2018/day15/solution.nim)* | simulation, bfs | if a unit could not find a living oppenent in its turn, the round is incomplete and not counted for
[14](2018/day14/solution.nim) | simulation |
[13](2018/day13/solution.nim) | simulation |
[12](2018/day12/solution.nim) | simulation, period |
[11](2018/day11/solution.nim) | implementation, grid, integral image, brute force |
[10](2018/day10/solution.nim) | simulation | run simulation until the bounding box of points is small enough
[9](2018/day9/solution.nim) | simulation, linked list |
[8](2018/day8/solution.nim) | dfs |
[7](2018/day7/solution.nim) | graph, topological sorting, priority queue |
[6](2018/day6/solution.nim) | grid, flood fill |
[5](2018/day5/solution.nim) | string, simulation, stack, brute force |
[4](2018/day4/solution.nim) | implementation |
[3](2018/day3/solution.nim) | grid | implement [Imos](lib/imos.nim)
[2](2018/day2/solution.nim) | implementation, string |
[1](2018/day1/solution.nim) | implementation, hash |

## 2017

Day | Tags | Memo
--- | --- | ---
[25](2017/day25/solution.nim) | simulation, parsing |
[24](2017/day24/solution.nim) | dfs |
[23](2017/day23/solution.nim) | simulation, reverse engineering | part2: check prime
[22](2017/day22/solution.nim) | simulation, hash |
[21](2017/day21/solution.nim) | simulation | [Glider](https://conwaylife.com/wiki/Glider)
[20](2017/day20/solution.nim) | simulation, math | part2: settles under 50 secs
[19](2017/day19/solution.nim) | simulation |
[18](2017/day18/solution.nim) | simulation, coroutine |
[17](2017/day17/solution.nim) | simulation |
[16](2017/day16/solution.nim) | simulation, period |
[15](2017/day15/solution.nim) | implementation, brute force |
[14](2017/day14/solution.nim) | implementation, flood fill | solve day 10 first
[13](2017/day13/solution.nim) | math, brute force | similar to 2016 day 15
[12](2017/day12/solution.nim) | graph, disjoint set | implement [Disjoint-set/Union-find](lib/dsu.nim)
[11](2017/day11/solution.nim) | math | [Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/)
[10](2017/day10/solution.nim) | string, implementation |
[9](2017/day9/solution.nim) | string, parsing |
[8](2017/day8/solution.nim) | simulation |
[7](2017/day7/solution.nim) | graph, dfs | nodes with two subtrees are always balanced
[6](2017/day6/solution.nim) | simulation, hash |
[5](2017/day5/solution.nim) | simulation |
[4](2017/day4/solution.nim) | string, implementation |
[3](2017/day3/solution.nim) | math, simulation |
[2](2017/day2/solution.nim) | implementation, brute force |
[1](2017/day1/solution.nim) | string, implementation |

## 2016

Day | Tags | Memo
--- | --- | ---
[25](2016/day25/solution.nim) | simulation, vm, brute force, reverse engineering | integer in binary: [reverse engineered](2016/day25/solution1.nim)
[24](2016/day24/solution.nim) | grid, bfs |
[23](2016/day23/solution.nim) | simulation, vm, reverse engineering | part2: factorial
[22](2016/day22/solution.nim)* | grid, bfs | part2: move only the empty node and the target node
[21](2016/day21/solution.nim) | string, simulation, brute force, permutation |
[20](2016/day20/solution.nim) | simulation |
[19](2016/day19/solution.nim) | math, simulation | implement [OrderedList](lib/llrb.nim)
[18](2016/day18/solution.nim) | string, implementation |
[17](2016/day17/solution.nim) | bfs, brute force |
[16](2016/day16/solution.nim) | string, implementation |
[15](2016/day15/solution.nim) | math, brute force |
[14](2016/day14/solution.nim) | string, sliding window |
[13](2016/day13/solution.nim) | bfs |
[12](2016/day12/solution.nim) | simulation, vm, reverse engineering | [reverse engineered](2016/day12/solution1.nim)
[11](2016/day11/solution.nim)* | bfs | items with same types are equivalent, count number of items for each type only
[10](2016/day10/solution.nim) | simulation |
[9](2016/day9/solution.nim) | string, simulation, dfs |
[8](2016/day8/solution.nim) | simulation, grid |
[7](2016/day7/solution.nim) | string, implementation |
[6](2016/day6/solution.nim) | implementation |
[5](2016/day5/solution.nim) | brute force, implementation |
[4](2016/day4/solution.nim) | implementation |
[3](2016/day3/solution.nim) | math |
[2](2016/day2/solution.nim) | simulation |
[1](2016/day1/solution.nim) | simulation |

## 2015

Day | Tags | Memo
--- | --- | ---
[25](2015/day25/solution.nim) | math, fastExp |
[24](2015/day24/solution.nim) | brute force, dfs |
[23](2015/day23/solution.nim) | simulation, vm, reverse engineering | [Collatz conjecture](https://en.wikipedia.org/wiki/Collatz_conjecture)
[22](2015/day22/solution.nim) | simulation, bfs |
[21](2015/day21/solution.nim) | brute force, math |
[20](2015/day20/solution.nim) | math |
[19](2015/day19/solution.nim)* | dfs | part2: reduce target string from back to front using reversed rules
[18](2015/day18/solution.nim) | simulation, grid |
[17](2015/day17/solution.nim) | brute force, bitops |
[16](2015/day16/solution.nim) | brute force |
[15](2015/day15/solution.nim) | dfs, brute force |
[14](2015/day14/solution.nim) | math, simulation |
[13](2015/day13/solution.nim) | brute force, permutation |
[12](2015/day12/solution.nim) | dfs |
[11](2015/day11/solution.nim) | string, brute force |
[10](2015/day10/solution.nim) | simulation |
[9](2015/day9/solution.nim) | graph, brute force, permutation |
[8](2015/day8/solution.nim) | string |
[7](2015/day7/solution.nim) | dfs, memoization |
[6](2015/day6/solution.nim) | simulation, grid |
[5](2015/day5/solution.nim) | string, regex |
[4](2015/day4/solution.nim) | brute force, implementation |
[3](2015/day3/solution.nim) | simulation |
[2](2015/day2/solution.nim) | math |
[1](2015/day1/solution.nim) | stack |
