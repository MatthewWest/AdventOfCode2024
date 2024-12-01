module Day02

INPUT_PATH = joinpath(@__DIR__, "../data/day02.txt")

struct Round
    green::Int
    blue::Int
    red::Int
end

struct Game
    game::Int
    rounds::Vector{Round}
end

function parse_input(s)
    games = Game[]
    for line ∈ split(strip(s), "\n")
        game, s_rounds = split(line, ':')
        game_num = parse(Int, match(r"Game ([0-9]+)", game).captures[1])
        rounds = Round[]
        for round ∈ split(s_rounds, ';')
            m_red = match(r"([0-9]+) red", round)
            red = isnothing(m_red) ? 0 : parse(Int, m_red.captures[1])
            m_blue = match(r"([0-9]+) blue", round)
            blue = isnothing(m_blue) ? 0 : parse(Int, m_blue.captures[1])
            m_green = match(r"([0-9]+) green", round)
            green = isnothing(m_green) ? 0 : parse(Int, m_green.captures[1])
            push!(rounds, Round(green, blue, red))
        end
        push!(games, Game(game_num, rounds))
    end
    games
end

function ispossible(round::Round)
    round.red <= 12 && round.blue <= 14 && round.green <= 13
end

function ispossible(game::Game)
    all(ispossible, game.rounds)
end

function part1(input = read(INPUT_PATH, String))
    games = parse_input(input)
    map(g -> g.game, filter(ispossible, games)) |> sum
end

function power(game::Game)
    max_green = map(r -> r.green, game.rounds) |> maximum
    max_blue = map(r -> r.blue, game.rounds) |> maximum
    max_red = map(r -> r.red, game.rounds) |> maximum
    max_green * max_blue * max_red
end

function part2(input = read(INPUT_PATH, String))
    games = parse_input(input)
    map(power, games) |> sum
end

end