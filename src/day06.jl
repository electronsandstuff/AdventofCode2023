module Day06

# Grab a list of named tuples containing the time and distance for the races
function parse_input(s)
    time = parse.(Int64, split(match(r"Time:([\s\d]*)", s).captures[1], keepempty=false))
    dist = parse.(Int64, split(match(r"Distance:([\s\d]*)", s).captures[1], keepempty=false))
    [(time=t, dist=d) for (t, d) in zip(time, dist)]
end

# Given a vector of ints, combine them into a single number as if concating a string (ie [1, 2, 3] -> 123)
combine_digits(vs) = parse(Int64, prod(string(v) for v in vs))

# number of ways we win; Solve for time pressed (t1) such that we exceed distance d in time t2
# t1*a*(t2 - t1) > d; -a*t1^2 + a*t2*t1 - d = 0; t1 = (a*t2 +/- sqrt(a^2*t2^2 - 4*a*d))/2/a
function count_wins(time, dist, a=1)
    min_hold = trunc(Int64, (a*time - sqrt(a^2*time^2 - 4*a*dist))/2/a) + 1
    max_hold = ceil(Int64, (a*time + sqrt(a^2*time^2 - 4*a*dist))/2/a) - 1
    max_hold - min_hold + 1
end

function day06(input::String = readInput(joinpath(@__DIR__, "data", "day06.txt")))
    races = parse_input(input)
    [
        prod(count_wins(r.time, r.dist) for r in races),
        count_wins(combine_digits([r.time for r in races]), combine_digits([r.dist for r in races]))
    ]
end

end