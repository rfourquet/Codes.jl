module CodesTests

__revise_mode__ = :eval

using ReTest
using Codes
using AbstractAlgebra

include("GeneratorCode.jl")
include("RepetitionCode.jl")
include("ParityCheckCode.jl")
include("examples.jl")

end
