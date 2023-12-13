module Day07

# Types for the cards and hand
Card = Char
Hand = Tuple{Card, Card, Card, Card, Card}
Game = NamedTuple{(:hand, :bid), Tuple{Hand, Int64}}

# Stuff for ranking
card_to_rank_pt1 = begin 
    x = Dict(Char(Int('0') + x) => x for x in range(2, 9))
    for (idx, c) in enumerate("TJQKA"); x[c] = 9+idx; end
    x
end
card_to_rank_pt2 = begin
    x = copy(card_to_rank_pt1)
    x['J'] = 1
    x
end

@enum HandType begin
    five_of_a_kind=7
    four_of_a_kind=6
    full_house=5
    three_of_a_kind=4
    two_pair=3
    one_pair=2
    high_card=1
end

# For loading the data
function parse_line(s)
    x = split(strip(s))
    Game((Hand(collect(x[1])), parse(Int64, x[2])))
end
parse_input(s) = [parse_line(l) for l in split(s, '\n') if length(l) > 1]

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

function sort_games(games::Vector{Game}, pt=1)
    card_vals = (pt == 1 ? card_to_rank_pt1 : card_to_rank_pt2)
    for idx in 5:-1:1
        games = sort(games, by=g->card_vals[g.hand[idx]])
    end
    sort(games, by=g->get_type(g.hand, pt == 2))
end

function camel_card_winnings(games::Vector{Game}, pt=1)
    games = sort_games(games, pt)
    sum(idx*g.bid for (idx, g) in enumerate(games))
end

function day07(input::String = readInput(joinpath(@__DIR__, "data", "day07.txt")))
    games = parse_input(input)
    [camel_card_winnings(games, 1), camel_card_winnings(games, 2)]
end

end