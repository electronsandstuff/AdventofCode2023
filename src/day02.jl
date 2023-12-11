module Day02

# Turn list of colors and numbers into dict
subgame_to_dict(s) = Dict{String, Int64}((x = split(strip(color), ' '))[2] => parse(Int64, x[1]) for color in split(s, ','))

# Check if game exceeds ball count
subgame_is_valid(sg, maxes) = all(get(maxes, k, 0) >= v for (k, v) in pairs(sg))

# Check if a whole game is valid
game_is_valid(g, maxes) = all(subgame_is_valid(subgame_to_dict(sg), maxes) for sg in split(g, ';'))

# Turn the whole line into the number to sum (id if valid, zero if not)
function line_to_count1(l, maxes)
    m = match(r".*Game (\d*): (.*)", l)
    m === nothing && return 0
    game_is_valid(m.captures[2], maxes) ? parse(Int64, m.captures[1]) : 0
end

# Merge two dicts of colors together for minimal bag counts
bag_max_reduce(a, b) = Dict(k => max(get(a, k, 0), get(b, k, 0)) for k in union(keys(a), keys(b)))

# Gets minimum bag counts
get_min_bag(g) = reduce(bag_max_reduce, [subgame_to_dict(sg) for sg in split(g, ';')],  init=Dict{String, Int64}())

# Calculate the "power"
bag_power(b) = prod(values(b))

function line_to_count2(l)
    m = match(r".*Game (\d*): (.*)", l)
    m === nothing && return 0
    bag_power(get_min_bag(m.captures[2]))
end

# The ball count limits (pt. 1)
subgame_maxes = Dict{String, Int64}("red" => 12, "green" => 13, "blue" => 14)

# Final solution
function day02(input::String = readInput(joinpath(@__DIR__, "data", "day02.txt")))
    [
        sum(line_to_count1(l, subgame_maxes) for l in split(input, '\n')),
        sum(line_to_count2(l) for l in split(input, '\n')),
    ]
end

end