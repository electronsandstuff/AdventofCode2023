module Day14

# Load input into matrix
parse_input(s) = permutedims(hcat([collect(collect(strip(l))) for l in split(s, '\n') if length(l) > 1]...))

# Shift rocks in a single vector
function shift_rocks_up!(v)
    for i in 1:lastindex(v)
        if v[i] == 'O'
            first_rock = findfirst(==('#'), v[i:-1:1])
            first_rock = isnothing(first_rock) ? 0 : i - first_rock + 1
            first_empty = findfirst(==('.'), v[(1 + first_rock):i])
            if !isnothing(first_empty)
                v[i] = '.'
                v[first_empty + first_rock] = 'O'
            end
        end
    end
end

function shift_rocks_down!(v)
    for i in lastindex(v):-1:1
        if v[i] == 'O'
            first_rock = findfirst(==('#'), v[i:end])
            first_rock = isnothing(first_rock) ? length(v) + 1 : i + first_rock - 1
            first_empty = findfirst(==('.'), v[(first_rock-1):-1:i])
            if !isnothing(first_empty)
                v[i] = '.'
                v[first_rock - first_empty ] = 'O'
            end
        end
    end
end

function get_north_load(rocks)
    rocks = copy(rocks)
    shift_rocks_up!.(eachcol(rocks))
    sum(sum(rocks .== 'O'; dims=2) .* collect(size(rocks)[1]:-1:1))
end

function cycle!(rocks)
    shift_rocks_up!.(eachcol(rocks))
    shift_rocks_up!.(eachrow(rocks))
    shift_rocks_down!.(eachcol(rocks))
    shift_rocks_down!.(eachrow(rocks))
end

function get_north_load_cycles(rocks, n_cycle)
    rocks = copy(rocks)
    seen = Dict{Matrix{Char}, Int}()
    cycle = 0
    jumped = false
    while cycle < n_cycle
        cycle!(rocks)
        cycle += 1
        if !jumped && rocks in keys(seen)
            cycle = n_cycle - ((n_cycle - seen[rocks]) % (cycle - seen[rocks]))
            jumped = true
        else
            seen[copy(rocks)] = cycle
        end
    end
    sum(sum(rocks .== 'O'; dims=2) .* collect(size(rocks)[1]:-1:1))
end

function day14(input::String = readInput(joinpath(@__DIR__, "data", "day14.txt")))
    rocks = parse_input(input)
    [get_north_load(rocks), get_north_load_cycles(rocks, 1000000000)]
end

end
