struct ParityCheckCode{F} <: LinearCode{F}
    field::F
    dim::Int
end

blocklength(c::ParityCheckCode) = c.dim + 1
dimension(c::ParityCheckCode) = c.dim
maybe_minimum_distance(::ParityCheckCode) = 2

function generator_matrix(c::ParityCheckCode)
    m = diagonal_matrix(one(base_field(c)), dimension(c), blocklength(c))
    for i = 1:dimension(c)
        m[i, end] = -one(base_field(c))
    end
    m
end

systematic_generator_matrix(c::ParityCheckCode) = generator_matrix(c)

function encode(code::ParityCheckCode, msg)
    cw = vecsimilar(msg, blocklength(code))
    F = base_field(code)
    s = zero(F)
    for i = 1:dimension(code)
        s -= msg[1, i]
        cw[1, i] = msg[1, i] # TODO: define linear indexing for row/column AA matrices
    end
    cw[1, end] = s
    cw
end
