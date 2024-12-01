module Day04

INPUT_PATH = joinpath(@__DIR__, "../data/day04.txt")

struct Card
    id::Int
    nums::Set{Int}
    wins::Set{Int}
end

function parse_input(s)
    cards = Card[]
    for line ∈ split(strip(s), '\n')
        id, rest = split(line, ':')
        s_nums, s_wins = split(rest, '|')
        nums = parse.(Int, split(s_nums)) |> Set{Int}
        wins = parse.(Int, split(s_wins)) |> Set{Int}
        push!(cards, Card(parse(Int, id[6:end]), nums, wins))
    end
    cards
end

function points(card::Card)
    num_wins = length(intersect(card.nums, card.wins))
    if num_wins == 0
        0
    else
        2 ^ (num_wins - 1)
    end
end

function part1(input = read(INPUT_PATH, String))
    cards = parse_input(input)
    points.(cards) |> sum
end

function part2(input = read(INPUT_PATH, String))
    cards = parse_input(input)
    n = length(cards)
    copies = ones(Int, n)
    for card ∈ cards
        matches = length(intersect(card.nums, card.wins))
        for i ∈ card.id+1:card.id+matches
            if i > n  # Bounds check
                continue
            end
            copies[i] += copies[card.id]
        end
    end
    sum(copies)
end

end