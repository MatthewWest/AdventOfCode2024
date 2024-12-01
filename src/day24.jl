### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 8650fd09-815a-4893-84b7-c3b707c5daec
using Combinatorics

# ╔═╡ 0a06363b-92d9-4642-9557-a9d532d7fc82
using JuMP, MadNLP

# ╔═╡ a166e6b2-a2a0-11ee-02e8-b39a047056c4
INPUT = read(joinpath(@__DIR__, "../data/day24.txt"), String);

# ╔═╡ 087489a9-fa66-444f-9108-2d4c9f699bec
struct Hail
	pos
	vel
end

# ╔═╡ 37fefe81-bb24-440d-8734-ac7f81b9871b
function parse_input(s)
	lines = split(strip(s), '\n')
	hailstones = Hail[]
	for line in lines
		pos, vel = split(line, '@')
		p = split(pos, ',') .|> strip .|> n -> parse(Int, n)
		v = split(vel, ',') .|> strip .|> n -> parse(Int, n)
		push!(hailstones, Hail(p, v))
	end
	hailstones
end

# ╔═╡ 6cafd11e-a15e-4c6d-aecf-2b5f7280ce53
md"""
Finding the intersections of two lines just requires a bit of algebra. When finding an interception between two hail lines, we have the following equations representing the lines:

$X = Vt + B$

All 3 of $X$, $V$, and $B$ are vectors with 2 elements.

To find where two lines intersect, we just set them equal (though not with the same independent variable - use $s$ and $t$).

$V_1s + B_1 = V_2t + B_2$
$V_1s - V_2t = -B_1 + B_2$

We can then reframe this as a matrix equation rather than two equations with scalar independent variables:

$AS=b$

Where:

$A = \begin{bmatrix}
vx_1 & vx_2 \\
vy_1 & vy_2 \\
\end{bmatrix}$

$S = \begin{bmatrix}
s \\
t
\end{bmatrix}$

$B = \begin{bmatrix}
bx_2 - bx_1 \\
by_2 - by_1 \\
\end{bmatrix}$

Then we can find S with the left division operator:

`A\b`

We can plug in $s$ and $t$ to the original $X_1=Vs+B$ and $X_2=Vt+B$ equations to get the X and Y values, which we need to do in order to evaluate whether the intersection occurs within the area of interest.
"""

# ╔═╡ 825e966f-b31b-460a-8861-1ea2135a1c12
function intersection2d(a::Hail, b::Hail)
	A = [a.vel[1:end-1] ;; -b.vel[1:end-1]]
	b = b.pos[1:end-1] - a.pos[1:end-1]
	s, t = 0.0, 0.0
	try
		s, t = A\b
	catch e
		return nothing
	end
	if s < 0 || t < 0
		return nothing
	end

	x, y = a.vel[1:end-1] * s + a.pos[1:end-1]
end

# ╔═╡ 32985d6a-38fe-4698-8169-0c1ef2ddaa61
function intersections2d(hails)
	[intersection2d(combo...) for combo in combinations(hails, 2)]
end

# ╔═╡ bd11a595-db52-4784-856d-95380c90521d
function part1(s = INPUT; window=200000000000000:400000000000000)
	hails = parse_input(s)
	function valid(res)
		if isnothing(res)
			return false
		end
		x, y = res
		return (x >= first(window) && 
			x <= last(window) && 
			y >= first(window) && 
			y <= last(window))
	end
	intersections = intersections2d(hails)
	count(valid, intersections)
end

# ╔═╡ 1897b877-bc3c-4a0e-a51a-530fb161df49
part1()

# ╔═╡ d38a20d0-b2fd-4618-9dca-b18836741a3d
md"""
Take 3 hailstones: $a$, $b$, $c$. $a$ has starting position $B_a = <x_{a0}, y_{a0}, z_{a0}>$ and velocity $V_a = <vx_a, vy_a, vz_a>$.

We are trying to find 6 unknowns: $x$, $y$, and $z$ of the rock's starting position. Let $B = <x, y, z>$. $vx$, $vy$, and $vz$ of the rock's velocity vector, let $V = <vx, vy, vz>$. We can define 3 positions at which each of $a$, $b$, and $c$ intersect our rock: $p_a$, $p_b$, and $p_c$. Let $t_a$ be the number of steps it takes for the intersection to happen.

$p_a = B_a + V_at_a$
$p_b = B_b + V_bt_b$
$p_c = B_c + V_ct_c$

By the way we've defined our hailstones, we assert that at $t_a$, our rock will intersect $p_a$, and so on. Therefore these equations become:

$B + Vt_a = B_a + V_at_a$
$B + Vt_b = B_b + V_bt_b$
$B + Vt_c = B_c + V_ct_c$

We can simplify these to:

$(V-V_a)t_a = B_a - B$
$(V-V_b)t_b = B_b - B$
$(V-V_c)t_c = B_c - B$

Note that each hailstone we add to our calculation introduces 3 equations but also introduces another unknown variable, so we need 3 points to solve this system of equations.

This is a nonlinear system of equations, so is nontrivial to solve. We'll use the JuMP computer algebra system, with the MadNLP nonlinear solver.
"""

