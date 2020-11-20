module Codes

export Code, LinearCode, RepetitionCode,
       blocklength, dimension


abstract type Code{F} end

abstract type LinearCode{F} <: Code{F} end

## generic functions

"""
    blocklength(c::Code)

Return the length of code `c`.
"""
function blocklength end

"""
    dimension(c::Code)

Return the dimension of code `c`.
"""
function dimension end


## includes

include("RepetitionCode.jl")

end # module
