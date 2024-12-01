### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 71a021ee-9718-11ee-2338-7d62a023e776
INPUT = read(joinpath(@__DIR__, "../data/day10.txt"), String);

# ╔═╡ 12619900-7039-4e06-bc67-6bf7e297df8a
struct Map
	chars::Matrix{Char}
	indices
end

# ╔═╡ 65e9c890-460a-4567-b49c-1e220ead9501
function tounicode(c::Char)
	if c == '7'
		return '┓'
	elseif c == 'J'
		return '┛'
	elseif c == 'L'
		return '┗'
	elseif c == '|'
		return '┃'
	elseif c == '-'
		return '━'
	elseif c == 'F'
		return '┏'
	else
		return c
	end
end

# ╔═╡ 62066673-a4bd-44ee-bc55-3bd2485c1e75
function Base.show(io::IO, m::Map)
	(ysize, xsize) = size(m.chars)
	for y in 1:ysize
		for x in 1:xsize
			print(io, tounicode(m.chars[x, y]))
		end
		print(io, '\n')
	end
end

# ╔═╡ b35cae47-9bb4-4e03-a7e9-9eeeabe57240
function parse_input(s)
	lines = split(strip(s), '\n')
	height = length(lines)
	width = length(lines[1])
	map = Matrix{Char}(undef, height, width)
	chars = [c for l in lines for c in l]
	chars = reshape(chars, (width, height))
	Map(chars, CartesianIndices(chars))
end

# ╔═╡ 849a28e6-25a9-4194-8902-a712edf32b48
TEST_INPUT_1 = """
.....
.S-7.
.|.|.
.L-J.
.....
""";

# ╔═╡ 187850c7-ac7b-4a63-a5be-5d7e062d9044
TEST_MAP_1 = parse_input(TEST_INPUT_1)

# ╔═╡ 75f7c8d7-df04-4d17-807d-5e46199896aa
TEST_INPUT_2 = """
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
""";

# ╔═╡ a491dc2d-aa58-4f87-9947-b2536f52a8f7
TEST_MAP_2 = parse_input(TEST_INPUT_2)

# ╔═╡ a04d33ed-166a-444b-9dd7-f634c048480e
const δ_ns = CartesianIndex(0, 1)

# ╔═╡ 26529426-bef8-4499-9329-3b2fad1f44df
north(i::CartesianIndex{2}) = i - δ_ns

# ╔═╡ 6d13e470-aee0-4fe8-9bba-3d5e6ec87d46
south(i::CartesianIndex{2}) = i + δ_ns

# ╔═╡ a31e8b61-05d2-46e2-830b-58fb499d7c06
const δ_ew = CartesianIndex(1, 0)

# ╔═╡ 59e74f49-05c5-4a5a-8752-f0d0b016587b
east(i::CartesianIndex{2}) = i + δ_ew

# ╔═╡ 8ef41ff4-587d-4c3b-9ac4-79a33e9c637c
west(i::CartesianIndex{2}) = i - δ_ew

# ╔═╡ 5be997cc-7cb3-4528-b951-8dd682061be0
function connections(map::Map, i::CartesianIndex{2})
	c = map.chars[i]
	if c == '|'
		return filter(a -> a in map.indices, [north(i), south(i)])
	elseif c == '-'
		return filter(a -> a in map.indices, [west(i), east(i)])
	elseif c == 'L'
		return filter(a -> a in map.indices, [north(i), east(i)])
	elseif c == 'J'
		return filter(a -> a in map.indices, [north(i), west(i)])
	elseif c == '7'
		return filter(a -> a in map.indices, [west(i), south(i)])
	elseif c == 'F'
		return filter(a -> a in map.indices, [east(i), south(i)])
	elseif c == '.'
		return []
	elseif c == 'S'
		# Unknown - I'm going to hope this isn't needed.
	else
		error("Unrecognized character $c at index $i.")
	end
end

# ╔═╡ b3cc28f1-9806-4e3e-afe7-1cc3d3d215c7
function Base.findall(f::F, map::AbstractArray{String}) where F<:Function
	indices = Tuple{Int, Int}[]
	for (i, line) in enumerate(map)
		xs = findall(f, line)
		push!(indices, (i, x) for x in xs)
	end
	indices
end

# ╔═╡ d3604ff4-ed6d-4a9e-aa05-ea3011c7ce11
function find_loop(map)
	start = only(findall(isequal('S'), map.chars))
	neighbors = filter(
		a -> a in map.indices,
		[west(start), north(start), east(start), south(start)])
	filter!(i -> start ∈ connections(map, i), neighbors)
	prev = start
	i = neighbors[1]
	loop = CartesianIndex{2}[]
	while i != start
		try
			nexts = connections(map, i)
			next = only(filter(j -> j != prev, nexts))
			push!(loop, i)
			prev = i
			i = next
		catch
			@error "At $i, could not find any connections"
			break
		end
	end
	loop
end

# ╔═╡ fc133963-c6e0-4c1e-b023-d0eed0a7aab0
function part1(input = INPUT)
	map = parse_input(input)
	loop = find_loop(map)
	length(loop) ÷ 2 + 1
