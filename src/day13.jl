module Day13

# Find locations of reflections in a vector
function is_reflection(v::AbstractVector, i::Int64)
    for j in 1:min(length(v) - i, i)
        v[i + j] == v[i - j + 1] || return false
    end
    true
end
function is_smudged_reflection(v::AbstractVector, i::Int64)
    err = 0
    for j in 1:min(length(v) - i, i)
        err += sum(v[i + j] .!= v[i - j + 1])
        err > 1 && return false
    end
    err == 1
end
find_reflection(v::AbstractVector, reflection_fn=is_reflection) = findfirst(i->reflection_fn(v, i), 1:(length(v)-1))

# Pull matrix from string
ele_to_bool(c) = (c == '#')
str_to_mat(s) = permutedims(hcat([ele_to_bool.(collect(strip(l))) for l in split(s, '\n') if length(l) > 1]...))

# Load data from file
function parse_input(s)
    ret = Vector{Matrix{Bool}}()
    idx = 1
    while true
        m = match(r"([#.\r?\n\w]+?)(?:(?:\r?\n\w*\r?\n)|\z|(?:\r?\n\z))", s, idx)
        isnothing(m) && break
        idx = m.offset + length(m.match)
        push!(ret, str_to_mat(m.captures[1]))
    end
    ret
end

# Score the maps
function score_map(m, reflection_fn=is_reflection)
    col = find_reflection(eachcol(m), reflection_fn)
    !isnothing(col) && return col
    return 100*find_reflection(eachrow(m), reflection_fn)
end

function day13(input::String = readInput(joinpath(@__DIR__, "data", "day13.txt")))
    maps = parse_input(input)
    [sum(score_map.(maps)), sum(score_map.(maps, is_smudged_reflection))]
end

end