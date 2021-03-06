abstract type AbstractChannel end

getrng(c::AbstractChannel) = something(c.rng, Random.default_rng())

transmit(chan::AbstractChannel, cw) = transmit!(chan, copy(cw))

##############################################################################

struct ErrorChannel{D,RNG<:Union{AbstractRNG,Nothing}} <: AbstractChannel
    nerrdist::D # distribution yielding the number of errors for a given message
    rng::RNG
    positions::Vector{Int}
end

function ErrorChannel(nerrdist; rng::Union{AbstractRNG,Nothing}=nothing)
    nerrdist = nerrdist isa Integer ?
        (nerrdist,) :
        nerrdist
    Random.gentype(nerrdist) <: Integer ||
        throw(ArgumentError("distribution for number of errors must yield integers"))
    ErrorChannel(nerrdist, rng, Int[])
end

nerror_distribution(chan::ErrorChannel) = chan.nerrdist

function transmit!(chan::ErrorChannel, cw)
    rng = getrng(chan)
    nerr = rand(rng, chan.nerrdist)
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


##############################################################################

struct SymmetricChannel{RNG<:Union{AbstractRNG,Nothing}} <: AbstractChannel
    perr::Float64
    rng::RNG

    function SymmetricChannel(perr::Real; rng::Union{AbstractRNG,Nothing}=nothing)
        perr = Float64(perr)
        0 <= perr <= 1.0 ||
            argerror("error probability `perr` must satisfy `0 <= perr <= 1` (got $perr)")
        new{typeof(rng)}(perr, rng)
    end
end

error_probability(chan::SymmetricChannel) = chan.perr

function transmit!(chan::SymmetricChannel, cw)
    rng = getrng(chan)
    Fsp = Random.Sampler(rng, base_ring(cw))

    for idx in eachindex(cw)
        if rand(rng) < error_probability(chan)
            while true
                x = rand(rng, Fsp)
                if x != cw[idx]
                    cw[idx] = x
                    break
                end
            end
        end
    end
    cw
end
