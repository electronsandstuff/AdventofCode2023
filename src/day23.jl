module Day23

# Load the graph from input
parse_input(s) = permutedims(hcat(collect.(filter(x->length(x)>0, strip.(split(s, '\n'))))...))

# Construct graph of junctions from the map. Graph is returned as a dict where each key contains a vector of 
# tuples of the junctions that can reach this one and the weight of that edge. Also gives the mapping of vertex
# labels with the junction's coordinates for debugging
function map_to_graph(m, use_slopes=false)
    # Find start and end positions
    start_idx = (1, findfirst(==('.'), m[1, 1:end]))
    end_idx = (size(m, 1), findfirst(==('.'), m[end, 1:end]))

    # Start traversing all paths marked by '.' state is (current point, last junction, distance from last junction)
    q = Vector{Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}, Int64}}()
    push!(q, ((start_idx[1]+1, start_idx[2]), start_idx, 1))
    seen = Set{Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}()
    push!(seen, (start_idx, start_idx))
    ret = Dict{Int64, Vector{Tuple{Int64, Int64}}}()

    # Label the nodes as we go
    junction_idx = Dict{Tuple{Int64, Int64}, Int64}()
    junction_idx[start_idx] = 1
    junction_idx[end_idx] = 2

    while length(q) > 0
        (i, j), last_junction, dist = popfirst!(q)
        ((i, j), last_junction) ∈ seen && continue

        # Figure out if we are a junction
        n_intersection = 0
        i > 1 && (m[i-1, j] == '.' || m[i-1, j] == '^' || m[i-1, j] == 'v') && (n_intersection += 1)
        j > 1 && (m[i, j-1] == '.' || m[i, j-1] == '<' || m[i, j-1] == '>') && (n_intersection += 1)
        i < size(m, 1) && (m[i+1, j] == '.' || m[i+1, j] == 'v' || m[i+1, j] == '^') && (n_intersection += 1)
        j < size(m, 2) && (m[i, j+1] == '.' || m[i, j+1] == '>' || m[i, j+1] == '<') && (n_intersection += 1)
        is_junction = n_intersection > 2 || (i, j) == end_idx

        # Add us to the dict if we are a new junction
        if is_junction
            (i, j) ∉ keys(junction_idx) && (junction_idx[(i, j)] = maximum(values(junction_idx))+1)
            ret[junction_idx[(i, j)]] = [get(ret, junction_idx[(i, j)], Vector{Tuple{Int64, Int64}}()); (junction_idx[last_junction], dist)]
            last_junction = (i, j)
            dist = 0
        end

        # Add the neighbors to the list
        i > 1 && (m[i-1, j] == '.' || m[i-1, j] == '^' || (use_slopes && m[i-1, j] == 'v')) && ((i-1, j), last_junction) ∉ seen && push!(q, ((i-1, j), last_junction, dist+1))
        j > 1 && (m[i, j-1] == '.' || m[i, j-1] == '<' || (use_slopes && m[i, j-1] == '>')) && ((i, j-1), last_junction) ∉ seen && push!(q, ((i, j-1), last_junction, dist+1))
        i < size(m, 1) && (m[i+1, j] == '.' || m[i+1, j] == 'v' || (use_slopes && m[i+1, j] == '^')) && ((i+1, j), last_junction) ∉ seen && push!(q, ((i+1, j), last_junction, dist+1))
        j < size(m, 2) && (m[i, j+1] == '.' || m[i, j+1] == '>' || (use_slopes && m[i, j+1] == '<')) && ((i, j+1), last_junction) ∉ seen && push!(q, ((i, j+1), last_junction, dist+1))

        push!(seen, ((i, j), last_junction))
    end

    ret, junction_idx
end

function flip_graph(g)
    g2 = Dict{Int64, Vector{Tuple{Int64, Int64}}}()

    for (k, vs) in pairs(g)
        for (v, d) in vs
            g2[v] = [get(g2, v, Vector{Tuple{Int64, Int64}}()); (k, d)]
        end
    end
    g2
end

function longest_hike(g, start_node=1, end_node=2)
    q = Vector{Tuple{Int64, Int64, Set{Int64}}}()
    push!(q, (start_node, 0, Set(start_node)))
    max_dist = 0

    while length(q) > 0
        node, dist, visited = popfirst!(q)
        
        if node == end_node
            max_dist = max(max_dist, dist)
            continue
        end

        for (neighbor, weight) in g[node]
            neighbor ∈ visited && continue
            push!(q, (neighbor, dist + weight, union(visited, neighbor)))
        end
    end
    max_dist
end

# If you visit nodes only once then you can only get to the end node from the
# second to last node in the graph
function optimize_graph(g, end_node=2)
    g = deepcopy(g)

    end_feeder = Vector{Int64}()
    d = 0
    for (k, v) in pairs(g)
        m = findfirst(x->x[1]==end_node, v)
        if !isnothing(m)
            push!(end_feeder, k)
            d = v[m][2]
        end
    end

    if length(end_feeder) == 1
        g[end_feeder[1]] = [(end_node, d)]
    end
    g
end

function day23(input::String = readInput(joinpath(@__DIR__, "data", "day23.txt")))
    trail_map = parse_input(input)
    [longest_hike(flip_graph(map_to_graph(trail_map)[1])), longest_hike(optimize_graph(flip_graph(map_to_graph(trail_map, true)[1])))]
end

end
