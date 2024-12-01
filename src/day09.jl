### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ a0e3dca8-f7c3-4f9f-8a76-6ef33bc4317d
md"""
# Advent of Code for December 9, 2023

Find the puzzle description [here](https://adventofcode.com/2023/day/9).
"""

# ╔═╡ b45ee46e-964f-11ee-2db7-9bf8330f710d
INPUT = read(joinpath(@__DIR__, "../data/day09.txt"), String);

# ╔═╡ 45db229f-276c-4b93-951a-83f3537a6339
function parse_input(s)
	rows = Vector{Vector{Int}}()
	for line in eachsplit(strip(s), '\n')
		push!(rows, parse.(Int, eachsplit(line)))
	end
	rows
end

# ╔═╡ e6287bde-5980-4e6b-a7bb-ff4cc0eb5586
δs(history) = history[2:end] .- history[1:end-1]

# ╔═╡ 191109cc-b20d-4897-8acc-d3ce8482d6ef
function extrapolate(history)
	differences = Vector{Vector{Int}}()
	push!(differences, copy(history))
	while !all(isequal(0), last(differences))
		push!(differences, δs(last(differences)))
	end

	for (i, diffs) in Iterators.reverse(enumerate(differences[1:end-1]))
		δ = last(differences[i+1])
		push!(differences[i], last(differences[i]) + δ)
	end
	last(differences[1])
end

# ╔═╡ 632e254d-6c0e-4a4b-bf5c-4078b4ded20f
function part1(input = INPUT)
	histories = parse_input(input)
	extrapolate.(histories) |> sum
end

# ╔═╡ f2233e66-7a46-46c7-a970-fcfe6a16cac4
part1()

# ╔═╡ 9b96d259-54b3-4b60-a1a3-721768511110
function extrapolate_backward(history)
	differences = Vector{Vector{Int}}()
	push!(differences, copy(history))
	while !all(isequal(0), last(differences))
		push!(differences, δs(last(differences)))
	end
	
	for (i, diffs) in Iterators.reverse(enumerate(differences[1:end-1]))
		δ = first(differences[i+1])
		pushfirst!(differences[i], first(differences[i]) - δ)
	end
	first(differences[1])
end

# ╔═╡ d8fcea78-630c-4cce-8e9a-973908a37d07
function part2(input = INPUT)
	histories = parse_input(input)
	extrapolate_backward.(histories) |> sum
end

# ╔═╡ 77c3511e-df7d-42ab-a269-1dcb95304ac6
part2()

# ╔═╡ Cell order:
# ╟─a0e3dca8-f7c3-4f9f-8a76-6ef33bc4317d
# ╠═b45ee46e-964f-11ee-2db7-9bf8330f710d
# ╠═45db229f-276c-4b93-951a-83f3537a6339
# ╠═e6287bde-5980-4e6b-a7bb-ff4cc0eb5586
# ╠═191109cc-b20d-4897-8acc-d3ce8482d6ef
# ╠═632e254d-6c0e-4a4b-bf5c-4078b4ded20f
# ╠═f2233e66-7a46-46c7-a970-fcfe6a16cac4
# ╠═9b96d259-54b3-4b60-a1a3-721768511110
# ╠═d8fcea78-630c-4cce-8e9a-973908a37d07
# ╠═77c3511e-df7d-42ab-a269-1dcb95304ac6
