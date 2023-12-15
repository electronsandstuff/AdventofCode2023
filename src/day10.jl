module Day10

parse_input(s) = permutedims(hcat([collect(strip(x)) for x in split(s, '\n') if length(x) > 1]...))

# Define pipe connectivity
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
connectivity(tile::Char) = connectivity_dict[tile]
connected(tiles, a, b) = ((a - b) ∈ connectivity(tiles[b...])) && ((b - a) ∈ connectivity(tiles[a...]))

inbounds(tiles, idx) = (1 <= idx[1] <= size(tiles)[1]) && (1 <= idx[2] <= size(tiles)[2])
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