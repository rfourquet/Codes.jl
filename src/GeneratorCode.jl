# code based on generator matrix
abstract type AbstractGeneratorCode{F,M<:MatrixElem} <: LinearCode{F} end

# unstructured generator matrix
mutable struct GeneratorCode{F,M<:MatrixElem} <: AbstractGeneratorCode{F,M}
    field::F
    genmat::M
    checkmat::Union{M,Nothing}
    mindist::Union{Int,Nothing}

    GeneratorCode{F,M}(field::F, genmat::M) where {F,M<:MatrixElem} =
        new{F,M}(field, genmat, nothing, nothing)
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

blocklength(c::AbstractGeneratorCode) = ncols(generator_matrix(c))
dimension(c::AbstractGeneratorCode) = nrows(generator_matrix(c))

generator_matrix(c::AbstractGeneratorCode) = c.genmat

# transposed of parity check matrix
function check_matrix(c::AbstractGeneratorCode)
    if c.checkmat === nothing
        c.checkmat = invoke(check_matrix, Tuple{LinearCode}, c)
    end
    c.checkmat
end

function encode(code::AbstractGeneratorCode, msg)
    # should column vectors be accepted (and automatically transposed) ?
    msg * generator_matrix(code)
end
