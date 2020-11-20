struct RepetitionCode{F} <: LinearCode{F}
    field::F
    len::Int
end

blocklength(c::RepetitionCode) = c.len
dimension(c::RepetitionCode) = 1
