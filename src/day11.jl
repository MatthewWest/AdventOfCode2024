### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 25803ece-6274-40f3-89fa-03b77d3828df
using Combinatorics

# ╔═╡ 45bd7906-989d-11ee-2e1e-852311773d60
INPUT = read(joinpath(@__DIR__, "../data/day11.txt"), String);

# ╔═╡ c453228f-1600-4cde-a960-0133c13cb7fc
TEST_INPUT_1 = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""";

# ╔═╡ 25468c05-d8d3-4947-8c85-9da302e8f15c
function parse_input(input)
	lines = split(strip(input))
	cs = [c for l in lines for c in l]
	reshape(cs, (length(first(lines)), length(lines)))
end

# ╔═╡ 8a8ae148-4826-422a-9a1b-9c123dd7621d
function Base.show(io::IO, m::Matrix{Char})
	(ysize, xsize) = size(m)
	print(io, '\n')
	for y in 1:ysize
		for x in 1:xsize
			print(io, m[y, x])
		end
		print(io, '\n')
	end
end

# ╔═╡ 5541f9e7-e149-4f36-9b40-ffe1b233eb27
function expand(m)
	empty_cols = filter(c -> all(isequal('.'), m[c, :]), axes(m, 1))
	all_cols = sort(vcat(empty_cols, 1:size(m, 1)))
	m = permutedims(stack(map(i -> m[i, :], all_cols)), (2, 1))
	empty_rows = filter(r -> all(isequal('.'), m[:, r]), axes(m, 2))
	all_rows = sort(vcat(empty_rows, 1:size(m, 2)))
	m = permutedims(stack(map(i -> m[:, i], all_rows)), (2, 1))
end

# ╔═╡ 671dc692-7391-43ac-8ac0-66e57c18ed16
function part1(input = INPUT)
	m = expand(parse_input(input))

	asteroids = findall(isequal('#'), m)
	total = 0
	for (a, b) in combinations(asteroids, 2)
		total += abs(a[1] - b[1]) + abs(a[2] - b[2])
	end
	total
end

# ╔═╡ 86e05dad-7a82-4391-a5de-333b481a9184
part1(TEST_INPUT_1)

# ╔═╡ 277cc221-c0d3-40e2-9610-b594876eb1b3
function all_pairs_distance(m, k)
	empty_cols = filter(c -> all(isequal('.'), m[c, :]), axes(m, 1))
	empty_rows = filter(r -> all(isequal('.'), m[:, r]), axes(m, 2))

	asteroids = findall(isequal('#'), m)
	total = 0
	for (a, b) in combinations(asteroids, 2)
		ax, ay = a[1], a[2]
		bx, by = b[1], b[2]
		xrange = min(ax, bx):max(ax, bx)
		yrange = min(ay, by):max(ay, by)
		expanded_cols = count(in(xrange), empty_cols)
		expanded_rows = count(in(yrange), empty_rows)
		d = abs(ax - bx) + abs(ay - by) + expanded_cols*(k-1) + expanded_rows*(k-1)
		total += d
	end
	total
end

# ╔═╡ 4c34dd5a-7f6a-47c2-bbc5-c69c5b8dc76c
function part2(input = INPUT)
	m = parse_input(input)
	all_pairs_distance(m, 1_000_000)
end

# ╔═╡ 8050364e-cd2a-4df2-aae9-b8211970708a
part2()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Combinatorics = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"

[compat]
Combinatorics = "~1.0.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "a34c01fbfb27d6e0d36b092741eb5c2684bd02ab"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"
"""

# ╔═╡ Cell order:
# ╠═45bd7906-989d-11ee-2e1e-852311773d60
# ╠═c453228f-1600-4cde-a960-0133c13cb7fc
# ╠═25468c05-d8d3-4947-8c85-9da302e8f15c
# ╠═8a8ae148-4826-422a-9a1b-9c123dd7621d
# ╠═5541f9e7-e149-4f36-9b40-ffe1b233eb27
# ╠═25803ece-6274-40f3-89fa-03b77d3828df
# ╠═671dc692-7391-43ac-8ac0-66e57c18ed16
# ╠═86e05dad-7a82-4391-a5de-333b481a9184
# ╠═277cc221-c0d3-40e2-9610-b594876eb1b3
# ╠═4c34dd5a-7f6a-47c2-bbc5-c69c5b8dc76c
# ╠═8050364e-cd2a-4df2-aae9-b8211970708a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
