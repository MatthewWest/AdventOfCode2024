### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 9ef5b60c-4dfb-4c06-abec-e7bb3a49f705
using BenchmarkTools

# ╔═╡ a00402b3-8010-4e5d-ac78-fb51e35a12d0
using Accessors

# ╔═╡ 0cc08564-a81f-4bcb-8899-b3041599ac7c
md"""
# Advent of Code 2023, Day 19

Part 1 of today's puzzle is to apply a set of rules as a filter to determine which of a list of parts are ultimately "Accepted". The primary challenge then is to model the problem in types, then apply those types to get the appropriate final result for each part.

In solving this problem, I've tried to use standard Julia functions where appropriate.
"""

# ╔═╡ 10814618-9e2c-11ee-30f7-bdcc50b1b020
INPUT = read(joinpath(@__DIR__, "../data/day19.txt"), String);

# ╔═╡ 285e3123-8526-402b-886d-14ef3ccf4caf
@enum Result A R

# ╔═╡ 451a5757-16c4-4f41-bed2-5152a3abb23a
struct Part
	x::Int
	m::Int
	a::Int
	s::Int
end

# ╔═╡ df7a6020-abf1-439c-94a8-e665ef232174
struct Rule
	field::Symbol
	comparator::Union{typeof(<), typeof(>)}
	value::Int
	result::Union{Result, AbstractString}
end

# ╔═╡ 49c92d0e-22ec-4cd7-a4d0-331a0e373015
struct Workflow
	label::AbstractString
	rules::Vector{Union{Rule, Result, AbstractString}}
end

# ╔═╡ 32976dbd-47e9-4489-867b-c67ae6382f86
md"""
I'm using a struct to represent each type used in the puzzle. I'm adding methods to the `parse` and `tryparse` functions defined in `Base`.
"""

# ╔═╡ ae2f4579-d4f1-4484-9ba0-756adbffefac
function Base.parse(::Type{Part}, s::AbstractString)
	part_match = match(r"^\{x=([0-9]+),m=([0-9]+),a=([0-9]+),s=([0-9]+)\}$", s)
	Part(parse.(Int, part_match.captures)...)
end

# ╔═╡ 826baf21-de2a-4031-ba39-938b4a1510e8
function Base.tryparse(::Type{Rule}, s::AbstractString)
	rule_match = match(r"([xmas])([<>])([0-9]+):([a-z]+|[AR])", s)
	if isnothing(rule_match)
		return nothing
	end
	field, s_comparator, s_val, s_result = rule_match.captures
	comparator = if s_comparator == "<"
		<
	else
		>
	end
	val = parse(Int, s_val)
	
	result::Union{Result, AbstractString} = if s_result == "A"
		A
	elseif s_result == "R"
		R
	else
		s_result
	end

	return Rule(Symbol(field), comparator, val, result)
end

# ╔═╡ c2f75646-d63e-427c-bd28-4914039ab2ac
function Base.parse(::Type{Workflow}, s::AbstractString)
	workflow_match = match(r"^([a-z]+)\{(.*)\}$", s)
	label, s_rules = workflow_match.captures
	rules = Union{Rule, Result, AbstractString}[]
	for s_rule in split(s_rules, ',')
		r = tryparse(Rule, s_rule)
		if !isnothing(r)
			push!(rules, r)
		else
			if s_rule == "R"
				push!(rules, R)
			elseif s_rule == "A"
				push!(rules, A)
			else
				push!(rules, s_rule)
			end
		end
	end
	return Workflow(label, rules)
end

# ╔═╡ 7dbc2e8b-3347-4b19-86f4-ceb83498c0ab
RuleSet = Dict{T, Workflow} where T <: AbstractString

# ╔═╡ 5e09ec39-411c-4c83-b607-1dafab12273a
function parse_input(s)
	s_workflows, s_parts = split(strip(s), "\n\n")
	workflows = [parse(Workflow, w) for w in split(s_workflows, '\n')]
	parts = [parse(Part, s_part) for s_part in split(s_parts, '\n')]
	Dict([w.label => w for w in workflows]), parts
end

