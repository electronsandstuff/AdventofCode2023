module Day12

# Represents one of the lines in the input with spring conditions and the list of group sizes
struct ConditionRecord
    springs::String
    groups::Vector{Int64}
end

# Creates the expanded record for part 2 from an original record
expand_record(cr::ConditionRecord) = ConditionRecord(join(repeat([cr.springs], 5), '?'), repeat(cr.groups, 5))

# Recursively calculate the number of ways we can fill in the unknown conditions that still satisfies the groups. Use
# memoization (in the form of the memo argument passed to subsequent recursions) to make things fast enough. r_idx is the index
# of the spring currently being considered, grp_idx is which group of springs we are checking out, cur_grp keep track of how many
# springs are in the current group. Goes down every possible branch for the unknown springs until that branch is found to be
# incompatible with the group counts or we reach the end of the string.
function count_valid_records(cr::ConditionRecord, r_idx=1, grp_idx=1, cur_grp=0, memo=Dict{Tuple{Int64, Int64, Int64}, Int64}())
    # Check the memo for this solution
    k = (r_idx, grp_idx, cur_grp)
    k ∈ keys(memo) && return memo[k]

    # End condition
    if r_idx > length(cr.springs)
        (grp_idx == length(cr.groups)) && return cur_grp == cr.groups[end]
        return (grp_idx == length(cr.groups) + 1) && (cur_grp == 0)
    end

    # Sum each posibility for ./#/?
    ret = 0
    if (cr.springs[r_idx] == '.') || (cr.springs[r_idx] == '?')
        if cur_grp == 0 || (grp_idx <= length(cr.groups) && cur_grp == cr.groups[grp_idx])
            ret += count_valid_records(cr, r_idx+1, grp_idx + (cur_grp != 0), 0, memo)
        end
    end
    if (cr.springs[r_idx] == '#') || (cr.springs[r_idx] == '?')
        if grp_idx <= length(cr.groups) && cur_grp < cr.groups[grp_idx]
            ret += count_valid_records(cr, r_idx+1, grp_idx, cur_grp+1, memo)
        end
    end

    # Store memo
    memo[k] = ret
    ret
end

# For reading in records
parse_input(s) = [parse_line(l) for l in split(s, '\n') if length(l) > 1]

# Loads one of the condition records from a line in the input file
function parse_line(l)
    m = match(r"([\?\.\#]*) ([\d\,]*)", l)
    if !isnothing(m)
        return ConditionRecord(m.captures[1], [parse(Int64, x) for x in split(m.captures[2], ',')])
    end
end

function day12(input::String = readInput(joinpath(@__DIR__, "data", "day12.txt")))
    records = parse_input(input)
    [sum(count_valid_records.(records)), sum(count_valid_records.(expand_record.(records)))]
end

end