module CodesTests

__revise_mode__ = :eval

using ReTest
using Codes
using AbstractAlgebra
using Random

include("GeneratorCode.jl")
include("RepetitionCode.jl")
include("ParityCheckCode.jl")
include("Channel.jl")
include("examples.jl")

end
