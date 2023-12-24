using Revise
using AdventofCode2023
using Test


@test day01("1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet")[1] == 142

@test day01("two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen")[2] == 281

@test day02("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green") == [8, 2286]

@test day03(raw"467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..") == [4361, 467835]


@test day04("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11") == [13, 30]

@test day05("seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4") == [35, 46]

@test day06("Time:      7  15   30
Distance:  9  40  200") == [288, 71503]

@test day07("32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483") == [6440, 5905]

@test day08("RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)")[1] == 2

@test day08("LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)")[1] == 6

@test day08("LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)")[2] == 6

@test day09("0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45") == [114, 2]

@test day10(".....
.S-7.
.|.|.
.L-J.
.....
")[1] == 4


@test day10(".....
.S-7.
.|.|.
.L-J.
.....
")[1] == 4

@test day10("..F7.
.FJ|.
SJ.L7
|F--J
LJ...
")[1] == 8

@test day10("
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
")[2] == 1

@test day10(".....
.S-7.
.|.|.
.L-J.
.....
")[2] == 1


@test day11("...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....")[1] == 374

@test AdventofCode2023.Day11.day11("...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....", 10)[2] == 1030

@test AdventofCode2023.Day11.day11("...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....", 100)[2] == 8410

@test day12("???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1") == [21, 525152]

@test day13("#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#") == [405, 400]

@test day14("O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....") == [136, 64]

@test AdventofCode2023.Day15.aoc_hash("HASH") == 52

@test day15("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7") == [1320, 145]

@test day16(raw".|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....") == [46, 51]

@test day17("2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533") == [102, 94]

@test day17("111111111111
999999999991
999999999991
999999999991
999999999991")[2] == 71