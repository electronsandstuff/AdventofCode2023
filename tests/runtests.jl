using Revise
using AdventofCode2023
using Test

@testset begin
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
end
