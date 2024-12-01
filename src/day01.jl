module Day01

INPUT_PATH = joinpath(@__DIR__, "../data/day01.txt")

DIGITS = Dict(
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9,
)

for i ∈ 1:9
    push!(DIGITS, "$(i)" => i)
end

parse_input(s) = split(s, "\n")

function get_calibration_value(line)
    nums = filter(isnumeric, line)
    return parse(Int, "$(first(nums))$(last(nums))")
end

function part1(input = read(INPUT_PATH, String))
    lines = parse_input(strip(input))
    sum(map(get_calibration_value, lines))
end

function get_calibration_value2(line)
    i_first, i_last = typemax(Int), typemin(Int)
    n_first, n_last = nothing, nothing
    for key ∈ keys(DIGITS)
        i = findfirst(key, line)
        if !isnothing(i) && first(i) < i_first
            i_first = first(i)
            n_first = DIGITS[key]
        end
        i = findlast(key, line)
        if !isnothing(i) && last(i) > i_last
            i_last = last(i)
            n_last = DIGITS[key]
        end
    end

    return 10*n_first + n_last
end

function part2(input = read(INPUT_PATH, String))
    lines = parse_input(strip(input))
    sum(map(get_calibration_value2, lines))
end

end