"""
    generator_matrix(c::Code)

Return the generator matrix of code `c`.
"""
function generator_matrix end

# default fallback
base_field(c::LinearCode) = c.field

# based on generator matrix
mutable struct GeneratorCode{F,M<:MatrixElem} <: LinearCode{F}
    field::F
    genmat::M
    checkmat::Union{M,Nothing}

    GeneratorCode{F,M}(field::F, genmat::M) where {F,M<:MatrixElem} =
        new{F,M}(field, genmat, nothing)
end

GeneratorCode(field::F, genmat::M) where {F,M<:MatrixElem} =
    GeneratorCode{F,M}(field, genmat)

function GeneratorCode(field; check_matrix::MatrixElem)
    k, genmat = left_kernel(check_matrix)
    code = GeneratorCode(field, genmat)
    code.checkmat = check_matrix
    @assert k == dimension(code)
    code
end

blocklength(c::GeneratorCode) = ncols(generator_matrix(c))
dimension(c::GeneratorCode) = nrows(generator_matrix(c))

generator_matrix(c::GeneratorCode) = c.genmat

# transposed of parity check matrix
function check_matrix(c::GeneratorCode)
    if c.checkmat === nothing
        k, checkmat = right_kernel(generator_matrix(c))
        @assert k + dimension(c) == blocklength(c)
        c.checkmat = checkmat
    end
    c.checkmat
end

function encode(code::GeneratorCode, msg)
    # should column vectors be accepted (and automatically transposed) ?
    msg * generator_matrix(code)
end
