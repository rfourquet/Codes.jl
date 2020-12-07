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
function check_matrix end

# default fallback
base_field(c::LinearCode) = c.field
