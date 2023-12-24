module Day17

import DataStructures

# Read in the matrix from input
parse_input(s) = permutedims(parse.(Int64, hcat(collect.(filter(x->length(x)>0, strip.(split(s, '\n'))))...)))

# Define indices for directions
const direction_left = 1
const direction_right = 2
const direction_up = 3
const direction_down = 4
const direction_start = 5

# Struct for nodes in graph for Dijkstra's algorithm
struct AOCNode
    idx::Tuple{Int64, Int64}
    dir::Int64
    straight_dist::Int64
end

# Find all neighbors of this node and the costs (this is a mess... might return to clean up later, but  am too tired)
function neighbors(heatloss, node, min_straight=1, max_straight=3)
    ret = Vector{Tuple{AOCNode, Int64}}()
    (node.dir != direction_down) && (node.dir != direction_up || node.straight_dist < max_straight) && (node.dir == direction_up || node.dir == direction_start || node.straight_dist >= min_straight) && node.idx[1] > 1 && push!(ret, (AOCNode((node.idx[1]-1, node.idx[2]), direction_up, (node.dir == direction_up || node.dir == direction_start) ? node.straight_dist + 1 : 1), heatloss[node.idx[1]-1, node.idx[2]]))
    (node.dir != direction_up) && (node.dir != direction_down || node.straight_dist < max_straight) && (node.dir == direction_down || node.dir == direction_start || node.straight_dist >= min_straight) && node.idx[1] < size(heatloss)[1] && push!(ret, (AOCNode((node.idx[1]+1, node.idx[2]), direction_down, (node.dir == direction_down || node.dir == direction_start) ? node.straight_dist + 1 : 1), heatloss[node.idx[1]+1, node.idx[2]]))
    (node.dir != direction_right) && (node.dir != direction_left || node.straight_dist < max_straight) && (node.dir == direction_left || node.dir == direction_start || node.straight_dist >= min_straight) && node.idx[2] > 1 && push!(ret, (AOCNode((node.idx[1], node.idx[2]-1), direction_left, (node.dir == direction_left || node.dir == direction_start) ? node.straight_dist + 1 : 1), heatloss[node.idx[1], node.idx[2]-1]))
    (node.dir != direction_left) && (node.dir != direction_right || node.straight_dist < max_straight) && (node.dir == direction_right || node.dir == direction_start || node.straight_dist >= min_straight) && node.idx[2] < size(heatloss)[2] && push!(ret, (AOCNode((node.idx[1], node.idx[2]+1), direction_right, (node.dir == direction_right || node.dir == direction_start) ? node.straight_dist + 1 : 1), heatloss[node.idx[1], node.idx[2]+1]))
    ret
end

# Traverse possible moves to find minimum path w/ Dijkstra
function min_distance(heatloss, start_point, end_point, min_straight=1, max_straight=3)
    # Set up some datastructures
    seen = Set{AOCNode}()
    dist = Dict{AOCNode, Int64}(AOCNode(start_point, direction_start, 1) => 0)
    prev = Dict{AOCNode, AOCNode}()
    q = DataStructures.PriorityQueue{AOCNode, Int64}()
    DataStructures.enqueue!(q, AOCNode(start_point, direction_start, 1), 0)

    while length(q) > 0
        # Get the least distance state
        this_point = DataStructures.dequeue!(q)

        # Return the final distance if we made it (and the path)
        if (this_point.idx == end_point) && (this_point.straight_dist >= min_straight)
            path = [this_point]
            while path[end] in keys(prev)
                push!(path, prev[path[end]])
            end
            return dist[this_point], path
        end

        # Continue if seen this node already
        this_point ∈ seen && continue

        # Test each neighboring node
        for (node, cost) in neighbors(heatloss, this_point, min_straight, max_straight)
            alt = dist[this_point] + cost
            if alt < get(dist, node, alt+1)
                dist[node] = alt
                prev[node] = this_point
                DataStructures.enqueue!(q, node, alt)
            end
        end
        
        # We've seen this node
        push!(seen, this_point)
    end
end

# Make a matrix of the traversed path for debugging
function path_to_mat(heatloss, path)
    ret = zeros(Bool, size(heatloss)...)
    for p in path
        ret[p.idx...] = 1
    end
    ret
end

function day17(input::String = readInput(joinpath(@__DIR__, "data", "day17.txt")))
    heatloss = parse_input(input)
    # display(path_to_mat(heatloss, min_distance(heatloss, (1, 1), size(heatloss), 4, 10)[2]))
    [min_distance(heatloss, (1, 1), size(heatloss))[1], min_distance(heatloss, (1, 1), size(heatloss), 4, 10)[1]]
end

end
