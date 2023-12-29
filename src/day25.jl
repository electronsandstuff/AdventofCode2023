module Day25

using DataStructures
using Random

# Loads a single line from input into a string vector pair
function parse_line(l)
    k, v = split(l, ':')
    string(k) => string.(split(strip(v), keepempty=false))
end

# Load input into dict of adjacency
parse_input(input) = Dict(parse_line.(filter(x->length(x)>0, strip.(split(input, '\n')))))

# Use Dijkstra to find the shortest path between two points in the graph
function shortest_path(g, start_vert, end_vert)
    # Set up some datastructures
    seen = Set{String}()
    dist = Dict{String, Int64}(start_vert => 0)
    prev = Dict{String, String}()
    q = PriorityQueue{String, Int64}()
    enqueue!(q, start_vert, 0)

    while length(q) > 0
        # Get the least distance state
        this_point = dequeue!(q)

        # Return the final distance if we made it (and the path)
        if this_point == end_vert
            path = [this_point]
            while path[end] in keys(prev)
                push!(path, prev[path[end]])
            end
            return dist[this_point], path
        end

        # Continue if seen this node already
        this_point ∈ seen && continue

        # Test each neighboring node
        for n in g[this_point]
            alt = dist[this_point] + 1
            if alt < get(dist, n, alt+1)
                dist[n] = alt
                prev[n] = this_point
                DataStructures.enqueue!(q, n, alt)
            end
        end
        
        # We've seen this node
        push!(seen, this_point)
    end
end

# Makes sure every node and edge appears in the adjacency list
function clean_graph!(g)
    to_add = Dict{String, Vector{String}}()
    for (k, ns) in pairs(g)
        for n in ns
            k ∉ get(g, n, []) && (to_add[n] = [get(to_add, n, []); k])
        end
    end
    for (k, v) in pairs(to_add)
        g[k] = [get(g, k, []); v]
    end
end

# Randomly sample two vertices and calculate shortest paths between them. Stores the number of times each edge
# is traversed by the paths and returns list of most traversed edges and the dict of number of times traversed
function sample_shortest_paths(g, max_samps=1024)
    nodes = collect(keys(g))
    seen_edges = Dict{Tuple{String, String}, Int64}()
    samples = 0
    while samples < max_samps
        a, b = randperm(length(nodes))[1:2]
        nodes[a] ∈ g[nodes[b]] && continue
        _, path = shortest_path(g, nodes[a], nodes[b])
        for i in 1:(length(path)-1)
            k = (min(path[i], path[i+1]), max(path[i], path[i+1]))
            seen_edges[k] = get(seen_edges, k, 0) + 1
        end
        samples += 1
    end
    sort(collect(keys(seen_edges)), by=x->-seen_edges[x]), seen_edges
end

# Removes an edge from the graph
function clip_edge!(g, start_vert, end_vert)
    deleteat!(g[start_vert], findall(==(end_vert), g[start_vert]))
    deleteat!(g[end_vert], findall(==(start_vert), g[end_vert]))
end

# Count size of region connected to a vertex
function count_connected(g, vert)
    q = Vector{String}()
    seen = Set{String}()
    push!(q, vert)

    while length(q) > 0
        n = popfirst!(q)
        n ∈ seen && continue
        for m in g[n]
            m ∉ seen && push!(q, m)
        end
        push!(seen, n)
    end
    length(seen)
end

# Count the three most traversed edge in the shortest paths from randomly selected points, clip them
# and count the sizes of the remaining connected components
function calc_subgraph_sizes(g, max_samps=1024)
    most_seen, _ = sample_shortest_paths(g, max_samps)
    clipped_edges = most_seen[1:3]

    # Clip the edges and count the size of the separate pieces
    for ce in clipped_edges
        clip_edge!(g, ce...)
    end
    a = count_connected(g, collect(keys(g))[1])
    a, length(g) - a
end

function day25(input::String = readInput(joinpath(@__DIR__, "data", "day25.txt")), max_samps=1024)
    # Parse the graph from input
    g = parse_input(input)
    clean_graph!(g)
    
    # Calculate product of the subgraphs w/ three edges clipped
    Random.seed!(137)
    [prod(calc_subgraph_sizes(g, max_samps))]
end

end
