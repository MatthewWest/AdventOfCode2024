### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 842a1300-8f4b-4ecb-8b5d-c621487de5de
using BenchmarkTools

# ╔═╡ 2ea96638-9586-11ee-2e74-2909e60f5c05
md"""
# Advent of Code Day 8, 2023
"""

# ╔═╡ f22bcb8a-1f69-4b9c-baa7-27a8767407ed
INPUT = read(joinpath(@__DIR__, "../data/day08.txt"), String);

# ╔═╡ d13e6d03-0c7f-4258-bf52-8c35f3203412
function parse_input(s)
	connections = Dict{String, Tuple{String, String}}()
	directions, lines...  = split(strip(s), '\n')
	for line in lines[2:end]
		key, rest = split(line, '=')
		l, r = match(r"([A-Z0-9]{3}), ([A-Z0-9]{3})", rest).captures
		connections[strip(key)] = (l, r)
	end
	directions, connections
end

# ╔═╡ 66fdb7ef-4d13-45f9-bd81-3ddd3ec9db65
md"""
Part 1 asks us to find how many steps it takes (when following the directions dictated in the input) to find a path from "AAA" to "ZZZ"). We do this by simply resolving each step of the directions until we get to the target.
"""

# ╔═╡ c29deb3f-28e5-4fd9-a5c2-f1ac2240541d
function next(connections, cur, dir)
	l, r = connections[cur]
	if dir == 'L'
		l
	else
		r
	end
end

# ╔═╡ 30d84c11-b592-49ba-b0a3-077277099b61
function part1(input = INPUT)
	directions, connections = parse_input(input)
	node = "AAA"
	i = 0
	for c in Iterators.cycle(directions)
		node = next(connections, node, c)
		i += 1
		if node == "ZZZ"
			return i
		end
	end
end

# ╔═╡ 2757806b-c9e7-483e-9872-8bf8c1e61571
@btime part1()

# ╔═╡ 850eccc8-c603-4916-8545-48a58f7e8fa3
md"""
Part 2 asks us to consider *every* node ending in 'A', and follow the directions starting at each of those points, until we reach a step where every one of the nodes we're on ends in 'Z'.

We can first determine how many starting points we have, and how many possible endpoints.
"""

# ╔═╡ 71b71930-4b0a-4d98-b48f-1ed47dc48231
begin
	directions, connections = parse_input(INPUT)
	numA = count(endswith("A"), collect(keys(connections)))
	numZ = count(endswith("Z"), collect(keys(connections)))
	numA, numZ
end

# ╔═╡ 215c8ec3-d5e1-42fb-ab92-61044ec20c3f
md"""
We can see that there are 6 startpoints, and 6 possible endpoints. Note that the answer we got from the first part, 18,113, is one of these paths.

It's probably a safe bet that all 6 of the paths that start at 'A' nodes won't take exactly 18,113 steps to get to a 'Z' node. So we need to figure out two things:

- how many steps does it take to get from each 'A' node to a 'Z' node?
- once at a 'Z' node, how many steps does it take to get from each 'Z' node back to a 'Z' node?

Since we'll need to calculate path length multiple times, let's write a `pathlength` function.
"""

# ╔═╡ 49ec7e3e-6902-46c2-8046-bd6d9688329e
function pathlength(directions, connections, start, endpoints)
	node = start
	n = 0
	for c in Iterators.cycle(directions)
		node = next(connections, node, c)
		n += 1
		if node in endpoints
			return n
		end
	end
end

# ╔═╡ c5f2419b-31b4-4cf2-ae92-1697fa55b8e8
md"""
We can confirm that this pathlength function works by redoing part 1 using it:
"""

# ╔═╡ ae77a773-3bbb-4ea6-9ffc-f31672090da7
begin
	start = "AAA"
	endpoints = Set(["ZZZ"])
	pathlength(directions, connections, start, endpoints)
end

# ╔═╡ 695d3b2e-2d3f-437a-a017-23ea8ae1fe57
md"""
To be fully general, we need to determine the pathlength from each 'A' to a 'Z', ensure that it is an even multiple of the directions' length, then determine the pathlength from each 'Z' to another 'Z'.

Then, the total time taken to have all 6 paths on a 'Z' node will be the least common multiple of the pathlengths from A to Z and the path lengths from Z to Z.
"""

