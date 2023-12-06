module Day04

# The card games
struct Game
    winning_nums::Vector{Int64}
    our_nums::Vector{Int64}
    function Game(s::AbstractString)
        new(
            [parse(Int64, x) for x in split(strip(s[findfirst(':', s)+1:findfirst('|', s)-1]), ' ', keepempty=false)],
            [parse(Int64, x) for x in split(strip(s[findfirst('|', s)+1:end]), ' ', keepempty=false)]
        )
    end
end
wins_to_points(points) = points > 0 ? 2^(points-1) : 0
n_wins(g::Game) = sum(n in g.winning_nums for n in g.our_nums)
get_points(g::Game) = wins_to_points(n_wins(g))

function count_copies(games::Vector{Game})
    # Find how many copies of each card we get
    n_copies = ones(Int64, length(games))
    for idx in 1:(length(games)-1)
        n = n_wins(games[idx])
        n_copies[idx+1:idx+n] .+= n_copies[idx]
    end
    sum(n_copies)
end

function day04(input::String = readInput(joinpath(@__DIR__, "data", "day04.txt")))
    games = [Game(s) for s in split(input, '\n') if length(s) > 1]
    [sum(get_points(g) for g in games), count_copies(games)]
end

end