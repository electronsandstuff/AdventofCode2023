module Day15

function aoc_hash(s::AbstractString)
    ret = 0
    for c in s;  ret = 17*(ret + Int64(c)) % 256; end
    ret
end

function str_to_instruction(s)
    m = match(r"(\w*)([=-])(\d?)", s)
    return (name=String(m.captures[1]), op=m.captures[2][1], val=length(m.captures[3]) > 0 ? parse(Int64, m.captures[3]) : 0)
end

box_t = Vector{NamedTuple{(:name, :val), Tuple{String, Int64}}}
box_focusing_power(b) = sum(collect(1:length(b)).*[l.val for l in b])
function get_focusing_power(instructions)
    boxes::Vector{box_t} = [box_t() for _ in 1:256]
    for i in instructions
        box_idx = aoc_hash(i.name) + 1
        m = findfirst(x->x.name==i.name, boxes[box_idx])
        if i.op == '-'
            isnothing(m) || deleteat!(boxes[box_idx], m)
        elseif i.op == '='
            if isnothing(m)
                push!(boxes[box_idx], (name=i.name, val=i.val))
            else
                boxes[box_idx][m] = (name=i.name, val=i.val)
            end
        else
            throw(DomainError(i.op, "Unknown operation"))
        end
    end
    sum(collect(1:length(boxes)) .* box_focusing_power.(boxes))
end

function day15(input::String = readInput(joinpath(@__DIR__, "data", "day15.txt")))
    instruction_strs = strip.(split(input, ','))
    [sum(aoc_hash.(instruction_strs)), get_focusing_power(str_to_instruction.(instruction_strs))]
end

end
