### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 915ef778-4ad1-4b03-99da-ba2e7d053a16
using BenchmarkTools

# ╔═╡ ae752c5e-8f82-4268-8b55-c7c7537171ae
using Memoize

# ╔═╡ bd3edbe0-98ad-11ee-18b0-a390fc510f44
INPUT = read(joinpath(@__DIR__, "../data/day12.txt"), String);

# ╔═╡ fc797b3c-2569-4092-a652-32b9e41c3e93
md"""
For memoization to work correctly, we must define the 2-argument hash function from Base, and the isequal function.
"""

# ╔═╡ 3b14e495-eb9a-4134-a6f7-f24d6038425f
struct Row
	springs::String
	counts::Vector{Int}
end

# ╔═╡ c59c5450-6e1e-4851-8668-3cb58e293300
function Base.hash(r::Row, h::UInt)
	h1 = Base.hash(r.springs, h)
	Base.hash(r.counts, h1)
end

# ╔═╡ 780264ab-2056-44ad-96f0-73a0197bb959
function Base.isequal(r1::Row, r2::Row)
	isequal(r1.springs, r2.springs) && isequal(r1.counts, r2.counts)
end

# ╔═╡ 45587c63-62f6-49a0-a427-8b26931ced6d
function parse_input(input)
	rows = Row[]
	for line in eachsplit(strip(input), '\n')
		springs, counts = split(line)
		push!(rows, Row(springs, parse.(Int, split(counts, ','))))
	end
	return rows
end

# ╔═╡ 398138fd-e2e9-48e7-8127-cb74bd32be07
@memoize Dict function possibilities(row::Row)
	springs, counts = row.springs, row.counts
	# Base case 1: No more broken spring groups
	if isempty(counts)
		# If there is a '#' left in springs, no possibility works.
		if '#' in springs
			return 0
		else
			# Otherwise all remaining '?' characters are '.'
			return 1
		end
	end

	# Base case 2: There are counts of broken springs left, but no more springs
	if isempty(springs)
		return 0
	end

	next_character = first(springs)
	next_count = first(counts)

	# logic for treating the first character as broken
	function broken()
		# There aren't enough springs left to match the next count.
		if length(springs) < next_count
			return 0
		end

		candidate_group = replace(springs[1:next_count], '?' => '#')
		# It isn't possible to have next_group broken springs starting here
		if !all(isequal('#'), candidate_group)
			return 0
		end

		# If there's only the characters for this group left
		if length(springs) == next_count
			if length(counts) == 1
				# This group of broken springs exactly finishes the groups.
				return 1
			else
				# There are more groups of broken springs that don't fit, so
				# this arrangement is impossible.
				return 0
			end
		end

		# Ensure that the group can have a valid separator (unknown or working)
		if springs[next_count+1] in ['?', '.']
			# Skip the group and the separator, and recurse.
			return possibilities(Row(springs[next_count+2:end], counts[2:end]))
		end

		# This character being broken doesn't fit.
		return 0
	end

	function working()
		return possibilities(Row(springs[2:end], counts))
	end

	if next_character == '#'
		out = broken()
	elseif next_character == '.'
		out = working()
	elseif next_character == '?'
		# This could be either broken or working, so we want the sum of the possibilities for each.
		out = broken() + working()
	else
		error("Found an unrecognized character $next_character")
	end

	return out
end

# ╔═╡ 786b82aa-2a86-4513-adc8-a6397b02e004
function part1(input = INPUT)
	rows = parse_input(input)
	sum(possibilities.(rows))
end

# ╔═╡ 31e5f8f8-aeea-4791-828b-16238974cd3d
@btime part1()

# ╔═╡ 57371449-0895-4678-8ed3-34d27da1e92b
function unfold(row::Row)
	springs = (row.springs * '?')^4 * row.springs
	counts = repeat(row.counts, 5)
	Row(springs, counts)
end

# ╔═╡ 9e5acf74-b702-415d-947f-16c51d287f35
function part2(input = INPUT)
	rows = unfold.(parse_input(input))
	sum(possibilities.(rows))
end

# ╔═╡ 6de73ae3-eb10-4798-b47d-a209f5a5d99f
@btime part2()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Memoize = "c03570c3-d221-55d1-a50c-7939bbd78826"

[compat]
BenchmarkTools = "~1.4.0"
Memoize = "~0.4.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "2a60ee8fcdbb868c4a6a9149788602e3bd0fc195"

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

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

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
# ╠═915ef778-4ad1-4b03-99da-ba2e7d053a16
# ╠═ae752c5e-8f82-4268-8b55-c7c7537171ae
# ╠═bd3edbe0-98ad-11ee-18b0-a390fc510f44
# ╟─fc797b3c-2569-4092-a652-32b9e41c3e93
# ╠═3b14e495-eb9a-4134-a6f7-f24d6038425f
# ╠═c59c5450-6e1e-4851-8668-3cb58e293300
# ╠═780264ab-2056-44ad-96f0-73a0197bb959
# ╠═45587c63-62f6-49a0-a427-8b26931ced6d
# ╠═398138fd-e2e9-48e7-8127-cb74bd32be07
# ╠═786b82aa-2a86-4513-adc8-a6397b02e004
# ╠═31e5f8f8-aeea-4791-828b-16238974cd3d
# ╠═57371449-0895-4678-8ed3-34d27da1e92b
# ╠═9e5acf74-b702-415d-947f-16c51d287f35
# ╠═6de73ae3-eb10-4798-b47d-a209f5a5d99f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
