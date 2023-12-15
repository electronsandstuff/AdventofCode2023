module Day11

function parse_input(s)
    galaxies = Set{Tuple{Int64, Int64}}()
    for (i, l) in enumerate(split(s, '\n'))
        for (j, ele) in enumerate(l)
            ele == '#' && push!(galaxies, (i, j))
        end
    end
    galaxies
end

function missing_vals(galaxies, idx)
    all_vals = Set(x[idx] for x in galaxies)
    setdiff(Set(1:maximum(all_vals)), all_vals)
end

function expand_galaxies(galaxies, scale=2)
    missing_rows = missing_vals(galaxies, 1)
    missing_cols = missing_vals(galaxies, 2)
    Set(Tuple((i + (scale-1)*sum(i .> missing_rows), j + (scale-1)*sum(j .> missing_cols))) for (i, j) in galaxies)
end

manhattan_distance(a, b) = sum(abs(x - y) for (x, y) in zip(a, b))
function sum_min_distances(galaxies)
    val = 0
    for (idx1, a) in enumerate(galaxies)
        for (idx2, b) in enumerate(galaxies)
            idx1 < idx2 && (val = val + manhattan_distance(a, b))
        end
    end
    val
end

function day11(input::String = readInput(joinpath(@__DIR__, "data", "day11.txt")), expansion=1000000)
    galaxies = parse_input(input)
    [sum_min_distances(expand_galaxies(galaxies)), sum_min_distances(expand_galaxies(galaxies, expansion))]
end

end