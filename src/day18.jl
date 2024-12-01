### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 7eee9918-9d64-11ee-3bf8-ab66be6a20d9
INPUT = read(joinpath(@__DIR__, "../data/day18.txt"), String);

# ╔═╡ f079bbcf-4d60-4a5d-bf40-20c0b8f26753
@enum Direction U D L R

# ╔═╡ d5cbe893-c9e3-4344-9a99-af560d3035f6
struct Instruction
	dir::Direction
	dist::Int
	color::Int
end

# ╔═╡ 9c905469-eb6d-4fea-b3bd-5224cfd66f21
function Base.parse(::Type{Direction}, s::AbstractString)
	if s == "U"
		U
	elseif s == "D"
		D
	elseif s == "L"
		L
	elseif s == "R"
		R
	else
		error("$s is not a valid Direction.")
	end
end

# ╔═╡ e274e452-b848-4d77-a2aa-6f49acb1958b
function Base.parse(::Type{Instruction}, s::AbstractString)
	instr_match = match(r"([UDLR]) ([0-9]+) \(#([0-9a-f]{6})\)", s)
	if isnothing(instr_match)
		error("Did not find the expected pattern to parse.")
	end

	dir, dist, color = instr_match.captures
	Instruction(parse(Direction, dir), parse(Int, dist), parse(Int, color; base=16))
end

# ╔═╡ 22b70da5-1278-4c55-adbe-a4d800f80704
function Base.show(io::IO, mime::MIME"text/plain", i::Instruction)
	print(io, i.dir)
	print(io, ' ')
	print(io, i.dist)
	print(io, " (#")
	print(io, string(i.color; base=16, pad=6))
	print(io, ")")
end

# ╔═╡ 2f29fa3a-a81f-4cea-a54a-8ddf2aef5f4c
function Base.show(io::IO, mime::MIME"text/plain", d::Dict{Tuple{Int, Int}, Char})
	locs = keys(d)
	rows, cols = first.(locs), last.(locs)
	rMin, rMax = extrema(rows)
	cMin, cMax = extrema(cols)
	for r in rMin:rMax
		for c in cMin:cMax
			print(io, get(d, (r, c), '.'))
		end
		print(io, "\n")
	end
end

# ╔═╡ 7ee1b838-35ed-4881-9283-81fe6e2ed6b9
function Base.show(io::IO, mime::MIME"text/html", d::Dict{Tuple{Int, Int}, Char})
	print(io, "<pre><code>")
	show(io, MIME"text/plain"(), d)
	print(io, "</code></pre>")
end

# ╔═╡ 07f9ac1d-d10b-4726-8641-b7d041a3d513
TEST_INPUT = """
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
""";

# ╔═╡ 56fb4d0d-3c0c-4a78-92d9-82716a1ee1f6
δs = Dict(
	U => (-1, 0),
	D => (1, 0),
	L => (0, -1),
	R => (0, 1),
)

# ╔═╡ d448847d-761a-4afa-bd2c-9b27b8fece9a
function apply!(m, instruction, pos)
	m[pos] = '#'
	for i in 1:instruction.dist
		pos = pos .+ δs[instruction.dir]
		m[pos] = '#'
	end
	pos
end

# ╔═╡ b148a2f1-dd9a-4f42-82b4-e970bb4bbde6
function interiorset(m, start)
	locs = keys(m)
	rows, cols = first.(locs), last.(locs)
	rMin, rMax = extrema(rows)
	cMin, cMax = extrema(cols)
	rRange = rMin:rMax
	cRange = cMin:cMax

	q = [start]
	seen = Set([(0, 0)])
	δs = [(0, 1), (0, -1), (-1, 0), (1, 0)]
	while !isempty(q)
		cur = popfirst!(q)
		if !(cur[1] in rRange && cur[2] in cRange)
			return Set{Tuple{Int, Int}}()
		end
		for δ ∈ δs
			n = cur .+ δ
			if n ∉ seen && get(m, n, '.') != '#'
				push!(q, n)
				push!(seen, n)
			end
		end
	end
	return seen
end

# ╔═╡ f4814260-4935-4105-a027-51c036f6ce49
function fill!(m)
	locs = keys(m)
	rows, cols = first.(locs), last.(locs)
	rMin = minimum(rows)
	rMinLocs = filter(l -> l[1] == rMin, keys(m))
	openAdjacents = filter(
		l -> get(m, l, '.') == '.',
	    [l .+ (1, 0) for l in rMinLocs]
	)

	interior = interiorset(m, openAdjacents[1])

	for loc in interior
		m[loc] = '#'
	end
end

# ╔═╡ 073f8087-5e7d-42ed-9dbf-2f3f6594ecf6
struct Instruction2
	dir::Direction
	dist::Int
end

# ╔═╡ 888f8629-54f4-41c8-bf26-99d6b1644f52
function dir_from_char(c)
	if c == "0"
		R
	elseif c== "1"
		D
	elseif c == "2"
		L
	elseif c == "3"
		U
	else
		error("unrecognized char $c")
	end
end

# ╔═╡ 44a75fce-79a7-48db-819f-ee45a5c0523c
function Base.parse(::Type{Instruction2}, s::AbstractString)
	instr_match = match(r"\(#([0-9a-f]{5})([0-9a-f])\)", s)
	if isnothing(instr_match)
		error("Did not find the expected pattern to parse.")
	end

	dist, dir = instr_match.captures
		
	Instruction2(dir_from_char(dir), parse(Int, dist; base=16))
