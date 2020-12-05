module Codes

export Code, ReedMuller, codelen, nvars, order, code

using Utils: iexp2, bitprecision
using InlineTest

import Base: convert

abstract type Code end

# * NVars, Order, Length (sanity checks)

# ** Nvars

struct NVars{T<:Integer}
    nvars::T

    NVars{T}(m) where {T} = m < 0 ? error("invalid number of variables $m (should be ≥ 0)") :
                       new(m)
end

NVars(m::T) where {T} = NVars{T}(m)
convert(::Type{NVars{T}}, m::T) where {T<:Integer} = NVars{T}(m)
convert(::Type{NVars{Int}}, m::Int) = NVars{Int}(m)
NVars(c::Code) = NVars(nvars(c))

# ** Order

struct Order{T<:Integer}
    order::T

    Order{T}(r::T) where {T} = r < -1 ? error("invalid order $r for Reed-Muller Codes (should be ≥ -1)") :
        new(r)
end

Order(r::T) where {T} = Order{T}(r)
Order(c::Code) = Order(order(c))

# ** Length

struct Length{T<:Integer}
    length::T

    Length{T}(n) where {T} = n < 0 ? error("invalid length $n (should be ≥ 0)") :
        new(n)
end

Length(n::T) where {T} = Length{T}(n)

# ** Conversion to Integer

Base.convert(::Type{T}, x::NVars{T}) where {T<:Integer} = x.nvars
Base.convert(::Type{T}, x::Order{T}) where {T<:Integer} = x.order
Base.convert(::Type{T}, x::Length{T}) where {T<:Integer} = x.length


# * generic codelen & code

"return the length of code `c`"
function codelen end

"return the code to which an object belongs, or associated with an object"
code(x) = error("undefined `code` for $x")


# * ReedMuller

struct ReedMuller <: Code
    order::Int
    nvars::Int

    function ReedMuller(r::Int, m::Int)
        NVars(m)
        r = min(r, m)
        Order(r)
        new(r, m)
    end
end

ReedMuller(nvars) = ReedMuller(nvars, nvars)

"return the number of variables of the `ReedMuller` code `c`"
nvars(c::ReedMuller) = c.nvars

"return the order of the `ReedMuller` code `c`"
order(c::ReedMuller) = c.order

function Length(::Type{ReedMuller}, m::NVars, ::Type{T}=Int) where {T<:Integer}
    m.nvars < bitprecision(T) ||
    error("$T overflow while computing the length of RM(., $(m.nvars))")
    Length(nvars_to_len(m.nvars, T))
end

Length(c::ReedMuller, ::Type{T}=Int) where {T<:Integer} = Length(ReedMuller, NVars(c), T)

codelen(c::ReedMuller, ::Type{T}=Int) where {T<:Integer} = convert(T, Length(c, T))

codelen(c::ReedMuller, ::Type{Float64}) = exp2(c.nvars)

"give the length (overflow unchecked) of Reed-Muller codes in `m` variables"
nvars_to_len(m::Int, ::Type{T}=Int) where {T<:Integer} = iexp2(T, m)

@testset "ReedMuller" begin
    c = ReedMuller(10)
    @test codelen(c) == 1024
    let cl = codelen(c, Float64)
        @test cl  == 1024.0
        @test isa(cl, Float64)
    end
    c = ReedMuller(1023)
    @test codelen(c, BigInt) == big(2)^1023
    @test log2(codelen(c, Float64)) == 1023

    @test nvars(c) == 1023
    @test_throws ErrorException ReedMuller(-2, 10)
    @test ReedMuller(20, 10) == ReedMuller(10, 10)
    c = ReedMuller(2, 5)
    @test nvars(c) == 5
    @test order(c) == 2
end

end # module Codes
