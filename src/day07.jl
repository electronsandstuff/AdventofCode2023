module Day07

# Type definitions for the cards and hand
Card = Char
Hand = Tuple{Card, Card, Card, Card, Card}
Game = NamedTuple{(:hand, :bid), Tuple{Hand, Int64}}

# Define a dictionary mapping cards (characters) into their value (ints)
card_to_rank_pt1 = begin 
    x = Dict(Char(Int('0') + x) => x for x in range(2, 9))
    for (idx, c) in enumerate("TJQKA"); x[c] = 9+idx; end
    x
end

# Modify the mapping for pt. 2
card_to_rank_pt2 = begin
    x = copy(card_to_rank_pt1)
    x['J'] = 1
    x
end

# Define the different types of hands (and their ranking)
@enum HandType begin
    five_of_a_kind=7
    four_of_a_kind=6
    full_house=5
    three_of_a_kind=4
    two_pair=3
    one_pair=2
    high_card=1
end

# Loads the hand and big from a single line in the input
function parse_line(s)
    x = split(strip(s))
    Game((Hand(collect(x[1])), parse(Int64, x[2])))
end

# Loads all of the games from the input
parse_input(s) = [parse_line(l) for l in split(s, '\n') if length(l) > 1]

# From a hand, returns the type of the hand (ie full_house, two_pair, etc.). Can optionally treat
# jokers as a wildcard for part 2
function get_type(x::Hand, joker_wildcard=false)
    c = Dict{Card, Int64}()  # Dict of counts
    for card in x
        (!joker_wildcard || card != 'J') && (c[card] = get(c, card, 0) + 1)
    end
    (length(c) == 1 || length(c) == 0) && return five_of_a_kind
    length(c) == 2 && any(values(c) .== 1) && return four_of_a_kind
    length(c) == 2 && return full_house
    (maximum(values(c)) + 5 - sum(values(c))) == 3 && return three_of_a_kind
    length(c) == 4 && return one_pair
    length(c) == 5 && return high_card
    two_pair
end

# Returns the games sorted in order of the hands' value
function sort_games(games::Vector{Game}, joker_wildcard=false)
    card_vals = (joker_wildcard ? card_to_rank_pt2 : card_to_rank_pt1)
    for idx in 5:-1:1
        games = sort(games, by=g->card_vals[g.hand[idx]])
    end
    sort(games, by=g->get_type(g.hand, joker_wildcard))
end

# Get the sorted games and then sum up the winnings according to the rules of camel cards
function camel_card_winnings(games::Vector{Game}, joker_wildcard=false)
    games = sort_games(games, joker_wildcard)
    sum(idx*g.bid for (idx, g) in enumerate(games))
end

function day07(input::String = readInput(joinpath(@__DIR__, "data", "day07.txt")))
    games = parse_input(input)
    [camel_card_winnings(games, false), camel_card_winnings(games, true)]
end

end