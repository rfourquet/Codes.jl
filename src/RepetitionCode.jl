struct RepetitionCode{F} <: LinearCode{F}
    field::F
    len::Int
end

blocklength(c::RepetitionCode) = c.len
dimension(c::RepetitionCode) = 1
base_field(c::RepetitionCode) = c.field

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
