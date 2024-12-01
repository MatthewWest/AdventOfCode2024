### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 5cabc1e7-192d-41fe-826f-51f3000696cf
using DataStructures

# ╔═╡ aebf202e-9ce8-11ee-39f8-8f4d38ffe877
INPUT = read(joinpath(@__DIR__, "../data/day17.txt"), String);

# ╔═╡ 4327fa0c-383f-47dc-9be7-6663acc5f508
function parse_input(s)
	"""Parse the input into a matrix of Ints, of size (rows, cols).
	
	Indexed by m[row, col].
	"""
	lines = split(strip(s), '\n')
	rows = length(lines)
	cols = length(first(lines))
	m = reshape(parse.(Int, [c for line in lines for c in line]), (rows, cols))
	return permutedims(m, (2, 1))
end

# ╔═╡ 0ecfa8ce-e5d4-4428-80dd-75ee0dcc8ae9
TEST_INPUT = """
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
""";

# ╔═╡ b0524aea-2e7e-460a-b7fa-f07f6f1e8f1a
@enum Direction N W S E

# ╔═╡ 4685c0ff-40b0-42d7-87d0-33940aa85813
struct State
	# A location, expressed as (row, col)
	loc::Tuple{Int, Int}
	dir::Direction
	# Momentum (how many squares in a straight line the crucible has moved).
	# Note: this will always be greater than 0 for any given 
	momentum::Int
end

# ╔═╡ 6dd5007c-47f8-4a3a-99ce-b6e4a0b076b3
function Base.hash(s::State, h::UInt)::UInt
	h1 = Base.hash(s.loc, h)
	h2 = Base.hash(s.dir, h1)
	return Base.hash(s.momentum, h2)
end

# ╔═╡ 669ec68a-aea6-4b32-9f2a-1215fa512cc0
function isequal(a::State, b::State)
	return a.loc == b.loc && a.dir == b.dir && a.momentum == b.momentum
end

# ╔═╡ b009d127-c887-4640-aa77-59db247cea5c
function left(dir::Direction)
	if dir == N
		W
	elseif dir == W
		S
	elseif dir == S
		E
	elseif dir == E
		N
	end
end

# ╔═╡ 000677bf-2c50-4184-8843-2906ed3d8b77
function right(dir::Direction)
	if dir == N
		E
	elseif dir == E
		S
	elseif dir == S
		W
	elseif dir == W
		N
	end
end

# ╔═╡ c33fa730-a7ed-42bf-b8c5-051cc76a1657
function one(dir::Direction)
	if dir == N
		(-1, 0)
	elseif dir == W
		(0, -1)
	elseif dir == S
		(1, 0)
	elseif dir == E
		(0, 1)
	else
		error("Unrecognized value $dir")
	end
end

# ╔═╡ 01ed0412-73e0-4b54-ad94-50574ac8dd2f
function inbounds(m, loc::Tuple{Int, Int})
	rows, cols = size(m)
	return loc[1] >= 1 && loc[1] <= rows && loc[2] >= 1 && loc[2] <= cols
end

# ╔═╡ 72c2eaf7-9a9c-4591-b7d5-e794f6dc934b
function neighbors(m, state::State)
	"""Find the possible moves from a given state.
	
	Coordinates are (row, col).
	"""
	rows, cols = size(m)
	ns = State[]

	left_dir = left(state.dir)
	left_loc = state.loc .+ one(left_dir)
	if inbounds(m, left_loc)
		push!(ns, State(left_loc, left_dir, 1))
	end

	right_dir = right(state.dir)
	right_loc = state.loc .+ one(right_dir)
	if inbounds(m, right_loc)
		push!(ns, State(right_loc, right_dir, 1))
	end
	
	straight_loc = state.loc .+ one(state.dir)
	if inbounds(m, straight_loc) && state.momentum < 3
		push!(ns, State(straight_loc, state.dir, state.momentum + 1))
	end
	return ns
end

# ╔═╡ 170a5c37-60d7-4a42-a5b8-2fbf4c106c1a
function h(m, state::State)
	(rows, cols) = size(m)
	abs(state.loc[1] - rows) + abs(state.loc[2] - cols)
end

# ╔═╡ 808b13b1-0702-4f3a-910a-5655d764e0db
function reconstruct_path(cameFrom, current)
	total_path = [current]
	while current in keys(cameFrom)
		current = cameFrom[current]
		pushfirst!(total_path, current)
	end
	return total_path
end

# ╔═╡ a58022b2-c887-4c4a-b6f7-eba1a7cf161d
d(m, current, neighbor) = m[neighbor.loc...]

