module Day15

# Given the step string, calculate the has functoin
function aoc_hash(s::AbstractString)
    ret = 0
    for c in s;  ret = 17*(ret + Int64(c)) % 256; end
    ret
end

# Parse the instruction's step string into an object. Gives a named tuple with a name to go on the label, an operation, and a value
function str_to_instruction(s)
    m = match(r"(\w*)([=-])(\d?)", s)
    return (name=String(m.captures[1]), op=m.captures[2][1], val=length(m.captures[3]) > 0 ? parse(Int64, m.captures[3]) : 0)
end

# The type definition of the box
box_t = Vector{NamedTuple{(:name, :val), Tuple{String, Int64}}}

# Gets the focusing power of the individual box
box_focusing_power(b) = sum(collect(1:length(b)).*[l.val for l in b])

# Calculates the final focusing power from the instructions by maintaining all of the boxes and applying each instruction one at a time
function get_focusing_power(instructions)
    boxes::Vector{box_t} = [box_t() for _ in 1:256]
    for i in instructions
        # Find the index of the lens in the box with the name in the instruction (or nothing if there is none)
        box_idx = aoc_hash(i.name) + 1
        m = findfirst(x->x.name==i.name, boxes[box_idx])

        # Apply the dash operation (remove the lens from the box if it exists)
        if i.op == '-'
            isnothing(m) || deleteat!(boxes[box_idx], m)

        # Apply the equals operation (add to back if not in box, replace value if it does)
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

    # Sum up the focusing power
    sum(collect(1:length(boxes)) .* box_focusing_power.(boxes))
end

function day15(input::String = readInput(joinpath(@__DIR__, "data", "day15.txt")))
    instruction_strs = strip.(split(input, ','))  # Break the steps into separate strings
    [sum(aoc_hash.(instruction_strs)), get_focusing_power(str_to_instruction.(instruction_strs))]
end

end
