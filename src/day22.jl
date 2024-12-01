### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ ed5dfe78-a0e6-11ee-09ba-bd639aa5d915
INPUT = read(joinpath(@__DIR__, "../data/day22.txt"), String);

# ╔═╡ c636c889-a652-490d-915e-3355fc277221
function parse_input(s)
	lines = split(strip(s), '\n')
	blocks = CartesianIndices[]
	for line in lines
		a, b = split(line, '~')
		push!(blocks,
			CartesianIndex(parse.(Int, split(a, ','))...):CartesianIndex(parse.(Int, split(b, ','))...))
	end
	blocks
end

# ╔═╡ d76c99fe-c367-47ba-be35-0615243f0749
TEST_INPUT = """
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
""";

# ╔═╡ 05b4ea23-9a2c-431f-8968-857e036da0c1
function space_fill(blocks)
	points = cat(blocks .|> first, blocks .|> last; dims=1)
	minx, maxx = map(i -> i[1], points) |> extrema
	miny, maxy = map(i -> i[2], points) |> extrema
	minz, maxz = map(i -> i[3], points) |> extrema

	xsize = maxx - minx + 1
	ysize = maxy - miny + 1
	zsize = maxz - minz + 1

	sort!(blocks, by = I -> min([i[3] for i in I]...))
	m = zeros(Int, (xsize, ysize, zsize))
	settled = similar(blocks)
	for (i, block) in enumerate(blocks)
		# Adjust the block for 1-based indexing
		block = block .+ CartesianIndex(1 - minx, 1 - miny, 1 - minz)

		supported = false
		while !supported
			fallen1 = block .- CartesianIndex(0, 0, 1)
			if checkbounds(Bool, m, fallen1) && all(==(0), m[fallen1])
				block = fallen1
			else
				supported = true
			end
		end

		m[block] .= i
		settled[i] = block
	end
	
	m, settled
end

# ╔═╡ a6f7e4be-2ab7-45b7-9f9e-8149da3abd93
function get_supports(m, block)
	n = m[first(block)]
	down1 = block .- CartesianIndex(0, 0, 1)
	if !checkbounds(Bool, m, down1)
		# 0 = supported by the ground
		return Set([0])
	end

	# 0 in the map indicates free space, not ground.
	supported_by = delete!(Set(m[down1]), 0)
	# Vertical blocks will include their own block number in supports.
	delete!(supported_by, n)
	return supported_by
end

# ╔═╡ 14adffcc-0351-4279-9f3a-999e66285756
function part1(s = INPUT)
	blocks = parse_input(s)
	m, settled_blocks = space_fill(blocks)
	supports = Dict(
		[i => get_supports(m, settled_blocks[i])
			for i in 1:length(blocks)]
	)
	can_disintegrate = fill(true, size(blocks))
	for (i, block) in enumerate(settled_blocks)
		supported_by = supports[i]
		if length(supported_by) == 1
			for j in supported_by
				if j != 0
					can_disintegrate[j] = false
				end
			end
		end
	end
	count(can_disintegrate)
end

# ╔═╡ 6bc0871f-2174-473b-9136-f25bce31d988
part1()

# ╔═╡ ff8173d7-2088-49b2-8fa4-a346dde2536e
function count_chain(m, settled_blocks, supports, dependencies, i)
	falling = [i]
	while !isempty(falling)
		b = popfirst!(falling)
	end
end

# ╔═╡ a5b046e9-a5d0-4daa-9157-d0029beca2f2
function part2(s = INPUT)
	blocks = parse_input(s)
	m, settled_blocks = space_fill(blocks)
	supports = Dict(
		[i => get_supports(m, settled_blocks[i])
			for i in 1:length(blocks)]
	)
	dependencies = Dict{Int, Set{Int}}()
	for i in 1:length(blocks)
		 for j in supports[i]
			 on = get!(dependencies, j, Set{Int}())
			 push!(on, i)
		 end
	end

	settle_counts = zeros(Int, length(blocks))
	for i in 1:length(blocks)
		if length(supports[i]) == 0
			continue
		end
		if i == 1
			one_removed = settled_blocks[2:end]
		elseif i == length(blocks)
			one_removed = settled_blocks[1:end-1]
		else
			one_removed = vcat(settled_blocks[1:i-1], settled_blocks[i+1:end])
		end
		_, resettled = space_fill(one_removed)
		settle_counts[i] = count(pair -> !=(pair[1], pair[2]), zip(one_removed, resettled))
	end
	sum(settle_counts)
end

# ╔═╡ 2a23dc72-ca9c-4333-ba40-d719e39ec125
part2()

# ╔═╡ Cell order:
# ╠═ed5dfe78-a0e6-11ee-09ba-bd639aa5d915
# ╠═c636c889-a652-490d-915e-3355fc277221
# ╠═d76c99fe-c367-47ba-be35-0615243f0749
# ╠═05b4ea23-9a2c-431f-8968-857e036da0c1
# ╠═a6f7e4be-2ab7-45b7-9f9e-8149da3abd93
# ╠═14adffcc-0351-4279-9f3a-999e66285756
# ╠═6bc0871f-2174-473b-9136-f25bce31d988
# ╠═ff8173d7-2088-49b2-8fa4-a346dde2536e
# ╠═a5b046e9-a5d0-4daa-9157-d0029beca2f2
# ╠═2a23dc72-ca9c-4333-ba40-d719e39ec125
