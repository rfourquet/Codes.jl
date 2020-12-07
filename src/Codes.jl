module Codes

export Code, GeneratorCode, LinearCode, RepetitionCode,
       blocklength, dimension,
       generator_matrix, systematic_generator_matrix, check_matrix, parity_check_matrix,
       encode, decode, base_field, message_space

using AbstractAlgebra: AbstractAlgebra, order, elem_type, right_kernel, left_kernel, rref,
      matrix, MatrixSpace, base_ring

abstract type Code{F} end


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

"""
    encode(c::Code, message)

Encode `message`, which must be a vector (or row-vector) of length
matching `dimension(c)`.
"""
function encode end

"""
    decode(c::Code, word)

Decode `word`, which must be a vector (or row-vector) of length
matching `blocklength(c)`.
"""
function decode end


## includes

include("utils.jl")
include("LinearCode.jl")
include("GeneratorCode.jl")
include("RepetitionCode.jl")

end # module
