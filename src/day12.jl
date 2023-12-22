module Day12

struct ConditionRecord
    springs::String
    groups::Vector{Int64}
end
expand_record(cr::ConditionRecord) = ConditionRecord(join(repeat([cr.springs], 5), '?'), repeat(cr.groups, 5))

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