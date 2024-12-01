module Day03

INPUT_PATH = joinpath(@__DIR__, "../data/day03.txt")

struct Num
    value::Int
    pos::Set{Tuple{Int, Int}}
end

struct Symbol
    x::Int
    y::Int
    value::Char
end

struct Map
    nums::Vector{Num}
    syms::Vector{Symbol}
end

function parse_input(s)
    s = strip(s)
    nums = Num[]
    syms = Symbol[]
    for (y, line) ∈ enumerate(split(s, '\n'))
        innumber = false
        partialnum = Char[]
        numstart = nothing
        numend = nothing
        for (x, char) ∈ enumerate(line)
            if isnumeric(char)
                if !innumber
                    numstart = x
                    innumber = true
                end
                push!(partialnum, char)
            else
                if innumber
                    numend = x - 1
                    numrange = numstart:numend
                    push!(nums, Num(parse(Int, line[numrange]), Set([(x_, y) for x_ in numrange])))
                    innumber = false
                    numstart = nothing
                    numend = nothing
                end
            end
            if !isnumeric(char) && char != '.'
                push!(syms, Symbol(x, y, char))
            end
        end
        # If we were in a number at the end of the line, handle it.
        if innumber
            numend = length(line)
            numrange = numstart:numend
            push!(nums, Num(parse(Int, line[numrange]), Set([(x_, y) for x_ in numrange])))
            innumber = false
            numstart = nothing
            numend = nothing
        end
    end
    return Map(nums, syms)
end

function adjacents(pos::Tuple{Int, Int})
    adjs = Set{Tuple{Int, Int}}()
    for δx ∈ (-1, 0, 1)
        for δy ∈ (-1, 0, 1)
            push!(adjs, (pos[1] + δx, pos[2] + δy))
        end
    end
    adjs
end

function symboladjacencts(map::Map)
    adjs = Set{Tuple{Int, Int}}()
    for symbol ∈ map.syms
        union!(adjs, adjacents((symbol.x, symbol.y)))
    end
    adjs
end

function part1(input = read(INPUT_PATH, String))
    m = parse_input(input)
    adj = symboladjacencts(m)
    partnums = filter(n -> !isdisjoint(adj, n.pos), m.nums)
    map(n -> n.value, partnums) |> sum
end

function part2(input = read(INPUT_PATH, String))
    m = parse_input(input)
    potential_gears = filter(s -> s.value == '*', m.syms)
    gear_powers = Int[]
    for pg ∈ potential_gears
        adjacent_positions = adjacents((pg.x, pg.y))
        adjacent_nums = filter(n -> !isdisjoint(n.pos, adjacent_positions), m.nums)
        if length(adjacent_nums) == 2
            push!(gear_powers, adjacent_nums[1].value * adjacent_nums[2].value)
        end
    end
    sum(gear_powers)
end

end