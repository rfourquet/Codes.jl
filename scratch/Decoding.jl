module Decoding

export Decoder, ListDecoder, SumsDecoder,
       threshold, setdistance!, setfunction!, decode, list

export code, codelen

using Codes
using Codes: Length
using BooleanFunctions

# * types

abstract type Decoder{C} end
abstract type ListDecoder{C} <: Decoder{C} end
abstract type SumsDecoder{S<:Real} <: ListDecoder{ReedMuller} end

# * codelen / distance

Codes.codelen(d::Decoder) = codelen(code(d))

"Decoding distance for a decoder"
distance(d::Decoder) = error("unimplemented")

# * Bias/Distance checkers

struct Bias
    bias::Float64
    function Bias(e::Float64)
        0.0 <= e <= 1.0 || error("invalid bias ɛ=$p (should be 0.0 ≤ ɛ <= 1.0)")
        new(e)
    end
end

Float64(p::Bias) = p.bias

struct Distance{T<:Integer}
    distance::T

    function Distance(d::T) where T
        0 <= d || error("invalid distance $d (should be non-negative)")
        new{T}(d)
    end
end

convert(::Type{T}, d::Distance{T}) where {T<:Integer} = d.distance

# * conversion Bias/Length/Distance/Threshold

# distance d, bias ɛ, sums threshold Σ
# d = n/2*(1-ɛ) ⟺ n-2d = nɛ := Σ
# δ = 1/2*(1-ɛ) ⟺ 1-2δ = ɛ

bias_to_distance(n::L, e::Float64) where {L<:Integer} = round(L, n/2*(1-e))
distance_to_bias(n::L, d::L) where {L<:Integer} = 1-2d/n

distance_to_sums(n::L, d::L) where {L<:Integer} = n-2d
bias_to_sums(n::L, e::Float64, ::Type{L}) where {L<:Integer} = ceil(L, n*e)
bias_to_sums(n::L, e::Float64, ::Type{Float64}) where {L<:Integer} = Float64(n*e)

sums_to_bias(n::L, s::T) where {L<:Integer, T} = s/n
sums_to_distance(n::L, s::T) where {L<:Integer, T} = T((n-s)/2)

# * distance / setdistance! / bias / setbias!

function check_distance(dec::ListDecoder, dist::T) where T
    c = code(dec)
    0 <= dist <= codelen(c)÷2 ||
        error("the decoding distance ($dist was given) must be in 0:$(codelen(c)÷2)")
    dist
end

check_bias(bias::Float64) =
    !(0 <= bias <= 1.0) && error("the bias must be in [0,1] ($bias was given)") ||
    bias

@generated function setdistance!(dec::ListDecoder, dist::T) where {T<:Integer}
    if :distance in fieldnames(dec)
        :(dec.distance = check_distance(dec, dist))
    elseif :bias in fieldnames(dec)
        quote
            dec.bias = distance_to_bias(codelen(dec), check_distance(dec, dist))
        end
    else
        error("unable to set distance for $dec")
    end
end

distance(dec::ListDecoder) = bias_to_distance(codelen(dec), dec.bias)

setbias!(dec::ListDecoder, bias::Float64) = dec.bias = check_bias(bias)

# * threshold

threshold(dec::SumsDecoder{S}) where S = bias_to_sums(codelen(dec), dec.bias, S)

# * setfunction!

setfunction!(dec::Decoder) = error("unimplemented")

# * decode

decode(dec::Decoder) = error("unimplemented")

decode(dec::Decoder, f::AbstractBooleanFunction) = (setfunction!(dec, f); decode(dec))
decode(dec::Decoder, dist::L) where {L<:Integer} = (setdistance!(dec, dist); decode(dec))
function decode(dec::Decoder, f::AbstractBooleanFunction, dist::L) where {L<:Integer}
    setfunction!(dec, f)
    decode(dec, dist)
end

# * list

getdistances(dec::ListDecoder) = map(s->sums_to_distance(codelen(dec), s),
                                     dec.sums)

getbiases(dec::ListDecoder) = map(s->sums_to_bias(codelen(dec), s),
                                  dec.sums)

function ilist(dec::ListDecoder, opt1::Symbol=:bias, opts::Symbol...)
    dec.decoded || error("decoder $dec has not yet decoded")

    features=[opt1, opts...]
    ls = []
    !(:nofun in features || :fun in features) && push!(ls, dec.list)

    for f in features
        f == :bias  ? push!(ls, getbiases(dec)) :
        f == :dist  ? push!(ls, getdistances(dec)) :
        f == :fun   ? push!(ls, dec.list) :
        f == :sums  ? push!(ls, dec.sums) :
        f == :nofun ? nothing :
        error("options must be in [:bias, :dist, :sums, :fun, :nofun]")
    end
    zip(ls...)
end

list(dec::ListDecoder, opt1::Symbol=:bias, opts::Symbol...) =
    sort!(collect(ilist(dec, opt1, opts...)))

# * call

function (dec::ListDecoder)(f::AbstractBooleanFunction, opts::Symbol...)
    decode(dec, f)
    list(dec, opts...)
end

function (dec::ListDecoder)(dist::L, opts::Symbol...) where {L<:Integer}
    decode(dec, dist)
    list(dec, opts...)
end

function (dec::ListDecoder)(f::AbstractBooleanFunction, dist::L,
                            opts::Symbol...) where {L<:Integer}
    decode(dec, f, dist)
    list(dec, opts...)
end

end # module Decoding
