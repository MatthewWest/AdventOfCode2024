### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ d96598ff-501b-4d6c-be4d-d422b5634856
using Polynomials

# ╔═╡ 0ba81a34-9fbe-11ee-01e3-1f1ba0a1f13c
INPUT = read(joinpath(@__DIR__, "../data/day21.txt"), String);

# ╔═╡ e3209af1-c6ee-4b13-81b9-12e07877bd74
TEST_INPUT = """
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
""";

# ╔═╡ ddd4614e-31bf-4257-8412-526009869e7a
function Base.show(io::IO, mime::MIME"text/plain", m::Matrix{Char})
	(rows, cols) = size(m)
	for row in 1:rows
		for col in 1:cols
			print(io, m[row, col])
		end
		print(io, '\n')
	end
end

# ╔═╡ 79a81c60-dc50-440d-ab26-6e57b240e857
function Base.show(m::Matrix{Char})
	show(stdout, MIME("text/plain"), m)
end

# ╔═╡ 16924265-8479-49ff-b27e-d46f7514d9bc
function parse_input(s)
	s = strip(s)
	lines = split(s, '\n')
	rows, cols = length(lines), length(first(lines))
	m = fill(' ', (rows, cols))
	for (r, line) in enumerate(lines)
		for (c, char) in enumerate(line)
			m[r, c] = char
		end
	end
	start = only(findall(==('S'), m))
	m[start] = '.'
	m, start
end

# ╔═╡ ffa9ebc8-8c8d-4075-8ef4-c09c60b282f8
const δs = [CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0), CartesianIndex(-1,0)];

# ╔═╡ 3fb75437-2490-4d4c-925d-0c961e001530
neighbors(loc) = [loc + δ for δ in δs]

# ╔═╡ fc2dde7e-fa03-431c-a13a-b2ee1052a6d2
function next(m, locs)
	nextLocs = Set(CartesianIndex{2}[])
	for loc in locs
		for n in neighbors(loc)
			if !checkbounds(Bool, m, n)
				continue
			end
			if m[n] == '.'
				push!(nextLocs, n)
			end
		end
	end
	nextLocs
end

# ╔═╡ 0cbf664d-2ca6-4259-b75d-61e2df90da48
function part1(input = INPUT; n=64)
	m, start = parse_input(input)
	locs = Set([start])
	for i in 1:n
		locs = next(m, locs)
	end
	length(locs)
end

# ╔═╡ 9d2c29c5-3d59-494a-aa11-e17281661e39
part1()

# ╔═╡ 6446d61a-51ef-4708-8358-b8d87937ffcb
function count_steps_to_fill(m, start)
	locs = Set([start])
	ns = Int[]
	cycle_started = false
	for i in Iterators.countfrom(1)
		locs = next(m, locs)
		push!(ns, length(locs))
		if i > 2 && (ns[i] == ns[i-1] || ns[i] == ns[i-2])
			pop!(ns)
			return ns
		end
	end
end

# ╔═╡ 97f23862-f5eb-4905-9cb1-75efef894aa2
function count_steps_to_edge(m, start)
	(rows, cols) = size(m)
	locs = Set([start])
	reached_edge = false
	edges = union(CartesianIndices((1:1, 1:cols)),
			CartesianIndices((rows:rows, 1:cols)),
			CartesianIndices((1:rows, 1:1)),
			CartesianIndices((1:rows, cols:cols)))
	for i in Iterators.countfrom(1)
		locs = next(m, locs)
		if !isempty(intersect(locs, edges))
			return i, length(locs)
		end
	end
end

# ╔═╡ cfaa9616-e50b-4e53-955b-ff3572b10144
function part2(input = INPUT; n=26501365)
	m, start = parse_input(input)
	x1, y1 = count_steps_to_edge(m, start)
	m3 = repeat(m, 3, 3)
	x3, y3 = count_steps_to_edge(m3, start + CartesianIndex(size(m)))
	m5 = repeat(m, 5, 5)
	x5, y5 = count_steps_to_edge(m5, start + 2*CartesianIndex(size(m)))
	xs = [x1, x3, x5]
	ys = [y1, y3, y5]
	poly = fit(Polynomial{BigFloat}, xs, ys)
	sol = poly(n)
	@show sol - floor(sol)
	sol |> floor |> BigInt
end

# ╔═╡ 521b0cee-8d25-4e01-b6e5-1e104fd98c70
part2()

# ╔═╡ d92a4048-7572-41c8-a790-d4c8eb762140
md"""
This solution is a bit unintuitive to me. [This Reddit post](https://www.reddit.com/r/adventofcode/comments/18ofc8i/2023_day_21_part_2_intuition_behind_solution/) explains it pretty well.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Polynomials = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"

[compat]
Polynomials = "~4.0.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "7381ac5aaa15eb3c740162ba758190bd28e78843"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

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

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase", "Setfield", "SparseArrays"]
git-tree-sha1 = "a9c7a523d5ed375be3983db190f6a5874ae9286d"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "4.0.6"

    [deps.Polynomials.extensions]
    PolynomialsChainRulesCoreExt = "ChainRulesCore"
    PolynomialsFFTWExt = "FFTW"
    PolynomialsMakieCoreExt = "MakieCore"
    PolynomialsMutableArithmeticsExt = "MutableArithmetics"

    [deps.Polynomials.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
    MakieCore = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
    MutableArithmetics = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"

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

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

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
# ╠═0ba81a34-9fbe-11ee-01e3-1f1ba0a1f13c
# ╠═e3209af1-c6ee-4b13-81b9-12e07877bd74
# ╠═ddd4614e-31bf-4257-8412-526009869e7a
# ╠═79a81c60-dc50-440d-ab26-6e57b240e857
# ╠═16924265-8479-49ff-b27e-d46f7514d9bc
# ╠═ffa9ebc8-8c8d-4075-8ef4-c09c60b282f8
# ╠═3fb75437-2490-4d4c-925d-0c961e001530
# ╠═fc2dde7e-fa03-431c-a13a-b2ee1052a6d2
# ╠═0cbf664d-2ca6-4259-b75d-61e2df90da48
# ╠═9d2c29c5-3d59-494a-aa11-e17281661e39
# ╠═6446d61a-51ef-4708-8358-b8d87937ffcb
# ╠═d96598ff-501b-4d6c-be4d-d422b5634856
# ╠═97f23862-f5eb-4905-9cb1-75efef894aa2
# ╠═cfaa9616-e50b-4e53-955b-ff3572b10144
# ╠═521b0cee-8d25-4e01-b6e5-1e104fd98c70
# ╟─d92a4048-7572-41c8-a790-d4c8eb762140
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
