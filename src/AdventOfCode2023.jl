module AdventOfCode2024
import Printf.@sprintf

solved = 1:1
for day ∈ solved
    padded = @sprintf("%02d", day)
    include(joinpath(@__DIR__, "day$padded.jl"))
end

end # module AdventOfCode2024