# ╔═╡ b0d625aa-5839-4c20-93fa-3b059599493d
function apply(workflow::Workflow, part::Part)
	for rule in workflow.rules
		if rule isa Result
			return rule
		elseif rule isa AbstractString
			return rule
		elseif rule.comparator(getfield(part, rule.field), rule.value)
			return rule.result
		end
	end
end

# ╔═╡ 5acf8355-4fa4-4995-88b4-5d7886388f07
total(p::Part) = p.x + p.m + p.a + p.s

# ╔═╡ 3caa1b03-c829-4c36-b5c9-f92759f133d6
md"""
For part 2, we are asked to find how many parts can possibly satisfy the set of rules, where the valid range for each category of a part is `1:4000`. This means that the total number of parts to assess is $4000^4$, or 256,000,000,000,000 (256 trillion). Since part 1 runs in around 1 ms (on my computer), implementing this by trying every possible part would take roughly 256 billion seconds, or over 8,000 years. Therefore, we need a different approach.

This different approach is to simply keep track of each part range, so that each rule splits the range into either 1 or 2 groups (those that fulfill the rule's condition, and those that don't).

For this part, I defined a new struct to represent ranges of parts, and functions that operate on that type. Note that I also defined `Base.length` on PartRange.
"""

# ╔═╡ 7fd06f44-aa7c-427e-a8e7-95e68d882d6f
struct PartRange
	x::UnitRange{Int}
	m::UnitRange{Int}
	a::UnitRange{Int}
	s::UnitRange{Int}
end

# ╔═╡ e9fbf55f-70d0-4990-8fa1-6fdb3a3173e3
md"""
[Accessors.jl](https://github.com/JuliaObjects/Accessors.jl) is a library that allows updating the creation of slightly modified immutable objects (which Julia structs are by default). In this case, I'm using it to create PartRange objects which are bisected by each rule. That would be tedious to do otherwise (it would involve getting the value for each field out of the old range).
"""

# ╔═╡ 19cc417f-e44c-446e-acf0-48096d566897
function bisect(partRange::PartRange, rule::Rule)
	fieldLens = PropertyLens(rule.field)
	bisector = rule.value
	partFieldRange = getfield(partRange, rule.field)
	if rule.comparator == <
		matchStart = min(minimum(partFieldRange), bisector)
		matchEnd = bisector - 1
		notMatchStart = bisector
		notMatchEnd = max(maximum(partFieldRange), bisector-1)
		if matchStart <= matchEnd
			match = set(partRange, fieldLens, matchStart:matchEnd)
		else
			match = nothing
		end
		if notMatchStart <= notMatchEnd
			notMatch = set(partRange, fieldLens, notMatchStart:notMatchEnd)
		else
			notMatch = nothing
		end
		return match, notMatch
	elseif rule.comparator == >
		matchStart = bisector + 1
		matchEnd = max(maximum(partFieldRange), bisector)
		notMatchStart = min(minimum(partFieldRange), bisector+1)
		notMatchEnd = bisector
		if matchStart <= matchEnd
			match = set(partRange, fieldLens, matchStart:matchEnd)
		else
			match = nothing
		end
		if notMatchStart <= notMatchEnd
			notMatch = set(partRange, fieldLens, notMatchStart:notMatchEnd)
		else
			notMatch = nothing
		end
		return match, notMatch
	else
		error("Unexpected comparator $(rule.comparator).")
	end
end

# ╔═╡ 40088f80-1188-4cd4-838b-4c1d197695ec
function Base.length(r::PartRange)
	length(r.x) * length(r.m) * length(r.a) * length(r.s)
end

# ╔═╡ 3e76f9ae-25e6-4c48-b31f-dc9203c2ec0f
function apply(workflow::Workflow, partRange::PartRange)
	ranges = Pair{PartRange, Union{Result, AbstractString}}[]
	curRange = partRange
	for rule in workflow.rules
		if rule isa Result
			push!(ranges, curRange => rule)
		elseif rule isa AbstractString
			push!(ranges, curRange => rule)
		elseif rule isa Rule
			match, notMatch = bisect(curRange, rule)
			if !isnothing(match)
				push!(ranges, match => rule.result)
			end
			if !isnothing(notMatch)
				curRange = notMatch
			end
		end
	end
	ranges
end

