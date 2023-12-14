module AdventofCode2023
# From goggle on github

using BenchmarkTools
using Printf

solvedDays = 1:8
# Include the source files:
for day in solvedDays
    ds = @sprintf("%02d", day)
    include(joinpath(@__DIR__, "day$ds.jl"))
end

# Read the input from a file:
function readInput(path::String)
    s = open(path, "r") do file
        read(file, String)
    end
    return s
end

function readInput(day::Integer)
    path = joinpath(@__DIR__, "..", "data", @sprintf("day%02d.txt", day))
    return readInput(path)
end
export readInputpr

# Export a function `dayXY` for each day:
for d in solvedDays
    global ds = @sprintf("day%02d.txt", d)
    global modSymbol = Symbol(@sprintf("Day%02d", d))
    global dsSymbol = Symbol(@sprintf("day%02d", d))

    @eval begin
        input_path = joinpath(@__DIR__, "..", "data", ds)
        function $dsSymbol(input::String = readInput($d))
            return AdventofCode2023.$modSymbol.$dsSymbol(input)
        end
        export $dsSymbol
    end
end

# Benchmark a list of different problems:
function benchmark(days=solvedDays)
    results = []
    for day in days
        modSymbol = Symbol(@sprintf("Day%02d", day))
        fSymbol = Symbol(@sprintf("day%02d", day))
        input = readInput(joinpath(@__DIR__, "..", "data", @sprintf("day%02d.txt", day)))
        @eval begin
            bresult = @benchmark(AdventofCode2023.$modSymbol.$fSymbol($input))
        end
        push!(results, (day, time(bresult), memory(bresult)))
    end
    return results
end

# Write the benchmark results into a markdown string:
function _to_markdown_table(bresults)
    header = "| Day | Problem | Time | Allocated memory | Solution |\n" *
             "|----:|:-------:|-----:|-----------------:|:-----------:|"
    lines = [header]
    for (d, t, m) in bresults
        ds = string(d)
        ps = "[:white_check_mark:](https://adventofcode.com/2023/day/$d)"
        ts = BenchmarkTools.prettytime(t)
        ms = BenchmarkTools.prettymemory(m)
        ss = @sprintf("[:white_check_mark:](https://github.com/electronsandstuff/AdventofCode2023/blob/main/src/day%02d.jl)", d)
        push!(lines, "| $ds | $ps | $ts | $ms | $ss |")
    end
    return join(lines, "\n")
end

# Utility function to decode images:
function generate_image(image)
    block = '\u2588'
    empty = ' '
    output = ""
    for i = 1:size(image, 2)
        row = join(image[:, i])
        row = replace(row, "#" => block)
        row = replace(row, "." => empty)
        output *= row * "\n"
    end
    return output
end
export generate_image

aoc_benchmark(days=solvedDays) = print(_to_markdown_table(benchmark(days)))
aoc_benchmark_today() = aoc_benchmark([solvedDays[end]])
export aoc_benchmark, aoc_benchmark_today

end # module AdventofCode2023