end

# ╔═╡ d5addd06-8d17-4dea-bdb8-9e8e4014ce0a
function part1(s = INPUT)
	instructions = parse.(Instruction, split(strip(s), '\n'))
	m = Dict{Tuple{Int, Int}, Char}()
	pos = (0, 0)
	for i in instructions
		pos = apply!(m, i, pos)
	end
	fill!(m)
	count(isequal('#'), values(m))
end

# ╔═╡ 3676e693-538e-40e9-84ee-b213f437e1a0
part1(TEST_INPUT)

# ╔═╡ ee8c00bf-0a83-4ca6-ad59-2025f74831e7
part1()

# ╔═╡ 3844171c-1ef6-4706-b753-f7156263f2f4
function one(d::Direction)
	if d == R
		(0, 1)
	elseif d == L
		(0, -1)
	elseif d == U
		(-1, 0)
	elseif d == D
		(1, 0)
	end
end

# ╔═╡ b6a732cd-96a3-4811-9580-75e4ff9fa704
function apply(pos, instruction)
	pos .+ (one(instruction.dir) .* instruction.dist)
end

# ╔═╡ 8a3a47be-8f3a-4c93-9f1d-9e87d525be58
md"""
There are two key insights for this problem. One of them I arrived at by a Google search of how to determine the area inside an arbitrary polygon. The other, I arrived at by browsing the solutions thread on the AoC subreddit (specifically [this comment](https://www.reddit.com/r/adventofcode/comments/18l0qtr/2023_day_18_solutions/kdv385s/), which inspired me to look up Pick's Theorem).

Key insight #1 is that we can determine the area of the polygon formed by the "instructions" by using the Shoelace Method. I came across the Shoelace method while searching the internet for how to find the area of a polygon. Wikipedia has [a helpful article about it](https://en.wikipedia.org/wiki/Shoelace_formula).

Key insight #2 is that Pick's theorem can tell us how many integer-value points are contained within a polygon with integer vertex coordinates, given the area and the number of points on the boundary.

This feels like a gotcha question, where you have to know a specific theorem or fact in order to succeed in solving the puzzle.
"""

# ╔═╡ 671f5a55-9ef0-4e37-9c3a-5c4ab7de3014
function polygon_area(path)
	total = BigInt(0)
	for i in 1:length(path)-1
		p1 = path[i]
		p2 = path[i+1]
		total += (p1[1] + p2[1]) * (p1[2] - p2[2])
	end
	total / 2
end

# ╔═╡ d3652283-4ab7-41a2-98b0-e905230a7dad
function part2(s = INPUT)
	instructions = parse.(Instruction2, split(strip(s), '\n'))
	pos = (0, 0)
	path = [(0, 0)]
	for i in instructions
		pos = apply(pos, i)
		push!(path, pos)
	end
	b = sum(i -> i.dist, instructions)
	A = polygon_area(path)
	i = A - (b / 2) + 1
	BigInt(b + i)
end

# ╔═╡ 4112f8fb-133e-4024-892d-e30b1c0457ca
part2()

# ╔═╡ Cell order:
# ╠═7eee9918-9d64-11ee-3bf8-ab66be6a20d9
# ╠═f079bbcf-4d60-4a5d-bf40-20c0b8f26753
# ╠═d5cbe893-c9e3-4344-9a99-af560d3035f6
# ╠═9c905469-eb6d-4fea-b3bd-5224cfd66f21
# ╠═e274e452-b848-4d77-a2aa-6f49acb1958b
# ╠═22b70da5-1278-4c55-adbe-a4d800f80704
# ╠═2f29fa3a-a81f-4cea-a54a-8ddf2aef5f4c
# ╠═7ee1b838-35ed-4881-9283-81fe6e2ed6b9
# ╠═3676e693-538e-40e9-84ee-b213f437e1a0
# ╠═07f9ac1d-d10b-4726-8641-b7d041a3d513
# ╠═56fb4d0d-3c0c-4a78-92d9-82716a1ee1f6
# ╠═d448847d-761a-4afa-bd2c-9b27b8fece9a
# ╠═b148a2f1-dd9a-4f42-82b4-e970bb4bbde6
# ╠═f4814260-4935-4105-a027-51c036f6ce49
# ╠═d5addd06-8d17-4dea-bdb8-9e8e4014ce0a
# ╠═ee8c00bf-0a83-4ca6-ad59-2025f74831e7
# ╠═073f8087-5e7d-42ed-9dbf-2f3f6594ecf6
# ╠═888f8629-54f4-41c8-bf26-99d6b1644f52
# ╠═44a75fce-79a7-48db-819f-ee45a5c0523c
# ╠═3844171c-1ef6-4706-b753-f7156263f2f4
# ╠═b6a732cd-96a3-4811-9580-75e4ff9fa704
# ╟─8a3a47be-8f3a-4c93-9f1d-9e87d525be58
# ╠═671f5a55-9ef0-4e37-9c3a-5c4ab7de3014
# ╠═d3652283-4ab7-41a2-98b0-e905230a7dad
# ╠═4112f8fb-133e-4024-892d-e30b1c0457ca
