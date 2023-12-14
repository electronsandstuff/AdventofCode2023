module Day08

mutable struct LRGraph
    const name::String
    l::Union{LRGraph, Nothing}
    r::Union{LRGraph, Nothing}
end
LRGraph(name) = LRGraph(name, nothing, nothing)
function walk(g::LRGraph, dir::Char)
    dir == 'L' && return g.l
    dir == 'R' && return g.r
    throw(KeyError("Unrecognized direction $(dir)"))
end

function count_steps_to(graph::LRGraph, directions::String, to::String, direction_idx::Int64=1)
    graph.name == to && return 0
    return 1 + count_steps_to(walk(graph, directions[direction_idx]), directions, to, direction_idx%length(directions)+1)
end

function count_steps_to_end_in(graph::LRGraph, directions::String, ending::Char, direction_idx::Int64=1)
    graph.name[end] == ending && return 0
    return 1 + count_steps_to_end_in(walk(graph, directions[direction_idx]), directions, ending, direction_idx%length(directions)+1)
end

function parse_directions_and_graph(s)
    directions = nothing
    graph_data = Dict{String, Tuple{LRGraph, String, String}}()

    for l in split(s, '\n')
        # Handle the directions
        if isnothing(directions)
            m = match(r"([LR]*)", l)
            !isnothing(m) && (directions = m.captures[1])
        else  # Handle the graph connections
            m = match(r"(\S\S\S) = \((\S\S\S), (\S\S\S)\)", l)
            !isnothing(m) && (graph_data[m.captures[1]] = (LRGraph(m.captures[1]), m.captures[2], m.captures[3]))
        end
    end

    # Connect the graph objects
    for gd in values(graph_data)
        gd[1].l = graph_data[gd[2]][1]
        gd[1].r = graph_data[gd[3]][1]
    end
    string(directions), Dict(n => gd[1] for (n, gd) in pairs(graph_data))
end

function steps_until_all_end(graph_dict, directions, from_end_char='A', to_end_char='Z')
    lcm([count_steps_to_end_in(graph_dict[n], directions, to_end_char) for n in keys(graph_dict) if n[end] == from_end_char]...)
end

function day08(input::String = readInput(joinpath(@__DIR__, "data", "day08.txt")))
    directions, graph = parse_directions_and_graph(input)
    pt1 = haskey(graph, "AAA") ? count_steps_to(graph["AAA"], directions, "ZZZ") : nothing
    [pt1, steps_until_all_end(graph, directions)]
end

end