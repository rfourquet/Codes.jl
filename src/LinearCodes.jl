"""
    generator_matrix(c::Code)

Return the generator matrix of code `c`.
"""
function generator_matrix end

# default fallback
base_field(c::LinearCode) = c.field

# based on generator matrix
struct GeneratorCode{F,M<:MatrixElem} <: LinearCode{F}
    field::F
    genmat::M
end

generator_matrix(c::GeneratorCode) = c.genmat

blocklength(c::GeneratorCode) = ncols(generator_matrix(c))
dimension(c::GeneratorCode) = nrows(generator_matrix(c))

function encode(code::GeneratorCode, msg)
    # should column vectors be accepted (and automatically transposed) ?
    msg * generator_matrix(code)
end


# based on parity check matrix
struct CheckCode{F,M<:MatrixElem} <: LinearCode{F}
    field::F
    checkmat::M
end

check_matrix(c::CheckCode) = c.checkmat

blocklength(c::CheckCode) = ncols(check_matrix(c))
dimension(c::CheckCode) = blocklength(c) - nrows(check_matrix(c))
