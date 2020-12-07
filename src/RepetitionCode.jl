struct RepetitionCode{F} <: LinearCode{F}
    field::F
    len::Int
end

blocklength(c::RepetitionCode) = c.len
dimension(c::RepetitionCode) = 1

generator_matrix(c::RepetitionCode) =
    matrix(base_field(c), fill(one(base_field(c)), 1, blocklength(c)))

systematic_generator_matrix(c::RepetitionCode) = generator_matrix(c)

function encode(code::RepetitionCode, message)
    n = veclen(message)
    n == 1 || throw(ArgumentError("message length ($n) does not match code dimension (1)"))
    x = message[1, 1]
    check_parent(code, x)
    codeword = vecsimilar(message, blocklength(code))
    for i in eachindex(codeword)
        codeword[i] = x
    end
    codeword
end

function decode(code::RepetitionCode, word)
    F = base_field(code)
    if order(F) == 2
        n0 = count(iszero, word)
        n1 = blocklength(code) - n0
        x = n0 < n1 ? one(F) : zero(F)
    else
        counts = Dict{elem_type(F), Int}()
        for x in word
            counts[x] = 1 + get(counts, x, 0)
        end
        x = argmax(counts) # undefined result in case of tie
    end
    message = vecsimilar(word, 1)
    message[1, 1] = x
    message
end
