module Day05

# Represents a rule that maps one chunk of inputs to a set of outputs (ie a single line in the groups of the input)
struct Rule
    source_range::UnitRange{Int64}
    offset::Int64
end

# Generate a rule from the format in the input file
Rule(dest_start::Int64, src_start::Int64, range::Int64) = Rule(src_start:(src_start+range-1), dest_start-src_start)

# My linked-list object representing one of the "banks" of multiple rules in the input file that maps one entity to another
struct LinkedList
    to::Union{LinkedList, Nothing}
    rules::Vector{Rule}
end

# Add to the head of the linked list
push(list::LinkedList, data::Vector{Rule}) = LinkedList(list, data)

# Some helper functions for working with ranges
Base.minimum(a::Vector{UnitRange{Int64}}) = minimum([first(x) for x in a])
rangediff(a, b) =  [first(a):(first(b)-1), (last(b)+1):last(a)]

# Transforms the value through every node in the linked list by recursively transforming the value according to this
# node's rules and then passing the result to the next node in the linked list until there is no next node. The actual
# low level transformation rules are implemented as transform(...) called on the vector of rules
function transform(ll::LinkedList, val)
    n = transform(ll.rules, val)  # Apply our rules to the value
    isnothing(ll.to) ? n : transform(ll.to, n)  # Check for next node and pass value to it (or return if there is none)
end

# Pass a single number through a list of rules (also returns a number). Check every rule for if it applies and returns
# the original input as default
function transform(rs::Vector{Rule}, val::Int64)
    for r in rs; val in r.source_range && return val + r.offset; end
    val
end

# Applies the list of rules to a vector of ranges (just passes things to the rule for a single range and combines results into a vector of ranges)
transform(rs::Vector{Rule}, vals::Vector{UnitRange{Int64}}) = vcat((transform(rs, v) for v in vals)...)

# Apply a list of rules to a single range (results in a vector of ranges) by successively applying intersection and differences with the regions 
# the rules apply to
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

# Read the input file into the list of seeds (for pt 1) the list of ranges of seeds (for pt 2) and the linked list of rules
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

# Find the minimum transformed values after going through the linked list (for both numbers and ranges)
min_dest_val(ll::LinkedList, vals::Vector{Int64}) = min((transform(ll, v) for v in vals)...)
min_dest_val(ll::LinkedList, vals::Vector{UnitRange{Int64}}) = minimum(transform(ll, vals))

function day05(input::String = readInput(joinpath(@__DIR__, "data", "day05.txt")))
    seeds_pt1, seeds_pt2, maps = parse_maps(input, "seed", "location")
    [min_dest_val(maps, seeds_pt1), min_dest_val(maps, seeds_pt2)]
end

end