abstract type LinearCode{F} <: Code{F} end

"""
    generator_matrix(c::LinearCode)

Return the generator matrix of code `c`.
"""
function generator_matrix end

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

# LinearCode constructor falls back on GeneratorCode

LinearCode(field, genmat::MatrixElem) = GeneratorCode(field, genmat)
LinearCode(field; check_matrix::MatrixElem) = GeneratorCode(field; check_matrix)
