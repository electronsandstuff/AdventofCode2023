module Day24

using LinearAlgebra

# Holds position (r) and velocity (v) or the hailstone
struct Hailstone
    r::Tuple{Int64, Int64, Int64}
    v::Tuple{Int64, Int64, Int64}
end

# Get position at time t
get_pos(h::Hailstone, t) = t .* h.v .+ h.r

# Hailstone from a string
function Hailstone(s::AbstractString)
    m = match(r"(-?\d+),\s*(-?\d+),\s*(-?\d+)\s*@\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)", s)
    Hailstone(Tuple(parse(Int64, x) for x in m.captures[1:3]), Tuple(parse(Int64, x) for x in m.captures[4:6]))
end

# y1 = t1*v1 + r1
# t1*v1 + r1 = t2*v2 + r2
# [v1; -v2]*[t1; t2] = r2 - r1
# [t1; t2] = [v1; -v2]^(-1)*(r2 - r1)
function path_intersection(a::Hailstone, b::Hailstone)
    det = (a.v[2]*b.v[1] - a.v[1]*b.v[2])
    det == 0 && return nothing
    t1 = (-b.v[2]*(b.r[1] - a.r[1]) + b.v[1]*(b.r[2] - a.r[2]))/det
    t2 = (-a.v[2]*(b.r[1] - a.r[1]) + a.v[1]*(b.r[2] - a.r[2]))/det
    t1, t2
end

# Read hailstones from input file
parse_input(s) = Hailstone.(filter(x->length(x)>0, strip.(split(s, '\n'))))

# Counts number of intersections in x/y with coordinates between start and stop
function count_intersection_in_reg(hail, start, stop)
    acc = 0
    for i in 1:length(hail); for j in (i+1):length(hail)
        t = path_intersection(hail[i], hail[j])
        isnothing(t) && continue
        x, y, _ = get_pos(hail[i], t[1])
        t[1] > 0 && t[2] > 0 && x >= start && x <= stop && y >= start && y <= stop && (acc += 1)
    end; end
    acc
end

# Solve for linear system of equations in the stone's unknown r and v in terms of the hail's ri and vi
# ti*(vi - v) + r1 - r = 0 (must hold for each hailstone)
# (vi - v)x(r1 - r) = 0 (cross product zeros out time term)
# (vi)x(ri) - (vi)x(r) - (v)x(ri) + (v)x(r) = 0 (next, take difference to remove nonlinearity)
# (vi)x(ri) - (vi)x(r) - (v)x(ri) - (vj)x(rj) + (vj)x(r) + (v)x(rj) = 0
# (vi)x(ri) - (vj)x(rj) - (vi)x(r) + (vj)x(r) - (v)x(ri) + (v)x(rj) = 0
# (r)x(vi-vj) + (v)x(rj-ri) = (vj)x(rj) - (vi)x(ri) (nicely collect the unknowns)

# Cross product
cross(a, b) = (a[2]*b[3] - a[3]*b[2]), (a[3]*b[1] - a[1]*b[3]), (a[1]*b[2] - a[2]*b[1])

# Meant to be used like: set one component of r and v to one with the rest zero. Will return
# the coefficient in the LHS matrix corresponding to that element
get_mat_coeff(hail, r, v, i, j) = cross(r, hail[i].v .- hail[j].v) .+ cross(v, hail[j].r .- hail[i].r)
get_rhs(hail, i, j) = cross(hail[j].v, hail[j].r) .- cross(hail[i].v, hail[i].r)

# Calculate one three component "strip" of the matrix and RHS... IE the x,y,z components of the equation
function get_eq_strip(hail, i, j)
    a = collect(get_mat_coeff(hail, (1, 0, 0), (0, 0, 0), i, j))
    b = collect(get_mat_coeff(hail, (0, 1, 0), (0, 0, 0), i, j))
    c = collect(get_mat_coeff(hail, (0, 0, 1), (0, 0, 0), i, j))
    d = collect(get_mat_coeff(hail, (0, 0, 0), (1, 0, 0), i, j))
    e = collect(get_mat_coeff(hail, (0, 0, 0), (0, 1, 0), i, j))
    f = collect(get_mat_coeff(hail, (0, 0, 0), (0, 0, 1), i, j))
    hcat(a, b, c, d, e, f), collect(get_rhs(hail, i, j))
end

# Get the full 6x6 equation for the given indices of the stones i, j, k
function get_eq(hail, i, j, k)
    a, b = get_eq_strip(hail, i, j)
    c, d = get_eq_strip(hail, j, k)
    vcat(a, c), vcat(b, d)
end

# Iterate until we find a nonsingular matrix and return the solution
function solve_for_stone(hail)
    for i in 1:(length(hail)-3)
        a, y = get_eq(hail, i, i+1, i+2)
        if det(a) != 0
            x = round.(a \ y)
            return Hailstone((x[1], x[2], x[3]), (x[4], x[5], x[6]))
        end
    end
end

function day24(input::String = readInput(joinpath(@__DIR__, "data", "day24.txt")), start=200000000000000, stop=400000000000000)
    hail = parse_input(input)
    [count_intersection_in_reg(hail, start, stop), sum(solve_for_stone(hail).r)]
end

end