end

# ╔═╡ 34f56a9f-03d6-4311-bd60-1baece056267
part1()

# ╔═╡ 3113f45a-b38e-4e38-b9b6-8ce615881d4c
function simplify_map(map, loop)
	map2 = Map(copy(map.chars), CartesianIndices(map.chars))
	for I in map2.indices
		if I ∉ loop
			map2.chars[I] = '.'
		end
	end
	map2
end

# ╔═╡ 742e69a9-a11d-40c0-ae54-7b15535aad81
function expand(m, path)
	m = simplify_map(m, path)
	m2_chars = fill(' ', (size(m.chars) .* 2) .+ 1)
	
	m2 = Map(m2_chars, CartesianIndices(m2_chars))
	# Fill the '.' chars to find
	for I in m.indices
		if m.chars[I] == '.'
			m2.chars[I*2] = '.'
		end
	end

	path = vcat(path, [first(path)])
	for i in 2:length(path)
		a, b = path[i-1] * 2, path[i] * 2
		for j in min(a, b):max(a, b)
			m2.chars[j] = '*'
		end
	end
	m2
end

# ╔═╡ 152d4fd0-d9d9-4cc2-8aeb-d6a78db2b487
const δs = [CartesianIndex(1, 0), CartesianIndex(-1, 0), CartesianIndex(0, 1), CartesianIndex(0, -1)]

# ╔═╡ ac867cbc-c4cf-4487-b041-3aa22443d3b6
function count_outside_dots(m)
	seen = Set{CartesianIndex{2}}()
	q = [CartesianIndex(1, 1)]
	n = 0
	while !isempty(q)
		cur = pop!(q)
		if m.chars[cur] == '.'
			n += 1
		end
		neighbors = filter(i -> in(i, m.indices) && m.chars[i] != '*', [cur + δ for δ in δs])
		new_neighbors = filter(∉(seen), neighbors)
		if length(new_neighbors) > 0
			push!(q, new_neighbors...)
			push!(seen, new_neighbors...)
		end
	end
	n
end

# ╔═╡ 3d4d2bd2-a005-44e3-89b6-31c90f99573c
function get_expanded_map(input)
	map = parse_input(input)
	start = only(findall(isequal('S'), map.chars))
	loop = vcat([start], find_loop(map))
	expand(map, loop)
end

# ╔═╡ a29ef616-3345-4545-a076-612bef51fccf
function part2(input = INPUT)
	map = parse_input(input)
	start = only(findall(isequal('S'), map.chars))
	loop = vcat([start], find_loop(map))
	
	map = expand(map, loop)
	total_dots = count(isequal('.'), map.chars)
	outside_dots = count_outside_dots(map)
	total_dots - outside_dots
end

# ╔═╡ cfccbd7b-366a-4cd3-aa89-a7ea5932d3dd
part2()

# ╔═╡ Cell order:
# ╠═71a021ee-9718-11ee-2338-7d62a023e776
# ╠═12619900-7039-4e06-bc67-6bf7e297df8a
# ╠═65e9c890-460a-4567-b49c-1e220ead9501
# ╠═62066673-a4bd-44ee-bc55-3bd2485c1e75
# ╠═b35cae47-9bb4-4e03-a7e9-9eeeabe57240
# ╠═849a28e6-25a9-4194-8902-a712edf32b48
# ╠═187850c7-ac7b-4a63-a5be-5d7e062d9044
# ╠═75f7c8d7-df04-4d17-807d-5e46199896aa
# ╠═a491dc2d-aa58-4f87-9947-b2536f52a8f7
# ╠═a04d33ed-166a-444b-9dd7-f634c048480e
# ╠═26529426-bef8-4499-9329-3b2fad1f44df
# ╠═6d13e470-aee0-4fe8-9bba-3d5e6ec87d46
# ╠═a31e8b61-05d2-46e2-830b-58fb499d7c06
# ╠═59e74f49-05c5-4a5a-8752-f0d0b016587b
# ╠═8ef41ff4-587d-4c3b-9ac4-79a33e9c637c
# ╠═5be997cc-7cb3-4528-b951-8dd682061be0
# ╠═b3cc28f1-9806-4e3e-afe7-1cc3d3d215c7
# ╠═d3604ff4-ed6d-4a9e-aa05-ea3011c7ce11
# ╠═fc133963-c6e0-4c1e-b023-d0eed0a7aab0
# ╠═34f56a9f-03d6-4311-bd60-1baece056267
# ╠═3113f45a-b38e-4e38-b9b6-8ce615881d4c
# ╠═742e69a9-a11d-40c0-ae54-7b15535aad81
# ╠═152d4fd0-d9d9-4cc2-8aeb-d6a78db2b487
# ╠═ac867cbc-c4cf-4487-b041-3aa22443d3b6
# ╠═3d4d2bd2-a005-44e3-89b6-31c90f99573c
# ╠═a29ef616-3345-4545-a076-612bef51fccf
# ╠═cfccbd7b-366a-4cd3-aa89-a7ea5932d3dd