# ╔═╡ 94b5b1ca-5a71-43da-a4af-4420987984c1
function AStar(m, f_neighbors, goal_set)
	(rows, cols) = size(m)

	start = State((1, 1), E, 0)
	openSet = PriorityQueue{State, Int}()
	enqueue!(openSet, start => 0)
	cameFrom = Dict{State, State}()
	gScore = Dict(start => 0)
	fScore = Dict(start => h(m, start))

	while !isempty(openSet)
		current = dequeue!(openSet)
		if current in goal_set
			return reconstruct_path(cameFrom, current)
		end

		ns = f_neighbors(m, current)
		for n in ns
			tentative_gScore = gScore[current] + d(m, current, n)
			if tentative_gScore < get(gScore, n, typemax(Int))
				# This path to neighbor is best. Record it
				cameFrom[n] = current
				gScore[n] = tentative_gScore
				fScore[n] = tentative_gScore + h(m, n)
				openSet[n] = fScore[n]
			end
		end
	end
	return costs[(rows, cols)]
end

# ╔═╡ 925debbb-50df-4f64-b364-7e786ad414f9
function part1(input = INPUT)
	m = parse_input(input)
	goal_set = Set([
		State(size(m), S, 1),
		State(size(m), S, 2),
		State(size(m), S, 3),
		State(size(m), E, 1),
		State(size(m), E, 2),
		State(size(m), E, 3),
	])
	path = AStar(m, neighbors, goal_set)
	total_cost = 0
	for step in path[2:end]
		total_cost += m[step.loc...]
	end
	total_cost
end

# ╔═╡ 1946ef45-306d-491f-b91b-67faa4897adc
part1()

# ╔═╡ 5d961f9b-80d5-4c36-9df1-1141a5a550b4
function ultracrucible_neighbors(m, state::State)
"""Find the possible moves from a given state.
	
	Coordinates are (row, col).
	"""
	rows, cols = size(m)
	ns = State[]

	left_dir = left(state.dir)
	left_loc = state.loc .+ one(left_dir)
	if inbounds(m, left_loc) && (state.momentum >= 4 || state.momentum == 0)
		push!(ns, State(left_loc, left_dir, 1))
	end

	right_dir = right(state.dir)
	right_loc = state.loc .+ one(right_dir)
	if inbounds(m, right_loc) && (state.momentum >= 4 || state.momentum == 0)
		push!(ns, State(right_loc, right_dir, 1))
	end
	
	straight_loc = state.loc .+ one(state.dir)
	if inbounds(m, straight_loc) && state.momentum < 10
		push!(ns, State(straight_loc, state.dir, state.momentum + 1))
	end
	ns
end

# ╔═╡ 278d968c-3226-4b22-b7b4-e5e57582a533
function part2(input = INPUT)
	m = parse_input(input)
	goals_list = State[]
	for i in 4:10
		for dir in [E, S]
			push!(goals_list, State(size(m), dir, i))
		end
	end
	goals = Set(goals_list)
	path = AStar(m, ultracrucible_neighbors, goals)
	total_cost = 0
	for step in path[2:end]
		total_cost += m[step.loc...]
	end
	total_cost
end

# ╔═╡ 5404e1b5-f2f3-499a-bed6-1e7f4ddb0f95
part2()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"

[compat]
DataStructures = "~0.18.15"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "afddc9afffcecddf8e73c1b53d6c212c657b17e6"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "886826d76ea9e72b35fcd000e535588f7b60f21d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.1"

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

    [deps.Compat.weakdeps]
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
"""

# ╔═╡ Cell order:
# ╠═5cabc1e7-192d-41fe-826f-51f3000696cf
# ╠═aebf202e-9ce8-11ee-39f8-8f4d38ffe877
# ╠═4327fa0c-383f-47dc-9be7-6663acc5f508
# ╠═0ecfa8ce-e5d4-4428-80dd-75ee0dcc8ae9
# ╠═b0524aea-2e7e-460a-b7fa-f07f6f1e8f1a
# ╠═4685c0ff-40b0-42d7-87d0-33940aa85813
# ╠═6dd5007c-47f8-4a3a-99ce-b6e4a0b076b3
# ╠═669ec68a-aea6-4b32-9f2a-1215fa512cc0
# ╠═b009d127-c887-4640-aa77-59db247cea5c
# ╠═000677bf-2c50-4184-8843-2906ed3d8b77
# ╠═c33fa730-a7ed-42bf-b8c5-051cc76a1657
# ╠═01ed0412-73e0-4b54-ad94-50574ac8dd2f
# ╠═72c2eaf7-9a9c-4591-b7d5-e794f6dc934b
# ╠═170a5c37-60d7-4a42-a5b8-2fbf4c106c1a
# ╠═808b13b1-0702-4f3a-910a-5655d764e0db
# ╠═a58022b2-c887-4c4a-b6f7-eba1a7cf161d
# ╠═94b5b1ca-5a71-43da-a4af-4420987984c1
# ╠═925debbb-50df-4f64-b364-7e786ad414f9
# ╠═1946ef45-306d-491f-b91b-67faa4897adc
# ╠═5d961f9b-80d5-4c36-9df1-1141a5a550b4
# ╠═278d968c-3226-4b22-b7b4-e5e57582a533
# ╠═5404e1b5-f2f3-499a-bed6-1e7f4ddb0f95
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
