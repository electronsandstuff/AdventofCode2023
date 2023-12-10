module Day05

struct Rule
    dest_start::Int64
    source_start::Int64
    range::Int64
end

struct Map
    from::String
    to::String
    rules::Vector{Rule}
end

struct LinkedList
    to::Union{LinkedList, Nothing}
    rules::Vector{Rule}
end
push(list::LinkedList, data::Vector{Rule}) = LinkedList(list, data)

function source_to_dest_num(rules::Vector{Rule}, dest_num)
    for r in rules
        if r.source_start <= dest_num < r.source_start + r.range
            return dest_num - r.source_start + r.dest_start
        end
    end
    dest_num
end
source_to_dest_num(map::Map, dest_num) = source_to_dest_num(map.rules, dest_num)
function source_to_dest_num(ll::LinkedList, dest_num)
    n =  source_to_dest_num(ll.rules, dest_num)
    isnothing(ll.to) ? n : source_to_dest_num(ll.to, n)
end

function parse_maps(s)
    seeds::Vector{Int64} = []
    maps::Vector{Map} = []

    map_from = ""
    map_to = ""
    rules = []
    for l in split(s, "\n")
        # Check for the seeds
        if length(seeds) == 0
            m =  match(r"seeds: ([\s\d]*)", strip(l))
            isnothing(m) || (seeds = [parse(Int64, x) for x in split(m.captures[1])])
        else
            # Process section header
            m = match(r"(\w*)-to-(\w*) map:", strip(l))
            if !isnothing(m)
                map_from != "" && push!(maps, Map(map_from, map_to, [Rule(r...) for r in rules]))
                rules = []
                map_from = m.captures[1]
                map_to = m.captures[2]
            end

            # Process rules
            m = match(r"(\d*) (\d*) (\d*)", strip(l))
            if !isnothing(m)
                push!(rules, Tuple(parse(Int64, x) for x in m.captures))
            end
        end
    end
    push!(maps, Map(map_from, map_to, [Rule(r...) for r in rules]))
    seeds, maps
end

function maps_to_ll(maps, from, to)
    dest_to_map = Dict(m.to => m for m in maps)
    linked_list = LinkedList(nothing, [])
    while from != to
        linked_list = push(linked_list, dest_to_map[to].rules)
        to = dest_to_map[to].from
    end
    linked_list
end

function day05(input::String = readInput(joinpath(@__DIR__, "data", "day05.txt")))
    seeds, maps = parse_maps(input)
    ll = maps_to_ll(maps, "seed", "location")
    [min((source_to_dest_num(ll, s) for s in seeds)...), ]
end

end