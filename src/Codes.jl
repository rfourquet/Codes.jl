module Codes

export Code, GeneratorCode, LinearCode, RepetitionCode,
       blocklength, dimension, generator_matrix,
       encode, decode, base_field

using AbstractAlgebra: AbstractAlgebra, order, elem_type

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


## utils

function check_parent(c::Code, x)
    base_field(c) == parent(x) || throw(ArgumentError("incompatible fields"))
    nothing
end


vecsimilar(x, m) = _vecsimilar(x, size(x), m)

_vecsimilar(x, (n,)::NTuple{1}, m) = similar(x, m)
_vecsimilar(x, (n, m0)::NTuple{2}, m) = similar(x, _check_one(n), m)

function _check_one(n)
    isone(n) || throw(ArgumentError("expected a 1-dimensional vector"))
    n
end

veclen(x) = _veclen(size(x))

_veclen((n,)::NTuple{1}) = n
_veclen((n, m)::NTuple{2}) = (_check_one(n); m)

const MatrixElem = Union{AbstractMatrix,AbstractAlgebra.MatrixElem}

# TODO: move these methods to AbstractAlgebra.jl and import nrows/ncols from it
nrows(a::MatrixElem) = size(a, 1)
ncols(a::MatrixElem) = size(a, 2)

## includes

include("LinearCodes.jl")
include("RepetitionCode.jl")

end # module
