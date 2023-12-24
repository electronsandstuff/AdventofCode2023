module Day18

# Turn hex color into a Tuple
parse_color(s)::Tuple{UInt8, UInt8, UInt8} = Tuple(parse(Int64, s[i:i+1], base=16) for i in 1:2:length(s))

# Each command in the input
struct DigCommand
    dir::Char
    dist::Int64
    color::Tuple{UInt8, UInt8, UInt8}
end

function DigCommand(s::AbstractString)
    dir, dist, color = split(s)
    DigCommand(dir[1], parse(Int64, dist), parse_color(filter(isxdigit, color)))
end

# For fixing the commands in part 2
const hex_to_dir = Dict{Char, Char}('0' => 'R', '1' => 'D', '2' => 'L', '3' => 'U')
function fix_command(cmd)
    s = string(cmd.color[1], base=16, pad=2) * string(cmd.color[2], base=16, pad=2) * string(cmd.color[3], base=16, pad=2)
    DigCommand(hex_to_dir[s[end]], parse(Int64, s[1:5], base=16), (0, 0, 0))
end

# Load the input
parse_input(s) = DigCommand.(filter(x->length(x)>0, strip.(split(s, '\n'))))

# Turn the commands into vertices of a polygon
function commands_to_verts(cmds)
    verts = [(1, 1)]
    for cmd in cmds
        cmd.dir == 'D' && push!(verts, (verts[end][1] + cmd.dist, verts[end][2]))
        cmd.dir == 'U' && push!(verts, (verts[end][1] - cmd.dist, verts[end][2]))
        cmd.dir == 'R' && push!(verts, (verts[end][1], verts[end][2] + cmd.dist))
        cmd.dir == 'L' && push!(verts, (verts[end][1], verts[end][2] - cmd.dist))
    end
    verts
end

# Calc area of a polygon from verts
function triangle_formula(verts)
    n = length(verts)
    abs(sum(verts[i][2]*verts[(i%n)+1][1] - verts[i][1]*verts[(i%n)+1][2] for i in 1:n))÷2
end

# Find perimeter (manhattan distance since only U/R/D/L to keep things as ints)
function perimeter(verts)
    n = length(verts)
    sum(abs(verts[i][1]-verts[(i%n)+1][1]) + abs(verts[i][2]-verts[(i%n)+1][2]) for i in 1:n)
end

# Use Pick's thrm to find the points dug (interior plus the boundary)
function dug_area(verts)
    a = triangle_formula(verts)
    b = perimeter(verts)
    i = a - b÷2 + 1
    i + b
end

function day18(input::String = readInput(joinpath(@__DIR__, "data", "day18.txt")))
    commands = parse_input(input)
    [dug_area(commands_to_verts(commands)), dug_area(commands_to_verts(fix_command.(commands)))]  
end

end
