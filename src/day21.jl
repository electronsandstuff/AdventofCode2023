module Day21

# In a vector of vectors, find the first time condition fn is satisfied
function findfirst_2d(fn, lines)
    for (i, l) in enumerate(lines)
        j = findfirst(fn, l)
        isnothing(j) || return i, j
    end
end

# Load the input text into a grid of rocks and a starting position
function parse_input(input)
    lines_cleaned = filter(x->length(x)>0, strip.(split(input, '\n')))
    spos = findfirst_2d(==('S'), lines_cleaned)
    rocks = permutedims(hcat(collect.(lines_cleaned)...)) .== '#'
    rocks, spos
end

# For the special case that you walk to the edge of the one of the repeating units of the infinite square plots
# (ie the case that the elf starts in the center of the plot and walks one half length of the repeating unit
# plus some integer multiple of the plot size) the resulting number of steps walked will be some number of the
# repeating unit, some number of pieces that look like triangle cuts of the plots and then the caps which look like
# pyramid shaped occupying regions. The number of each section will grow quadratically, linearly or remain constant
# as the number of repeating tiles is increased. This constrains the number of occupied plots to be a quadratic function
# of the number of repeating units walked. To get this function, use the algorithm from part one for the first three
# repeating units and then fit a quadratic to it and calculate its value at the final n_step.
function count_occupied_plots_quad(rocks, spos, n_step)
    n = size(rocks, 2)
    k = size(rocks, 1) ÷ 2

    # Evaluate number of points as we increase number of "macroplots"
    pk = [count_occupied_plots(rocks, spos, i, true) for i in [k, k + n, k + 2*n]]

    # Calculate the quadratic polynomial from the points and return for our real number of steps
    x = n_step÷n
    a = (pk[1] + pk[3] - 2*pk[2])÷2
    b = pk[2] - pk[1] - a
    c = pk[1]
    a*x^2 + b*x + c
end

# Find the occupied plots... only need to count the plots reachable in the same number of steps mod 2
# as the total number of steps since you can always imagine a path that goes back and forth between the
# last tile and current tile until the total number of steps is achieved.
function count_occupied_plots(rocks, spos, n_step=64, isinfinite=false)
    if isinfinite && (n_step > 2048)
        # Trigger the quadratic fit rule
        m = size(rocks, 1)
        n = size(rocks, 2)
        k = size(rocks, 1) ÷ 2
        (m == n) && m%2 == 1 && spos[1] - 1 == k && spos[2] - 1 == k && n_step%n == k && return count_occupied_plots_quad(rocks, spos, n_step)

        # Otherwise don't offer an answer
        throw(DomainError(n_step, raw"sorry... calculation will be too slow ¯\_(ツ)_/¯"))
    end

    q = Vector{Tuple{Tuple{Int64, Int64}, Int64}}()
    push!(q, (spos, 0))
    seen = Set{Tuple{Int64, Int64}}()
    occupied_plots = 0

    while length(q) > 0
        (i, j), steps = popfirst!(q)
        ((i, j) ∈ seen || steps > n_step) && continue
        (steps%2 == n_step%2) && (occupied_plots += 1)
        (isinfinite || i > 1) && !rocks[mod(i-2, size(rocks, 1))+1, mod(j-1, size(rocks, 2))+1] && (i-1, j) ∉ seen && push!(q, ((i-1, j), steps+1))
        (isinfinite || j > 1) && !rocks[mod(i-1, size(rocks, 1))+1, mod(j-2, size(rocks, 2))+1] && (i, j-1) ∉ seen && push!(q, ((i, j-1), steps+1))
        (isinfinite || i < size(rocks, 1)) && !rocks[mod(i, size(rocks, 1))+1, mod(j-1, size(rocks, 2))+1] && (i+1, j) ∉ seen && push!(q, ((i+1, j), steps+1))
        (isinfinite || j < size(rocks, 2)) && !rocks[mod(i-1, size(rocks, 1))+1, mod(j, size(rocks, 2))+1] && (i, j+1) ∉ seen && push!(q, ((i, j+1), steps+1))
        push!(seen, (i, j))
    end
    occupied_plots
end

function day21(input::String = readInput(joinpath(@__DIR__, "data", "day21.txt")), n_step_pt1=64, n_step_pt2=26501365)
    rocks, spos = parse_input(input)
    [count_occupied_plots(rocks, spos, n_step_pt1), count_occupied_plots(rocks, spos, n_step_pt2, true)]
end

end
