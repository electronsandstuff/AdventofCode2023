module Day09

parse_input(s) = [[parse(Int64, x) for x in split(strip(l))] for l in split(s, '\n')]

function extrapolate(x)
    forward = 0
    backward = 0
    sign = 1
    while any(x .!= 0)
        backward += sign * x[1]
        forward += x[end]
        x = diff(x)
        sign = sign * -1
    end
    [forward, backward]
end

function day09(input::String = readInput(joinpath(@__DIR__, "data", "day09.txt")))
    seqs = parse_input(input)
    sum(extrapolate(x) for x in seqs)
end

end