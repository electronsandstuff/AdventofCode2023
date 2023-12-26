module Day20

using DataStructures

# Define all of the module types
Base.@kwdef mutable struct FlipFlop
    state::Bool = false
    next::Vector{String}
end

Base.@kwdef struct Conjunction2
    state::OrderedDict{String, Bool} = Dict{String, Bool}()
    next::Vector{String}
end


# Register an input to a module
register_input!(m::Conjunction2, mod) = (m.state[mod] = false)
register_input!(m, mod) = nothing

# Get a modules state
get_state(m) = Vector{Bool}()
get_state(m::Conjunction2) = collect(values(m.state))
get_state(m::FlipFlop) = [m.state]
get_state(ms::AbstractDict)::Vector{Bool} = reduce(vcat, get_state.(values(ms)))

struct Broadcast
    next::Vector{String}
end

propagate_pulse!(m::Broadcast, pulse::Bool, last::String) = pulse

function propagate_pulse!(m::Conjunction2, pulse::Bool, last::String)
    m.state[last] = pulse
    !all(values(m.state))
end

function propagate_pulse!(m::FlipFlop, pulse::Bool, last::String)
    pulse && return nothing
    m.state = !m.state
end

function module_from_line(l)
    m = match(r"([%&]?)(\w+) -> ([\w\s,]+)", l)
    if m.captures[1] == "" && m.captures[2] == "broadcaster"
        return string(m.captures[2]) => Broadcast(strip.(split(m.captures[3], ',')))
    elseif m.captures[1] == "%"
        return string(m.captures[2]) => FlipFlop(next=strip.(split(m.captures[3], ',')))
    elseif m.captures[1] == "&"
        return string(m.captures[2]) => Conjunction2(next=strip.(split(m.captures[3], ',')))
    end
    m.captures
end

function parse_lines(ls)
    d = OrderedDict{String, Union{FlipFlop, Conjunction2, Broadcast}}(module_from_line.(filter(x->length(x)>0, strip.(split(ls, '\n')))))
    for (k, v) in pairs(d);for n in v.next
        n ∈ keys(d) && register_input!(d[n], k)
    end; end
    d
end

function propagate_pulse!(modules::AbstractDict)
    q = Vector{Tuple{String, Bool, String}}()
    push!(q, ("broadcaster", false, "button"))
    pulses = Dict{String, Vector{Int64}}()

    while length(q) > 0
        this_node, pulse_val, last_node = popfirst!(q)
        this_node ∉ keys(pulses) && (pulses[this_node] = [0, 0])
        pulses[this_node][Int(pulse_val) + 1] += 1
        this_node ∉ keys(modules) && continue
        p = propagate_pulse!(modules[this_node], pulse_val, last_node)
        isnothing(p) && continue
        for n in modules[this_node].next
            push!(q, (n, p, this_node))
        end
    end
    pulses
end

function count_pulses(modules, n_presses)
    modules = deepcopy(modules)
    seen = Dict{Vector{Bool}, Tuple{Int64, Vector{Int64}}}()
    presses = 0
    jumped = false
    pulses = [0, 0]
    while presses < n_presses
        pulses += sum(values(propagate_pulse!(modules)))
        state = get_state(modules)
        presses += 1
        if !jumped && state in keys(seen)
            new_presses = n_presses - ((n_presses - seen[state][1]) % (presses - seen[state][1]))
            jumped = true
            pulses += (pulses - seen[state][2]) * ((new_presses - presses) ÷ (presses - seen[state][1]))
            presses = new_presses
        else
            seen[state] = (presses, pulses)
        end
    end
    pulses
end

function count_cycle_time(modules)
    modules = deepcopy(modules)
    seen = Set{Vector{Bool}}()
    push!(seen, get_state(modules))
    presses = 0
    while true
        propagate_pulse!(modules)
        state = get_state(modules)
        presses += 1
        state ∈ seen && return presses
        push!(seen, state)
    end
end

function presses_until_low(modules, node="rx")
    modules = deepcopy(modules)
    acc = 0
    while true
        acc += 1
        get(propagate_pulse!(modules), node, [0, 0])[1] > 0 && return acc
    end
end

function to_vizgraph(modules)
    ret = "strict digraph{\n"
    for (k, m) in pairs(modules)
        if typeof(m) == Conjunction2
            ret = ret * "  $k [color = green]\n"
        elseif typeof(m) == FlipFlop
            ret = ret * "  $k [color = red]\n"
        end
        ret = ret * "  $k -> " * join(m.next, ",") * "\n"
    end
    ret = ret * "}\n"
end

function get_modules_to_beginning(modules, end_node)
    ret = OrderedDict{String, Union{FlipFlop, Conjunction2, Broadcast}}()
    q = Vector{String}()
    push!(q, end_node)
    while length(q) > 0
        name = popfirst!(q)
        ret[name] = deepcopy(modules[name])
        for (k, v) in pairs(modules)
            k ∉ keys(ret) && name ∈ v.next && push!(q, k)
        end
    end
    ret
end

get_prev(m::Conjunction2) = collect(keys(m.state))
function get_submodules(modules, end_node="rx")
    # Go a few steps up the chain (this is specific to this graph structure)
    feeders = keys(filter(x->end_node∈x[2].next, modules))
    feeders = reduce(vcat, get_prev.([modules[k] for k in feeders]))
    feeders = reduce(vcat, get_prev.([modules[k] for k in feeders]))

    # For each of the conjunction nodes, get only the pieces feeding it
    [get_modules_to_beginning(modules, f) for f in feeders]
end

is_real_data(ms, end_node="rx") = any(end_node ∈ m.next for m in values(ms))
function day20(input::String = readInput(joinpath(@__DIR__, "data", "day20.txt")))
    modules = parse_lines(input)
    # print(to_vizgraph(modules))
    [prod(count_pulses(modules, 1000)), is_real_data(modules) ? lcm(count_cycle_time.(get_submodules(modules))...) : nothing]
end

end


# 8978220530622 too low