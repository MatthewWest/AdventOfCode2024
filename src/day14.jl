### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ b083b0da-808a-4fbc-9bb3-204757689521
function Base.show(io::IO, mime::MIME"text/plain", m::Matrix{Char})
	(rows, cols) = size(m)
	print(io, '\n')
	for row in 1:rows
		for col in 1:cols
			print(io, m[row, col])
		end
		print(io, '\n')
	end
end

# ╔═╡ b95015b3-9e90-4df3-91cf-fefd35a2b7f3
TEST_INPUT = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
""";

# ╔═╡ 7902a9a1-3503-4012-bdbc-6c6ca2d32075
INPUT = read(joinpath(@__DIR__, "../data/day14.txt"), String);

# ╔═╡ 0e1c5d62-0120-4018-a8d6-0b76c5b979f5
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

# ╔═╡ 9722553a-73c3-46f9-8807-29f25b1db9be
@enum Direction N S E W

# ╔═╡ bf0c428a-a999-4ece-ac02-862b6c0b7247
function roll_north!(m)
	(rows, cols) = size(m)
	for col in 1:cols
		row = 1
		while row <= rows
			if m[row, col] == 'O'
				from = row
				while row > 1 && m[row-1, col] == '.'
					m[row-1, col] = 'O'
					m[row, col] = '.'
					row -= 1
				end
				row = from
			end
			row += 1
		end
	end
	m
end

# ╔═╡ 52f98881-3493-4930-9585-f9855b8f32c7
function roll_south!(m)
	(rows, cols) = size(m)
	for col in 1:cols
		row = rows
		while row >= 1
			if m[row, col] == 'O'
				from = row
				while row < rows && m[row+1, col] == '.'
					m[row+1, col] = 'O'
					m[row, col] = '.'
					row += 1
				end
				row = from
			end
			row -= 1
		end
	end
	m
end

# ╔═╡ f7c5b9f0-0308-4960-801a-5c771ab17137
function roll_west!(m)
	(rows, cols) = size(m)
	for row in 1:rows
		col = 1
		while col <= cols
			if m[row, col] == 'O'
				from = col
				while col > 1 && m[row, col-1] == '.'
					m[row, col-1] = 'O'
					m[row, col] = '.'
					col -= 1
				end
				col = from
			end
			col += 1
		end
	end
	m
end

# ╔═╡ f8f80f7e-e1cf-4472-8f2a-9350e1fd6792
function roll_east!(m)
	(rows, cols) = size(m)
	for row in 1:rows
		col = cols
		while col >= 1
			if m[row, col] == 'O'
				from = col
				while col < cols && m[row, col+1] == '.'
					m[row, col+1] = 'O'
					m[row, col] = '.'
					col += 1
				end
				col = from
			end
			col -= 1
		end
	end
	m
end

# ╔═╡ a35abe66-943d-4bbf-a14d-8c0ad57c0ed9
function roll!(m, dir)
	if dir == N
		return roll_north!(m)
	elseif dir == S
		return roll_south!(m)
	elseif dir == E
		return roll_east!(m)
	elseif dir == W
		return roll_west!(m)
	end
end

# ╔═╡ 3589403c-7a2b-480d-a492-c8bec098bdd4
function total_load(m)
	(rows, cols) = size(m)
	total = 0
	for r in 1:rows
		for c in 1:cols
			if m[r, c] == 'O'
				total += rows + 1 - r
			end
		end
	end
	total
end

# ╔═╡ 1b627d9f-4b80-4699-81cc-af8faba47dd2
function part1(input = INPUT)
	input |> parse_input |> roll_north! |> total_load
end

# ╔═╡ 813c6ffe-3505-4a98-904a-f4899a164030
part1()

# ╔═╡ 26d79e48-8b4a-4d42-bbc0-1cb7a6978bb4
function cycle!(m)
	for dir in [N, W, S, E]
		roll!(m, dir)
	end
	m
end

# ╔═╡ 4c1fe7ac-800e-48a0-8754-b901df6d71fb
function cycle!(m, n)
	for _ in 1:n
		cycle!(m)
	end
	m
end

# ╔═╡ 20631482-bcd6-42af-a489-21da02294a26
function part2(input = INPUT; cycle_count=1000000000)
	m = parse_input(input)
	hashes = Dict([hash(m) => 0])
	period = typemax(Int)
	offset = 0
	for n in Iterators.countfrom(1)
		cycle!(m)
		h = hash(m)
		if h in keys(hashes)
			period = n - hashes[h]
			offset = hashes[h]
			break
		else
			hashes[h] = n
		end
		if n > 1000
			return "Did not find a period in the first 1000."
		end
	end

	loads = Int[]
	for i in 1:period
		push!(loads, total_load(m))
		cycle!(m)
	end
	loads[(cycle_count - offset + 1) % period]
end

# ╔═╡ 34d2e5d1-acbf-4f8c-b73d-8830cc2179e1
part2()

# ╔═╡ Cell order:
# ╠═b083b0da-808a-4fbc-9bb3-204757689521
# ╠═b95015b3-9e90-4df3-91cf-fefd35a2b7f3
# ╠═7902a9a1-3503-4012-bdbc-6c6ca2d32075
# ╠═0e1c5d62-0120-4018-a8d6-0b76c5b979f5
# ╠═9722553a-73c3-46f9-8807-29f25b1db9be
# ╠═bf0c428a-a999-4ece-ac02-862b6c0b7247
# ╠═52f98881-3493-4930-9585-f9855b8f32c7
# ╠═f7c5b9f0-0308-4960-801a-5c771ab17137
# ╠═f8f80f7e-e1cf-4472-8f2a-9350e1fd6792
# ╠═a35abe66-943d-4bbf-a14d-8c0ad57c0ed9
# ╠═3589403c-7a2b-480d-a492-c8bec098bdd4
# ╠═1b627d9f-4b80-4699-81cc-af8faba47dd2
# ╠═813c6ffe-3505-4a98-904a-f4899a164030
# ╠═26d79e48-8b4a-4d42-bbc0-1cb7a6978bb4
# ╠═4c1fe7ac-800e-48a0-8754-b901df6d71fb
# ╠═20631482-bcd6-42af-a489-21da02294a26
# ╠═34d2e5d1-acbf-4f8c-b73d-8830cc2179e1
