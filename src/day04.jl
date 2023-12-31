module Day04

# The card games
struct Game
    winning_nums::Vector{Int64}
    our_nums::Vector{Int64}

    # Load a game from a line in the input file
    function Game(s::AbstractString)
        new(
            [parse(Int64, x) for x in split(strip(s[findfirst(':', s)+1:findfirst('|', s)-1]), ' ', keepempty=false)],
            [parse(Int64, x) for x in split(strip(s[findfirst('|', s)+1:end]), ' ', keepempty=false)]
        )
    end
end

# Convert the number of wins into points in the game
wins_to_points(n_win) = n_win > 0 ? 2^(n_win-1) : 0

# Find the number of wins in the game
n_wins(g::Game) = sum(n in g.winning_nums for n in g.our_nums)

# Gets the points from this game
get_points(g::Game) = wins_to_points(n_wins(g))

# Given the list of games, count the total number of copies generated with the rules in part two by maintaining a
# vector of the count of cards and then iterating once through the list of cards, adding the number of copies generated.
function count_copies(games::Vector{Game})
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