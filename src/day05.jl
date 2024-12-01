module Day05

INPUT_PATH = joinpath(@__DIR__, "../data/day05.txt")

struct RangeMap
    dest_start::Int
    src_start::Int
    length::Int
end

struct Almanac
    seeds::Vector{Int}
    seed_to_soil::Vector{RangeMap}
    soil_to_fertilizer::Vector{RangeMap}
    fertilizer_to_water::Vector{RangeMap}
    water_to_light::Vector{RangeMap}
    light_to_temperature::Vector{RangeMap}
    temperature_to_humidity::Vector{RangeMap}
    humidity_to_location::Vector{RangeMap}
end

function parse_rangemap(line::AbstractString)
    RangeMap(map(s -> parse(Int, s), split(line))...)
end

function parse_input(s)
    sections = split(strip(s), "\n\n")
    s_seeds, maps = first(sections), sections[2:end]
    seeds = map(s_ -> parse(Int, s_), split(split(s_seeds, ':')[2]))
    s_to_s, s_to_f, f_to_w, w_to_l, l_to_t, t_to_h, h_to_l = maps

    seed_to_soil = map(parse_rangemap, split(s_to_s, '\n')[2:end])
    soil_to_fertilizer = map(parse_rangemap, split(s_to_f, '\n')[2:end])
    fertilizer_to_water = map(parse_rangemap, split(f_to_w, '\n')[2:end])
    water_to_light = map(parse_rangemap, split(w_to_l, '\n')[2:end])
    light_to_temperature = map(parse_rangemap, split(l_to_t, '\n')[2:end])
    temperature_to_humidity = map(parse_rangemap, split(t_to_h, '\n')[2:end])
    humidity_to_location = map(parse_rangemap, split(h_to_l, '\n')[2:end])

    Almanac(
        seeds,
        seed_to_soil,
        soil_to_fertilizer,
        fertilizer_to_water,
        water_to_light,
        light_to_temperature,
        temperature_to_humidity,
        humidity_to_location
    )
end

function resolve(val::Int, maps::Vector{RangeMap})
    for m ∈ maps
        srange = range(m.src_start, length=m.length)
        drange = range(m.dest_start, length=m.length)
        if val ∈ srange
            i = val - m.src_start + 1
            return drange[i]
        end
    end
    return val
end

function part1(input = read(INPUT_PATH, String))
    almanac = parse_input(input)
    soils = resolve.(almanac.seeds, Ref(almanac.seed_to_soil))
    fertilizers = resolve.(soils, Ref(almanac.soil_to_fertilizer))

    waters = resolve.(fertilizers, Ref(almanac.fertilizer_to_water))
    lights = resolve.(waters, Ref(almanac.water_to_light))
    temperatures = resolve.(lights, Ref(almanac.light_to_temperature))
    humidities = resolve.(temperatures, Ref(almanac.temperature_to_humidity))
    locations = resolve.(humidities, Ref(almanac.humidity_to_location))
    return minimum(locations)
end

function get_seeds_from_ranges(ranges::Vector{Int})
    seed_pairs = Base.Iterators.partition(ranges, 2)
    seed_ranges = map(pair -> pair[1]:pair[1]+pair[2]-1, seed_pairs)
    reduce(vcat, map(collect, seed_ranges))
end

function part2(input = read(INPUT_PATH, String))
    almanac = parse_input(input)
    
    seeds = collect(get_seeds_from_ranges(almanac.seeds))
    println("# seeds: $(length(seeds))")
    soils = resolve.(seeds, Ref(almanac.seed_to_soil))
    fertilizers = resolve.(soils, Ref(almanac.soil_to_fertilizer))
    waters = resolve.(fertilizers, Ref(almanac.fertilizer_to_water))
    lights = resolve.(waters, Ref(almanac.water_to_light))
    temperatures = resolve.(lights, Ref(almanac.light_to_temperature))
    humidities = resolve.(temperatures, Ref(almanac.temperature_to_humidity))
    locations = resolve.(humidities, Ref(almanac.humidity_to_location))
    return minimum(locations)
end

end
