module AdventOfCode2023
import Printf.@sprintf

solved = 1:5
for day ∈ solved
    padded = @sprintf("%02d", day)
    include(joinpath(@__DIR__, "day$padded.jl"))
end

end # module AdventOfCode2023
