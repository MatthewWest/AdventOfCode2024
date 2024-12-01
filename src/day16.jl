### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ cbffbfb6-587c-43dc-8adc-a347db59371d
md"""
# Advent of Code 2023, Day 16

For this problem we will need to keep track of both the location and direction of the light beam at each step, in order to plot the path of the light beam through the map.

Therefore, I will define a struct `Ray` for the purpose, and define the functions `Base.hash` and `Base.isequal`. With these two functions defined, instances of `Ray` will work with the standard Set and Dict types.
"""

# ╔═╡ a62bd114-9c1b-11ee-1c91-71187ce6c822
INPUT = read(joinpath(@__DIR__, "../data/day16.txt"), String);

# ╔═╡ 3930435e-83e0-4f14-8d48-5740be51e3f4
function parse_input(s)
	lines = split(strip(s), '\n')
	rows = length(lines)
	cols = length(lines[1])
	m = fill(' ', (rows, cols))
	for (row, line) in enumerate(lines)
		for (col, c) in enumerate(line)
			m[row, col] = c
		end
	end
	m
end

# ╔═╡ ff01c255-56cf-4fa8-94d9-87fdb073b07e
@enum Direction N W S E

# ╔═╡ 829294c6-34cf-4e27-a637-e2d42c1c7dbf
struct Ray
	# A location, expressed as (row, col)
	loc::Tuple{Int, Int}
	dir::Direction
end

# ╔═╡ aa6d86f9-19be-4ab2-912b-a2f9bb9561e9
function Base.hash(r::Ray, h::UInt)::UInt
	h1 = Base.hash(r.loc, h)
	return Base.hash(r.dir, h1)
end

# ╔═╡ f97c4606-8045-44a5-8200-5d7a89e30194
Base.isequal(a::Ray, b::Ray) = a.loc == b.loc && a.dir == b.dir

# ╔═╡ cfea552b-926f-4e17-ad9b-6dd0d35e2d1b
function one(dir::Direction)
	"""One step in a given direction.
	
	Coordinates are (row, col).
	"""
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

# ╔═╡ 1b710b97-d5f0-4265-a66a-d8967e216530
function reflect(c, dir::Direction)
	if c == '/'
		if dir == N
			return E
		elseif dir == W
			return S
		elseif dir == S
			return W
		elseif dir == E
			return N
		else
			error("Unrecognized direction $dir")
		end
	elseif c == '\\'
		if dir == N
			return W
		elseif dir == E
			return S
		elseif dir == W
			return N
		elseif dir == S
			return E
		else
			error("Unrecognized direction $dir")
		end
	else
		error("Received a nonreflective character")
	end
end

# ╔═╡ 910f9793-63cd-489e-b02d-dd49c6aa0d3e
function transit(m, ray::Ray)
	"""Return locations the light transits to when entering loc in direction dir."""
	c = m[ray.loc...]
	loc, dir = ray.loc, ray.dir
	if c == '.'
		return [Ray(loc .+ one(dir), dir)]
	elseif c == '/' || c == '\\'
		newdir = reflect(c, dir)
		return [Ray(loc .+ one(newdir), newdir)]
	elseif c == '|'
		if dir == N || dir == S
			return [Ray(loc .+ one(dir), dir)]
		else
			return [Ray(loc .+ one(N), N), Ray(loc .+ one(S), S)]
		end
	elseif c == '-'
		if dir == W || dir == E
			return [Ray(loc .+ one(dir), dir)]
		else
			return [Ray(loc .+ one(W), W), Ray(loc .+ one(E), E)]
		end
	else
		error("Unrecognized character $c at $loc")
	end
end

# ╔═╡ 358499b9-478a-42a1-b86c-ddf76465fcc1
function nenergized(m, start::Ray)
	(nrows, ncols) = size(m)
	q = [start]
	seen = Set([start])
	while !isempty(q)
		r = pop!(q)
		next = transit(m, r)
		for n in next
			(r, c) = n.loc
			# Ignore out of bounds rays
			if r > nrows || r < 1 || c > ncols || c < 1
				continue
			end
			if n ∉ seen
				push!(seen, n)
				push!(q, n)
			end
		end
	end
	return [r.loc for r in seen] |> unique |> length
end

# ╔═╡ 31a809cd-c0ba-4c97-8edb-c9c2aebb36ac
function part1(input = INPUT)
	m = parse_input(input)
	nenergized(m, Ray((1, 1), E))
end

# ╔═╡ f79c6e18-5ebf-44d4-97ff-1e41f175fd70
part1()

# ╔═╡ c6d3f7a0-266c-4296-a210-91f91ad2d463
function part2(input = INPUT)
	m = parse_input(input)
	(nrows, ncols) = size(m)
	starts = Ray[]
	for r in 1:nrows
		push!(starts, Ray((r, 1), E))
		push!(starts, Ray((r, ncols), W))
	end
	for c in 1:ncols
		push!(starts, Ray((1, c), S))
		push!(starts, Ray((ncols, c), N))
	end

	max_energized = 0
	max_ray = Ray((1, 1), E)
	for start in starts
		n = nenergized(m, start)
		if n > max_energized
			max_energized = n
			max_ray = start
		end
	end
	max_energized
end

# ╔═╡ 66f06518-e2cd-4809-8688-220acee1d464
part2()

# ╔═╡ 839d3f44-bf55-4d76-a626-5ec6f33b3896
md"""
In retrospect, it would have been better to track the direction as a unit vector in the given direction. Then the `reflect` function could have been defined on a unit vector using negatives and switching the locations of the coordinates.
"""

# ╔═╡ Cell order:
# ╟─cbffbfb6-587c-43dc-8adc-a347db59371d
# ╠═a62bd114-9c1b-11ee-1c91-71187ce6c822
# ╠═3930435e-83e0-4f14-8d48-5740be51e3f4
# ╠═ff01c255-56cf-4fa8-94d9-87fdb073b07e
# ╠═829294c6-34cf-4e27-a637-e2d42c1c7dbf
# ╠═aa6d86f9-19be-4ab2-912b-a2f9bb9561e9
# ╠═f97c4606-8045-44a5-8200-5d7a89e30194
# ╠═cfea552b-926f-4e17-ad9b-6dd0d35e2d1b
# ╠═1b710b97-d5f0-4265-a66a-d8967e216530
# ╠═910f9793-63cd-489e-b02d-dd49c6aa0d3e
# ╠═358499b9-478a-42a1-b86c-ddf76465fcc1
# ╠═31a809cd-c0ba-4c97-8edb-c9c2aebb36ac
# ╠═f79c6e18-5ebf-44d4-97ff-1e41f175fd70
# ╠═c6d3f7a0-266c-4296-a210-91f91ad2d463
# ╠═66f06518-e2cd-4809-8688-220acee1d464
# ╟─839d3f44-bf55-4d76-a626-5ec6f33b3896
