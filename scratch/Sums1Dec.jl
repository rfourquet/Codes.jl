module Sums1Dec
export Sums1

using Codes, TruthTables, BooleanFunctions, FFT

import FFT: fft2!
using Decoding
import Decoding: decode, setfunction!
import Codes: code
import BooleanFunctions: nvars

# * fft2! on PseudoTable

using FFT
import FFT.fft2!

fft2!(t::PseudoTable) = (fft2!(t.vec, nvars(t)); t)
fft2(f::AbstractBooleanFunction) = fft2!(truthtable(PseudoView(f)))

# * Sums1

mutable struct Sums1{S<:Real} <: SumsDecoder{S}
    fft::PseudoTable{S}
    fun::Union{AbstractBooleanFunction,Nothing}
    bias::Float64
    list::Vector{Linear{UInt}}
    sums::Vector{S}
    decoded::Bool

    Sums1{S}() where {S} = new{S}(PseudoTable{S}(0), nothing,
                                  1.0,
                                  Linear{UInt}[],
                                  S[],
                                  false)
end

Sums1() = Sums1{Int}()
SoftSums1() = Sums1{Float64}()

code(dec::Sums1) = ReedMuller(1, nvars(dec))
nvars(dec::Sums1) = nvars(dec.fun)

function setfunction!(dec::Sums1, f::AbstractBooleanFunction)
    (dec.fun === nothing || nvars(dec) != nvars(f)) && (dec.fft = PseudoTable(nvars(f)))
    dec.fun = f
    dec.decoded = false
    dec
end

resetfunction!(dec::Sums1) = assign!(dec.fft, PseudoView(dec.fun))

function _decode_fft(dec::Sums1, fft, thr)
    fft2!(fft)
    empty!(dec.list)
    empty!(dec.sums)
    for i in 0:endvec(fft)
         if abs(fft[i]) >= thr
           push!(dec.list, Linear(i % UInt))
           push!(dec.sums, fft[i])
       end
    end
    dec.decoded = true
    length(dec.list)
end

decode(dec::Sums1) = _decode_fft(dec, resetfunction!(dec), threshold(dec))

# ** show

function Base.show(io::IO, dec::Sums1)
    print(io, "Sums1 decoder with bias $(dec.bias)")
    if dec.fun !== nothing
        print(io,
              " (distance $(Decoding.distance(dec))) " *
              "for $(code(dec))")
    end
end

end
