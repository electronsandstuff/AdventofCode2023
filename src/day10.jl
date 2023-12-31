module Day10

# Loads a character matrix from input
parse_input(s) = permutedims(hcat([collect(strip(x)) for x in split(s, '\n') if length(x) > 1]...))

# Define pipe connectivity. Gives a Dict from the pipe characters to the relative indices they connect to
north_idx = [-1, 0]
south_idx = [1, 0]
east_idx = [0, 1]
west_idx = [0, -1]
connectivity_dict = Dict{Char, Set{Vector{Int64}}}(
    '|' => Set((north_idx, south_idx)),
    '-' => Set((east_idx, west_idx)),
    'L' => Set((north_idx, east_idx)),
    'J' => Set((north_idx, west_idx)),
    '7' => Set((south_idx, west_idx)),
    'F' => Set((east_idx, south_idx)),
    '.' => Set(),
    'S' => Set((north_idx, south_idx, east_idx, west_idx)),
)

# Query the pipe character's connectivity from the dict
connectivity(tile::Char) = connectivity_dict[tile]

# Given the matrix of characters "tiles" is the location a connected to location b?
connected(tiles, a, b) = ((a - b) ∈ connectivity(tiles[b...])) && ((b - a) ∈ connectivity(tiles[a...]))

# Check if the index is inbounds for the matrix of tiles
inbounds(tiles, idx) = (1 <= idx[1] <= size(tiles)[1]) && (1 <= idx[2] <= size(tiles)[2])

# Finds the loop of pipes by repeatedly looking around for "unseen" pipes near the current head. Starts at the given character.
# Returns the set of seen pipe locations
function get_loop(tiles, start_char='S')
    current_idx = collect(Tuple(findfirst(==(start_char), tiles)))
    seen = Set{Vector{Int64}}((current_idx,))
    moved = true
    while moved
        moved = false
        for dir in connectivity_dict[tiles[current_idx...]]
            inbounds(tiles, current_idx + dir) || continue
            if connected(tiles, current_idx, current_idx + dir) && (current_idx + dir) ∉ seen
                current_idx = current_idx + dir
                push!(seen, current_idx)
                moved = true
                break
            end
        end
    end
    seen
end

# Given the tile matrix and the loop of pipes, fill in all of the "pixels" inside the loop by scanning every pixel and keeping
# track of when we cross into and out of the loop
function fill_loop(tiles, loop, start_char='S')
    # Calculate if S serves the purpose of a horizontal element
    s_idx = collect(Tuple(findfirst(==(start_char), tiles)))
    s_horz = (inbounds(tiles, s_idx + [0, -1]) && (s_idx + [0, -1]) ∈ loop) && (inbounds(tiles, s_idx + [0, 1]) && (s_idx + [0, 1]) ∈ loop)
    s_horz = s_horz || ((inbounds(tiles, s_idx + [0, -1]) && (s_idx + [0, -1]) ∈ loop) && (inbounds(tiles, s_idx + [1, 0]) && (s_idx + [1, 0]) ∈ loop))
    s_horz = s_horz || ((inbounds(tiles, s_idx + [0, -1]) && (s_idx + [0, -1]) ∈ loop) && (inbounds(tiles, s_idx + [-1, 0]) && (s_idx + [-1, 0]) ∈ loop))

    # Fill the interior points
    filled = zeros(Bool, size(tiles))
    cur = false
    for j = 1:size(filled, 2)
        for i = 1:size(filled, 1)
            if [i, j] ∈ loop
                ((tiles[i, j] ∈ "7J-") || (tiles[i, j] == 'S' && s_horz)) &&  (cur = !cur)
            else
                filled[i, j] = cur
            end
        end
    end
    filled
end

function day10(input::String = readInput(joinpath(@__DIR__, "data", "day10.txt")))
    tiles = parse_input(input)
    loop = get_loop(tiles)
    filled = fill_loop(tiles, loop)
    [Int64(ceil(length(loop)/2)), sum(filled)]
end

end