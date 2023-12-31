module Day09

# Load the list of sequences
parse_input(s) = [[parse(Int64, x) for x in split(strip(l))] for l in split(s, '\n')]

# Extrapolate the sequence (vector of ints) forwards and backwards at the same time. Do this by taking the difference of
# successive elements repeatedly until the differences are zero. The first and last values of these successive difference can be
# summed (being careful to alternate +/- for each new row for the bakwards direction) to get the next values. This corresponds to
# summing the leftmost and rightmost edge of the "pyramid" of difference values in the diagram at https://adventofcode.com/2023/day/9
# to get the next terms
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
    sum(extrapolate(x) for x in seqs) # Sums the vectors of forward/backward to end up with a final 2 element vector of the sums of extrapolated values
end

end