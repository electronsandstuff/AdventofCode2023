module Day19

# Represent a single part
Base.@kwdef struct Part
    x::Int64
    m::Int64
    a::Int64
    s::Int64
end

# Get property by name
function get_property(p::Part, prop::Char)
    if prop == 'x'
        return p.x
    elseif prop == 'm'
        return p.m
    elseif prop == 'a'
        return p.a
    elseif prop == 's'
        return p.s
    end
end

# Sum properties for Pt. 1
parts_sum(p::Part) = p.x + p.m + p.a + p.s
parts_sum(parts::Vector{Part}) = sum(parts_sum.(parts))

# Represent range of parts
Base.@kwdef struct PartRange
    xa::Int64 = 1
    xb::Int64 = 4000
    ma::Int64 = 1
    mb::Int64 = 4000
    aa::Int64 = 1
    ab::Int64 = 4000
    sa::Int64 = 1
    sb::Int64 = 4000
end

# Sum number of parts in range for Pt. 2
parts_sum(p::PartRange) = (p.xb-p.xa+1)*(p.mb-p.ma+1)*(p.ab-p.aa+1)*(p.sb-p.sa+1)

# Splits a range into two pieces on the condition that the property is greater than a threshold
# Returns lower and upper piece as tuple and pieces may be nothing
function split_range(p::PartRange, prop, thresh)
    if prop == 'x'
        p.xb <= thresh && return PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb), nothing
        p.xa > thresh && return nothing, PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb)
        return PartRange(p.xa, thresh, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb), PartRange(thresh+1, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb)
    elseif prop == 'm'
        p.mb <= thresh && return PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb), nothing
        p.ma > thresh && return nothing, PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb)
        return PartRange(p.xa, p.xb, p.ma, thresh, p.aa, p.ab, p.sa, p.sb), PartRange(p.xa, p.xb, thresh+1, p.mb, p.aa, p.ab, p.sa, p.sb)
    elseif prop == 'a'
        p.ab <= thresh && return PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb), nothing
        p.aa > thresh && return nothing, PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb)
        return PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, thresh, p.sa, p.sb), PartRange(p.xa, p.xb, p.ma, p.mb, thresh+1, p.ab, p.sa, p.sb)
    elseif prop == 's'
        p.sb <= thresh && return PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb), nothing
        p.sa > thresh && return nothing, PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, p.sb)
        return PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, p.sa, thresh), PartRange(p.xa, p.xb, p.ma, p.mb, p.aa, p.ab, thresh+1, p.sb)
    end
end

# Represents one rule in the workflow
struct Filter
    thresh::Int64
    property::Char
    next::String
    gt::Bool
end

# Create filters from the workflow string sections
function Filter(s::AbstractString)
    m = match(r"([xmas])([><])(\d+):(\w+)", s)
    Filter(parse(Int64, m.captures[3]), m.captures[1][1], m.captures[4], m.captures[2] == ">")
end

# Does a part meet the condition in the rule
function get_comparison(f::Filter, p::Part)
    f.gt && return get_property(p, f.property) > f.thresh
    return get_property(p, f.property) < f.thresh
end

# Pass a range through the rule: returns a tuple of the piece captured by the workflow and what is left over
function get_comparison(f::Filter, p::PartRange)
    f.gt && return split_range(p, f.property, f.thresh)
    lo, hi = split_range(p, f.property, f.thresh-1)
    return hi, lo
end

# Represents a single workflow (ie line in input)
struct Workflow
    rules::Vector{Filter}
    default::String
end

# Find where a single part ends up
function run_workflow(w::Workflow, part::Part)
    for r in w.rules
        get_comparison(r, part) && return r.next
    end
    w.default
end

# Pass a range through the workflow, returns a vector of the output ranges and the workflows they end up in
function run_workflow(w::Workflow, pr::PartRange)
    out = Vector{Tuple{PartRange, String}}()
    for r in w.rules
        pr, n = get_comparison(r, pr)
        isnothing(n) || push!(out, (n, r.next))
        isnothing(pr) && break
    end
    isnothing(pr) || push!(out, (pr, w.default))
    out
end

# Load the input into datastructures
function parse_input(s)
    workflows = Dict{String, Workflow}()
    parts = Vector{Part}()

    for l in split(s, '\n')
        m = match(r"(\w+)\{([\w\d:><,]+)\}", l)
        if !isnothing(m)
            filts = split(m.captures[2], ',')
            workflows[m.captures[1]] = Workflow([Filter(f) for f in filts[1:end-1]], filts[end])
        end

        m = match(r"\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}", l)
        isnothing(m) || push!(parts, Part(x=parse(Int64, m.captures[1]), m=parse(Int64, m.captures[2]), a=parse(Int64, m.captures[3]), s=parse(Int64, m.captures[4])))
    end
    workflows, parts
end

# Run workflows all the way until part ends up in A or R
function get_accept_or_reject(workflows, part, cur_workflow="in")
    next = run_workflow(workflows[cur_workflow], part)
    (next == "A" || next == "R") && return next
    return get_accept_or_reject(workflows, part, next)
end

# Counts the number of accepted parts in a range
function count_accept(workflows, pr=PartRange(), cur_workflow="in")
    acc = 0
    for (new_pr, wf) in run_workflow(workflows[cur_workflow], pr)
        if wf == "A"
            acc += parts_sum(new_pr)
        elseif wf != "R"
            acc += count_accept(workflows, new_pr, wf)
        end
    end
    acc
end

function day19(input::String = readInput(joinpath(@__DIR__, "data", "day19.txt")))
    workflows, parts = parse_input(input)
    [parts_sum(filter(x->get_accept_or_reject(workflows, x) == "A", parts)), count_accept(workflows)]
end

end