# ╔═╡ f4a0a179-2cd9-4742-bdbc-a99d9cb328bd
begin
	As = filter(endswith("A"), collect(keys(connections)))
	Zs = filter(endswith("Z"), collect(keys(connections)))
	zset = Set(Zs)
	a_to_z_lengths = sort([pathlength(directions, connections, a, zset) for a in As])
	z_to_z_lengths = sort([pathlength(directions, connections, z, zset) for z in Zs])
	a_to_z_lengths, z_to_z_lengths
end

# ╔═╡ 22b3479d-692a-42b6-a867-b983f4376071
md"""
By inspection, we can see that the path lengths from A to Z nodes are the same as the path lengths from Z to Z nodes. This wasn't an intrinsic property of the puzzle, but it does mean that we could have only calculated the pathlength from A to Z and still gotten the right answer.

We should also check to make sure that each of these pathlengths are evenly divisible by the length of the directions string, to make sure that we calculated the Z to Z pathlengths correctly (note: if A to Z pathlengths weren't an even multiple of the length of the directions string, we would have had to start calculating the path from Z to Z with an offset).
"""

# ╔═╡ 3a1d1b94-cad2-4e77-930b-97bcc07b3003
a_to_z_lengths .% length(directions)

# ╔═╡ fdc4352d-06a5-442b-830e-9853ea88260d
z_to_z_lengths .% length(directions)

# ╔═╡ e6c2744d-f80b-46c7-80ef-54682f36b0c4
md"""
Finally we need to put it all together. Since the set of lengths from A to Z is the same as from Z to Z, we can just calculate A to Z lengths, then find the least common multiple of those cycle lengths. That will find us the first time in the future when all the cycles will have completed an even number of times (e.g. be at a Z node).
"""

# ╔═╡ c3f8c2aa-5fb0-48ae-a629-d297c2836858
function part2(input = INPUT)
	directions, connections = parse_input(INPUT)
	As = filter(endswith("A"), collect(keys(connections)))
	Zs = filter(endswith("Z"), collect(keys(connections)))
	zset = Set(Zs)
	a_to_z_lengths = sort([pathlength(directions, connections, a, zset) for a in As])
	lcm(a_to_z_lengths)
end

# ╔═╡ 312fcea7-3a8c-4220-b03c-9f2e3761d9a4
@btime part2()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"

[compat]
BenchmarkTools = "~1.4.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "3a738398956e02c7245c3a0e85a5368c59e778d8"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1f03a9fa24271160ed7e73051fba3c1a759b53f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.4.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─2ea96638-9586-11ee-2e74-2909e60f5c05
# ╠═842a1300-8f4b-4ecb-8b5d-c621487de5de
# ╠═f22bcb8a-1f69-4b9c-baa7-27a8767407ed
# ╠═d13e6d03-0c7f-4258-bf52-8c35f3203412
# ╟─66fdb7ef-4d13-45f9-bd81-3ddd3ec9db65
# ╠═c29deb3f-28e5-4fd9-a5c2-f1ac2240541d
# ╠═30d84c11-b592-49ba-b0a3-077277099b61
# ╠═2757806b-c9e7-483e-9872-8bf8c1e61571
# ╟─850eccc8-c603-4916-8545-48a58f7e8fa3
# ╠═71b71930-4b0a-4d98-b48f-1ed47dc48231
# ╟─215c8ec3-d5e1-42fb-ab92-61044ec20c3f
# ╠═49ec7e3e-6902-46c2-8046-bd6d9688329e
# ╟─c5f2419b-31b4-4cf2-ae92-1697fa55b8e8
# ╠═ae77a773-3bbb-4ea6-9ffc-f31672090da7
# ╟─695d3b2e-2d3f-437a-a017-23ea8ae1fe57
# ╠═f4a0a179-2cd9-4742-bdbc-a99d9cb328bd
# ╟─22b3479d-692a-42b6-a867-b983f4376071
# ╠═3a1d1b94-cad2-4e77-930b-97bcc07b3003
# ╠═fdc4352d-06a5-442b-830e-9853ea88260d
# ╟─e6c2744d-f80b-46c7-80ef-54682f36b0c4
# ╠═c3f8c2aa-5fb0-48ae-a629-d297c2836858
# ╠═312fcea7-3a8c-4220-b03c-9f2e3761d9a4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