# ╔═╡ 5ba0d8f0-a750-4b71-9f90-676637230a40
function process(workflows::RuleSet, part::Part)::Result
	workflow = workflows["in"]
	while true
		r = apply(workflow, part)
		if r isa Result
			return r
		elseif r isa AbstractString
			workflow = workflows[r]
		else
			error("Unrecognized rule type $r.")
		end
	end
end

# ╔═╡ c7ff32d2-f62b-4dcf-a655-cfe579f6b6f4
function part1(s = INPUT)
	ruleset, parts = parse_input(s)
	filter!(p -> isequal(A, process(ruleset, p)), parts)
	total.(parts) |> sum
end

# ╔═╡ cd79dd56-51db-4309-8151-62d40f6199cd
@btime part1()

# ╔═╡ 8b5088e8-d897-42ff-b8a5-7048eef73a94
function part2(s = INPUT)
	ruleset, _ = parse_input(s)
	ranges = Pair{PartRange, Union{AbstractString, Result}}[]
	push!(ranges, PartRange(1:4000, 1:4000, 1:4000, 1:4000) => "in")
	n_accepted = 0
	while !isempty(ranges)
		partRange, next = pop!(ranges)
		if next isa Result
			if next == A
				n_accepted += length(partRange)
			end
			continue
		end
		successors = apply(ruleset[next], partRange)
		push!(ranges, successors...)
	end
	n_accepted
end

# ╔═╡ 38b8b1a2-d3b7-47b4-b729-6ef605f26a98
@btime part2()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Accessors = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"

[compat]
Accessors = "~0.1.33"
BenchmarkTools = "~1.4.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "8de497eaf50841b25ac35803e9e9a8fe105a4607"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Test"]
git-tree-sha1 = "a7055b939deae2455aa8a67491e034f735dd08d3"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.33"

    [deps.Accessors.extensions]
    AccessorsAxisKeysExt = "AxisKeys"
    AccessorsIntervalSetsExt = "IntervalSets"
    AccessorsStaticArraysExt = "StaticArrays"
    AccessorsStructArraysExt = "StructArrays"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"

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

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "68772f49f54b479fa88ace904f6127f0a3bb2e46"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.12"

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

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
# ╟─0cc08564-a81f-4bcb-8899-b3041599ac7c
# ╠═10814618-9e2c-11ee-30f7-bdcc50b1b020
# ╠═285e3123-8526-402b-886d-14ef3ccf4caf
# ╠═451a5757-16c4-4f41-bed2-5152a3abb23a
# ╠═df7a6020-abf1-439c-94a8-e665ef232174
# ╠═49c92d0e-22ec-4cd7-a4d0-331a0e373015
# ╟─32976dbd-47e9-4489-867b-c67ae6382f86
# ╠═826baf21-de2a-4031-ba39-938b4a1510e8
# ╠═c2f75646-d63e-427c-bd28-4914039ab2ac
# ╠═ae2f4579-d4f1-4484-9ba0-756adbffefac
# ╠═7dbc2e8b-3347-4b19-86f4-ceb83498c0ab
# ╠═5e09ec39-411c-4c83-b607-1dafab12273a
# ╠═b0d625aa-5839-4c20-93fa-3b059599493d
# ╠═5ba0d8f0-a750-4b71-9f90-676637230a40
# ╠═5acf8355-4fa4-4995-88b4-5d7886388f07
# ╠═c7ff32d2-f62b-4dcf-a655-cfe579f6b6f4
# ╠═9ef5b60c-4dfb-4c06-abec-e7bb3a49f705
# ╠═cd79dd56-51db-4309-8151-62d40f6199cd
# ╟─3caa1b03-c829-4c36-b5c9-f92759f133d6
# ╠═7fd06f44-aa7c-427e-a8e7-95e68d882d6f
# ╟─e9fbf55f-70d0-4990-8fa1-6fdb3a3173e3
# ╠═a00402b3-8010-4e5d-ac78-fb51e35a12d0
# ╠═19cc417f-e44c-446e-acf0-48096d566897
# ╠═40088f80-1188-4cd4-838b-4c1d197695ec
# ╠═3e76f9ae-25e6-4c48-b31f-dc9203c2ec0f
# ╠═8b5088e8-d897-42ff-b8a5-7048eef73a94
# ╠═38b8b1a2-d3b7-47b4-b729-6ef605f26a98
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
