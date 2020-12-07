struct ParityCheckCode{F} <: LinearCode{F}
    field::F
    dim::Int
end

blocklength(c::ParityCheckCode) = c.dim + 1
dimension(c::ParityCheckCode) = c.dim

function generator_matrix(c::ParityCheckCode)
    m = diagonal_matrix(one(base_field(c)), dimension(c), blocklength(c))
    for i = 1:dimension(c)
        m[i, end] = -one(base_field(c))
    end
    m
end

systematic_generator_matrix(c::ParityCheckCode) = generator_matrix(c)
