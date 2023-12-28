module Day22

# Brick object (with "a" standardized on having the smaller coordinate)
struct Brick
    a::Tuple{Int64, Int64, Int64}
    b::Tuple{Int64, Int64, Int64}
end

# Load a brick object from a string
function Brick(s::AbstractString)
    m = match(r"(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)", s)
    isnothing(m) && return DomainError(s, "cannot parse string into Brick")
    a = (parse(Int64, m.captures[1]), parse(Int64, m.captures[2]), parse(Int64, m.captures[3])) 
    b = (parse(Int64, m.captures[4]), parse(Int64, m.captures[5]), parse(Int64, m.captures[6]))
    Brick(min.(a, b), max.(a, b))
end

# Get all xy coordinate pairs this brick covers
function xy_coords(b::Brick)
    b.a[1] != b.b[1] && return collect(zip(b.a[1]:b.b[1], fill(b.a[2], length(b.a[1]:b.b[1]))))
    b.a[2] != b.b[2] && return collect(zip(fill(b.a[1], length(b.a[2]:b.b[2])), b.a[2]:b.b[2]))
    [(b.a[1], b.a[2])]
end

# Returns a brick shifted along z by dz
shift_z(b::Brick, dz) = Brick((b.a[1], b.a[2], b.a[3]+dz), (b.b[1], b.b[2], b.b[3]+dz))

# Parse the list of bricks in the input file
parse_input(s) = Brick.(filter(x->length(x)>0, strip.(split(s, '\n'))))

# Get the graph of the bricks each brick supports (by index; 0 is "ground brick")
function get_supporting_bricks(bricks)
    # Sort to drop lowest z first
    idx = sortperm(bricks, by=x->x.a[3])
    bricks = bricks[idx]
    brick_idx = (1:length(bricks))[idx]

    # Setup some objects to maintain the graph of supporting bricks and the highest so far
    max_z = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()
    supporting_bricks = Dict{Int64, Set{Int64}}(i => Set{Int64}() for i in 0:length(bricks))

    # Drop the bricks in order
    for (idx, b) in enumerate(bricks)
        # Get the bricks which support us
        coords = xy_coords(b)
        our_max_z = [get(max_z, c, (0, 0)) for c in coords]
        m = maximum(x[2] for x in our_max_z)
        for sb in filter(x->x[2] == m, our_max_z)
            push!(supporting_bricks[sb[1]],  brick_idx[idx])
        end
        
        # Add ourself to the max coords
        for c in coords
            max_z[c] = (brick_idx[idx],  b.b[3] + m - b.a[3] + 1)
        end
    end
    supporting_bricks
end

function flip_graph(g)
    # Flip graph repesentation to get which bricks support the brick that is the key
    g2 = Dict{Int64, Set{Int64}}(i => Set{Int64}() for i in 0:(length(g)-1))
    for (k, vs) in pairs(g)
        for v in vs
            push!(g2[v], k)
        end
    end
    g2
end

# Count number of bricks we can disintegrate w/o another falling
function count_ok_disintegrations(g1)
    g2 = flip_graph(g1)
    sum(length(g1[idx]) == 0 || all(length(g2[x]) > 1 for x in g1[idx]) for idx in keys(g1))
end

# Count number of bricks that will fall by counting which ones connect to ground if we remove one
function count_falling_bricks(g1, remove_idx)
    q = Vector{Int64}()
    seen = Set{Int64}()
    push!(q, 0)
    acc = -1  # -1 to not count "ground brick"

    while length(q) > 0
        idx = popfirst!(q)
        idx ∈ seen && continue
        for v in g1[idx]
            v != remove_idx && v ∉ seen && push!(q, v)
        end
        acc += 1
        push!(seen, idx)
    end
    length(g1) - acc - 2  # Account for "ground brick" and the one we removed
end

function day22(input::String = readInput(joinpath(@__DIR__, "data", "day22.txt")))
   bricks = parse_input(input)
   g = get_supporting_bricks(bricks)
   [count_ok_disintegrations(g), sum(count_falling_bricks(g, i) for i in 1:(length(g)-1))]
end

end