# ╔═╡ 3ed87514-fac0-4570-ab91-2242a7566c1d
function part2(s = INPUT)
	hails = parse_input(s);
	model = Model(MadNLP.Optimizer)
	
	@variable(model, x)
	@variable(model, y)
	@variable(model, z)
	@variable(model, vx)
	@variable(model, vy)
	@variable(model, vz)
	
	@variable(model, ta)
	@constraint(model, (vx - hails[1].vel[1])*ta == hails[1].pos[1] - x)
	@constraint(model, (vy - hails[1].vel[2])*ta == hails[1].pos[2] - y)
	@constraint(model, (vz - hails[1].vel[3])*ta == hails[1].pos[3] - z)

	@variable(model, tb)
	@constraint(model, (vx - hails[2].vel[1])*tb == hails[2].pos[1] - x)
	@constraint(model, (vy - hails[2].vel[2])*tb == hails[2].pos[2] - y)
	@constraint(model, (vz - hails[2].vel[3])*tb == hails[2].pos[3] - z)

	@variable(model, tc)
	@constraint(model, (vx - hails[3].vel[1])*tc == hails[3].pos[1] - x)
	@constraint(model, (vy - hails[3].vel[2])*tc == hails[3].pos[2] - y)
	@constraint(model, (vz - hails[3].vel[3])*tc == hails[3].pos[3] - z)

	optimize!(model)
	(value(x), value(y), value(z)) .|> floor .|> Int |> sum
end

# ╔═╡ 933924d3-148b-400d-8233-b1b5ab86b502
part2()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Combinatorics = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
JuMP = "4076af6c-e467-56ae-b986-b466b2749572"
MadNLP = "2621e9c9-9eb4-46b1-8089-e8c72242dfb6"

[compat]
Combinatorics = "~1.0.2"
JuMP = "~1.17.0"
MadNLP = "~0.7.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "5bccc76cd5a968a5c753cec1768bf774b8a04bb8"

[[deps.AMD]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse_jll"]
git-tree-sha1 = "45a1272e3f809d36431e57ab22703c6896b8908f"
uuid = "14f7f29c-3bd6-536c-9a0b-7339e30b5a3e"
version = "0.5.3"

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

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "c0ae2a86b162fb5d7acc65269b469ff5b8a73594"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.8.1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "886826d76ea9e72b35fcd000e535588f7b60f21d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.FastClosures]]
git-tree-sha1 = "acebe244d53ee1b461970f8910c235b259e772ef"
uuid = "9aa1b823-49e4-5ca5-8b0f-3971ec8bab6a"
version = "0.3.2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuMP]]
deps = ["LinearAlgebra", "MacroTools", "MathOptInterface", "MutableArithmetics", "OrderedCollections", "Printf", "SnoopPrecompile", "SparseArrays"]
git-tree-sha1 = "cd161958e8b47f9696a6b03f563afb4e5fe8f703"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "1.17.0"

    [deps.JuMP.extensions]
    JuMPDimensionalDataExt = "DimensionalData"

    [deps.JuMP.weakdeps]
    DimensionalData = "0703355e-b756-11e9-17c0-8b28908087d0"

[[deps.LDLFactorizations]]
deps = ["AMD", "LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "70f582b446a1c3ad82cf87e62b878668beef9d13"
uuid = "40e66cde-538c-5869-a4ad-c39174c6795b"
version = "0.10.1"

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

[[deps.LinearOperators]]
deps = ["FastClosures", "LDLFactorizations", "LinearAlgebra", "Printf", "SparseArrays", "TimerOutputs"]
git-tree-sha1 = "a58ab1d18efa0bcf9f0868c6d387e4126dad3e72"
uuid = "5c8ed15e-5a4c-59e4-a42b-c7e8811fb125"
version = "2.5.2"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.MadNLP]]
deps = ["Libdl", "LinearAlgebra", "Logging", "MathOptInterface", "NLPModels", "Pkg", "Printf", "SolverCore", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "65d1edba975973dfe3d08f06dde3b95847f8f233"
uuid = "2621e9c9-9eb4-46b1-8089-e8c72242dfb6"
version = "0.7.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "PrecompileTools", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "362ae34a5291a79e16b8eb87b5738532c5e799ff"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.23.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "806eea990fb41f9b36f1253e5697aa645bf6a9f8"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.4.0"

[[deps.NLPModels]]
deps = ["FastClosures", "LinearAlgebra", "LinearOperators", "Printf", "SparseArrays"]
git-tree-sha1 = "51b458add76a938917772ee661ffb9d59b4c7e5d"
uuid = "a4795742-8479-5a88-8948-cc11e1c8c1a6"
version = "0.20.0"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

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

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SolverCore]]
deps = ["LinearAlgebra", "NLPModels", "Printf"]
git-tree-sha1 = "9fb0712d597d6598857ae50b7744df17b1137b38"
uuid = "ff4d7338-4cf1-434d-91df-b86cb86fb843"
version = "0.3.7"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

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

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f548a9e9c490030e545f72074a41edfd0e5bcdd7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.23"

[[deps.TranscodingStreams]]
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

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
# ╠═a166e6b2-a2a0-11ee-02e8-b39a047056c4
# ╠═8650fd09-815a-4893-84b7-c3b707c5daec
# ╠═087489a9-fa66-444f-9108-2d4c9f699bec
# ╠═37fefe81-bb24-440d-8734-ac7f81b9871b
# ╟─6cafd11e-a15e-4c6d-aecf-2b5f7280ce53
# ╠═825e966f-b31b-460a-8861-1ea2135a1c12
# ╠═32985d6a-38fe-4698-8169-0c1ef2ddaa61
# ╠═bd11a595-db52-4784-856d-95380c90521d
# ╠═1897b877-bc3c-4a0e-a51a-530fb161df49
# ╟─d38a20d0-b2fd-4618-9dca-b18836741a3d
# ╠═0a06363b-92d9-4642-9557-a9d532d7fc82
# ╠═3ed87514-fac0-4570-ab91-2242a7566c1d
# ╠═933924d3-148b-400d-8233-b1b5ab86b502
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
