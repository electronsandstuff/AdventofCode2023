module Day16

# Define indices for directions
const direction_left = 1
const direction_right = 2
const direction_up = 3
const direction_down = 4

# Represents the laser at a single point (has a location and direction)
struct Point
    idx::Tuple{Int64, Int64}
    dir::Int64
end

# Move laser around the grid using flood fill style algorithm. Returns an array representing four maps of the layout with whether or not there is a laser
# beam moving in the up, down, left, or right direction in it. The first two indices are the spatial indices and the last represents the direction according
# to the definitions above
function laser_fill(layout, starting_point=Point((1, 1), direction_right))
    queue = Vector{Point}([starting_point])
    lr = zeros(Bool, size(layout)..., 4)

    while length(queue) > 0
        p = pop!(queue)

        # If we've seen this point already, move on (avoid loops)
        lr[p.idx..., p.dir] && continue

        # Mark that we've seen this point
        lr[p.idx..., p.dir] = true

        # Add in the neighbors to this point to the queue
        if layout[p.idx...] == '.'  # Free space propagation
            p.dir == direction_down && p.idx[1] < size(layout)[1] && push!(queue, Point((p.idx[1]+1, p.idx[2]), p.dir))
            p.dir == direction_up && p.idx[1] > 1 && push!(queue, Point((p.idx[1]-1, p.idx[2]), p.dir))
            p.dir == direction_right && p.idx[2] < size(layout)[2] && push!(queue, Point((p.idx[1], p.idx[2]+1), p.dir))
            p.dir == direction_left && p.idx[2] > 1 && push!(queue, Point((p.idx[1], p.idx[2]-1), p.dir))
        elseif layout[p.idx...] == '-'  # Beam splitter one
            (p.dir == direction_down || p.dir == direction_up) && p.idx[2] < size(layout)[2] && push!(queue, Point((p.idx[1], p.idx[2]+1), direction_right))
            (p.dir == direction_down || p.dir == direction_up) && p.idx[2] > 1 && push!(queue, Point((p.idx[1], p.idx[2]-1), direction_left))
            p.dir == direction_right && p.idx[2] < size(layout)[2] && push!(queue, Point((p.idx[1], p.idx[2]+1), p.dir))
            p.dir == direction_left && p.idx[2] > 1 && push!(queue, Point((p.idx[1], p.idx[2]-1), p.dir))
        elseif layout[p.idx...] == '|' # Beam splitter two
            p.dir == direction_down && p.idx[1] < size(layout)[1] && push!(queue, Point((p.idx[1]+1, p.idx[2]), p.dir))
            p.dir == direction_up && p.idx[1] > 1 && p.idx[1] > 1 &&push!(queue, Point((p.idx[1]-1, p.idx[2]), p.dir))
            (p.dir == direction_right || p.dir == direction_left) && p.idx[1] < size(layout)[1] && push!(queue, Point((p.idx[1]+1, p.idx[2]), direction_down))
            (p.dir == direction_right || p.dir == direction_left) && p.idx[1] > 1 && push!(queue, Point((p.idx[1]-1, p.idx[2]), direction_up))
        elseif layout[p.idx...] == '/'  # Mirror one
            p.dir == direction_down && p.idx[2] > 1 && push!(queue, Point((p.idx[1], p.idx[2] - 1), direction_left))
            p.dir == direction_up && p.idx[2] < size(layout)[2] && push!(queue, Point((p.idx[1], p.idx[2]+1), direction_right))
            p.dir == direction_right && p.idx[1] > 1 && push!(queue, Point((p.idx[1]-1, p.idx[2]), direction_up))
            p.dir == direction_left && p.idx[1] < size(layout)[1] && push!(queue, Point((p.idx[1]+1, p.idx[2]), direction_down))
        elseif layout[p.idx...] == '\\'  # Mirror two
            p.dir == direction_up && p.idx[2] > 1 && push!(queue, Point((p.idx[1], p.idx[2] - 1), direction_left))
            p.dir == direction_down && p.idx[2] < size(layout)[2] && push!(queue, Point((p.idx[1], p.idx[2]+1), direction_right))
            p.dir == direction_left && p.idx[1] > 1 && push!(queue, Point((p.idx[1]-1, p.idx[2]), direction_up))
            p.dir == direction_right && p.idx[1] < size(layout)[1] && push!(queue, Point((p.idx[1]+1, p.idx[2]), direction_down))
        end
    end
    lr
end

# Count the number of energized squares
lr_to_energized(lr) = any(lr, dims=3)
num_energized(lr) = sum(lr_to_energized(lr))

# Iterate over every starting point along the edges (and starting directions) and get the max points we saw energized
function max_energized(layout)
    a = maximum(num_energized(laser_fill(layout, Point((i, 1), direction_right))) for i in 1:size(layout)[1])
    b = maximum(num_energized(laser_fill(layout, Point((i, size(layout)[2]), direction_left))) for i in 1:size(layout)[1])
    c = maximum(num_energized(laser_fill(layout, Point((1, i), direction_down))) for i in 1:size(layout)[2])
    d = maximum(num_energized(laser_fill(layout, Point((size(layout)[1], i), direction_up))) for i in 1:size(layout)[2])
    max(a, b, c, d)
end

function day16(input::String = readInput(joinpath(@__DIR__, "data", "day16.txt")))
    # Get the layout of elements
    layout = permutedims(hcat(collect.(filter(x->length(x)>0, strip.(split(input, '\n'))))...))
    [num_energized(laser_fill(layout)), max_energized(layout)]
end

end
