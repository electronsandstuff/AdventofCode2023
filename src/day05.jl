module Day05

struct Rule
    source_range::UnitRange{Int64}
    offset::Int64
end
Rule(dest_start::Int64, src_start::Int64, range::Int64) = Rule(src_start:(src_start+range-1), dest_start-src_start)

struct LinkedList
    to::Union{LinkedList, Nothing}
    rules::Vector{Rule}
end
push(list::LinkedList, data::Vector{Rule}) = LinkedList(list, data)

Base.minimum(a::Vector{UnitRange{Int64}}) = minimum([first(x) for x in a])
rangediff(a, b) =  [first(a):(first(b)-1), (last(b)+1):last(a)]

function transform(rs::Vector{Rule}, vals::UnitRange{Int64})
    vals_a::Vector{UnitRange{Int64}} = [vals]
    vals_b::Vector{UnitRange{Int64}} = []
    out::Vector{UnitRange{Int64}} = []
    for r in rs
        for v in vals_a
            i = intersect(r.source_range, v)
            if length(i) > 0 
                append!(vals_b, rangediff(v, r.source_range))
                push!(out, i .+ r.offset)
            else
                push!(vals_b, v)
            end
        end
        vals_a = filter(x -> length(x) > 0, vals_b)
        vals_b = Vector{UnitRange{Int64}}()
    end
    [out; vals_a]
end

transform(rs::Vector{Rule}, vals::Vector{UnitRange{Int64}}) = vcat((transform(rs, v) for v in vals)...)

function transform(rs::Vector{Rule}, val::Int64)
    for r in rs; val in r.source_range && return val + r.offset; end
    val
end

transform(map::Map, val) = transform(map.rules, val)
function transform(ll::LinkedList, val)
    n = transform(ll.rules, val)
    isnothing(ll.to) ? n : transform(ll.to, n)
end

function parse_maps(s, ll_from, ll_to)
    seeds::Vector{Int64} = []
    maps = Dict{String, NamedTuple{(:from, :rules), Tuple{String, Vector{Rule}}}}()

    # Process lines pulling out the maps
    from = ""
    to = ""
    rules = Vector{Rule}()
    for l in split(s, "\n")
        # Check for the seeds
        m =  match(r"^seeds: ([\s\d]*)", strip(l))
        isnothing(m) || (seeds = [parse(Int64, x) for x in split(m.captures[1])])

        # Start a new map
        m = match(r"^(\w*)-to-(\w*) map:", strip(l))
        if !isnothing(m)
            from != "" && (maps[String(to)] = (from=String(from), rules=rules))
            rules, from, to = Vector{Rule}(), m.captures[1], m.captures[2]
        end

        # Create new rule
        m = match(r"^(\d*) (\d*) (\d*)", strip(l))
        isnothing(m) || push!(rules, Rule((parse(Int64, x) for x in m.captures)...))
    end
    maps[to] = (from=from, rules=rules)

    # Turn into linked list
    linked_list = LinkedList(nothing, [])
    while ll_from != ll_to
        linked_list = push(linked_list, maps[ll_to].rules)
        ll_to = maps[ll_to].from
    end
    seeds_pt2 = [start:(start+rng-1) for (start, rng) in zip(seeds[1:2:end], seeds[2:2:end])]
    seeds, seeds_pt2, linked_list
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

# Find minimum transformed values
function min_dest_val(ll::LinkedList, vals::Vector{Int64}) 
    min((transform(ll, v) for v in vals)...)
end
min_dest_val(ll::LinkedList, vals::Vector{UnitRange{Int64}}) = minimum(transform(ll, vals))

function day05(input::String = readInput(joinpath(@__DIR__, "data", "day05.txt")))
    seeds_pt1, seeds_pt2, maps = parse_maps(input, "seed", "location")
    [min_dest_val(maps, seeds_pt1), min_dest_val(maps, seeds_pt2)]
end

end