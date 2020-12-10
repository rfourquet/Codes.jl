abstract type AbstractChannel end

struct ErrorChannel{D,RNG<:Union{AbstractRNG,Nothing}} <: AbstractChannel
    errdist::D
    rng::RNG
    positions::Vector{Int}
end

function ErrorChannel(errdist; rng::Union{AbstractRNG,Nothing}=nothing)
    errdist = errdist isa Integer ?
        (errdist,) :
        errdist
    Random.gentype(errdist) <: Integer ||
        throw(ArgumentError("distribution for number of errors must yield integers"))
    ErrorChannel(errdist, rng, Int[])
end

getrng(c::AbstractChannel) = something(c.rng, Random.default_rng())

function transmit!(chan::ErrorChannel, cw)
    rng = getrng(chan)
    nerr = rand(rng, chan.errdist)
    len = length(cw)
    0 <= nerr <= len ||
        error("too many errors ($nerr) for codeword of length $len")

    # TODO: not efficient to shuffle a full array of error positions
    positions = chan.positions
    resize!(positions, len)
    copy!(positions, 1:len)
    shuffle!(rng, positions)

    Fsp = Random.Sampler(rng, base_ring(cw))

    for i=1:nerr
        pos = positions[i]
        while true
            x = rand(rng, Fsp)
            if x != cw[1, pos]
                cw[1, pos] = x
                break
            end
        end
    end
    cw
end

transmit(chan::ErrorChannel, cw) = transmit!(chan, copy(cw))
