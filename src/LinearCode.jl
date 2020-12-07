abstract type LinearCode{F} <: Code{F} end

"""
    generator_matrix(c::LinearCode)

Return the generator matrix of code `c`.
"""
function generator_matrix end

"""
    parity_check_matrix(c::LinearCode)

Return the parity check matrix `H` of `c`,
such that `iszero(generator_matrix(c) * H')`.
"""
parity_check_matrix(c::LinearCode) = transpose(check_matrix(c))
# TODO: make it lazy via LinearAlgebra.Transpose

"""
    check_matrix(c::LinearCode)

Return the transposed `H` of the parity check matrix of `c`,
such that `iszero(generator_matrix(c) * H)`.
"""
function check_matrix(c::LinearCode)
    k, checkmat = right_kernel(generator_matrix(c))
    @assert k + dimension(c) == blocklength(c)
    checkmat
end

# default fallback
base_field(c::LinearCode) = c.field

## LinearCode constructor falls back on GeneratorCode

LinearCode(field, genmat::MatrixElem) = GeneratorCode(field, genmat)
LinearCode(field; check_matrix::MatrixElem) = GeneratorCode(field; check_matrix)

## IO

function Base.show(io::IO, c::LinearCode)
    n = blocklength(c)
    k = dimension(c)
    codename = nameof(typeof(c))
    println(io, "[$n, $k] $codename over $(base_field(c))")
end
