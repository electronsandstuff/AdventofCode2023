module Day03

load_input(s) = permutedims(hcat((collect(strip(l)) for l in split(s, "\n") if length(l) > 1)...))

# Check if a symbol neighbors this position
issymbol(c) = c != '.' &&  !isdigit(c)
inbound(img, i, j) = (1 <= i <= size(img)[1]) && (1 <= j <= size(img)[2])
neighbors(img, i, j) = ((i+x, j+y) for x in [-1 0 1] for y in [-1 0 1] if inbound(img, i+x, j+y) && (x != 0 || y != 0))
is_symbol_adjacent(img, i, j) = any(issymbol(img[n...]) for n in neighbors(img, i, j))

function sum_symbol_adjecent_nums(img)
    total = 0
    for i in 1:size(img)[1]
        num = 0
        keep = false
        for j in 1:size(img)[2]
            if isdigit(img[i, j])
                num = 10*num + parse(Int64, img[i, j])
                keep = keep || is_symbol_adjacent(img, i, j)
            end
            if !isdigit(img[i, j]) || j == size(img)[2]            
                keep && (total += num)
                num = 0
                keep = false
            end
        end
    end
    total
end

# Looking for numbers near gears
get_gear_ratio_sum(img) = sum(prod(v) for v in values(get_gear_nums(img)) if length(v) ==2)
function get_gear_nums(img)
    all_gears = Dict{Tuple{Int64, Int64}, Vector{Int64}}()
    for i in 1:size(img)[1]
        num = 0
        our_gears = Set{Tuple{Int64, Int64}}()
        for j in 1:size(img)[2]
            if isdigit(img[i, j])
                num = 10*num + parse(Int64, img[i, j])
                for n in neighbors(img, i, j)
                    img[n...] == '*' && push!(our_gears, n)
                end
            end
            if !isdigit(img[i, j]) || j == size(img)[2]            
                for g in our_gears
                    all_gears[g] = [get(all_gears, g, Vector{Int64}()); num]
                end
                num = 0
                our_gears = Set{Tuple{Int64, Int64}}()
            end
        end
    end
    all_gears
end


# Final solution
function day03(input::String = readInput(joinpath(@__DIR__, "data", "day03.txt")))
    img = load_input(input)
    [sum_symbol_adjecent_nums(img), get_gear_ratio_sum(img)]
end

end