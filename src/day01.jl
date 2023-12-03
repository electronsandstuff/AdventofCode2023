module Day01

# Big dict of digits and their corresponding numbers
const digit_names = Dict{String,Int64}(
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9
)

# Find first or last digit in a string including by name (with part2 switch)
function finddigit(s, first=true, part2=false)
    for i in (first ? (1:lastindex(s)) : (lastindex(s):-1:1))
        isdigit(s[i]) && return parse(Int64, s[i])
        for (d, v) in pairs(digit_names)
            startswith(s[i:end], d) && part2 && return v
        end
    end
    return 0
end

# Get first and last digits, turn into number; sum over the lines
linetonum(s, part2) = 10*finddigit(s, true, part2) + finddigit(s, false, part2)
linessum(s, part2) = sum(linetonum(l, part2) for l in eachline(IOBuffer(s)))

# Final solution
function day01(input::String = readInput(joinpath(@__DIR__, "data", "day01.txt")))
    [linessum(input, false), linessum(input, true)]
end

end
