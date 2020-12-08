abstract type LinearCode{F} <: Code{F} end

"""
    message_space(c::LinearCode)

Ambient space of messages that can be encoded.
"""
message_space(c::LinearCode) = MatrixSpace(base_field(c), 1, dimension(c))

"""
    ambient_space(c::LinearCode)

Ambient space of codewords in `c`.
"""
ambient_space(c::LinearCode) = MatrixSpace(base_field(c), 1, blocklength(c))

"""
    generator_matrix(c::LinearCode)

Return the generator matrix of code `c`.
"""
function generator_matrix end

""" systematic_generator_matrix(c::LinearCode)

Return a systematic generator matrix of code `c`, which contain
a set of columns forming the identity matrix.
"""
function systematic_generator_matrix(c::LinearCode)
    G = generator_matrix(c)
    k, S = rref(G)
    @assert k == dimension(c)
    S
end

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
    nkd = params(c)
    codename = nameof(typeof(c))
    println(io, "$nkd $codename over $(base_field(c))")
end

## iteration

function Base.iterate(c::LinearCode, state = nothing)
    if state === nothing
        msg_it = iterator(message_space(c))
        msg_msg_st = iterate(msg_it)
    else
        msg_it, msg_st = state
        msg_msg_st = iterate(msg_it, msg_st)
    end
    msg_msg_st === nothing && return nothing
    msg, msg_st = msg_msg_st
    encode(c, msg), (msg_it, msg_st)
end

# number of codewords (TODO: check overflow)
Base.length(c::LinearCode) = order(base_field(c))^dimension(c)

Base.eltype(c::LinearCode) = elem_type(ambient_space(c))

## minimum distance

function minimum_distance(c::LinearCode)
    md() = minimum(hamming_weight, Iterators.filter(!iszero, c))
    if isdefined(c, :mindist)
        if c.mindist !== nothing
            c.mindist
        else
            c.mindist = md()
        end
    else
        md()
    end
end

maybe_minimium_distance(c::LinearCode) = isdefined(c, :mindist) ? c.mindist : nothing


## params

function params(c::LinearCode)
    n = blocklength(c)
    k = dimension(c)
    d = maybe_minimium_distance(c)
    d === nothing ? [n, k] : [n, k, d]
end


## NearestNeighborDecoder

struct NearestNeighborDecoder{C<:LinearCode} <: DecoderToCode
    code::C
end

function decode(dec::NearestNeighborDecoder, word)
    # TODO: assert "small" code
    dmin = typemax(Int)
    local nearest::elem_type(ambient_space(code(dec)))
    for cw in code(dec)
        d = hamming_distance(word, cw)
        if d < dmin
            nearest = cw
            dmin = d
        end
    end
    nearest
end
