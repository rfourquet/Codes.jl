# * :BEGIN:

module BooleanFunctions

export AbstractVectorialBooleanFunction, AbstractBooleanFunction,
       VectorialBooleanFunction, BooleanFunction,
       SignedBooleanFunction, PseudoBooleanFunction

export evaluate, nvars, nvarsmax, endvar, degree, order, outdim,
       setnvars!, assign!,
       proj, support, supportw, vectype, isconstant, endvec,
       showmod,
       code,
       bf0, bf1, Constant # should we export Constant ?

export SignView, PseudoView, BinaryView

import Base: +, *, <<, >>, ~, &, ⊻, |, iszero

using Utils

using Codes
import Codes: nvars, order, codelen, code

using Words
import Words: support

# * types

abstract type Value end
struct Binary <: Value end
struct Sign   <: Value end
struct Pseudo <: Value end

abstract type AbstractVectorialBooleanFunction{V} end
const AVBF{V} = AbstractVectorialBooleanFunction{V}

abstract type AbstractBooleanFunction{V} <: AVBF{V} end
const ABF{V} = AbstractBooleanFunction{V}

const VectorialBooleanFunction = AVBF{Binary}
const BooleanFunction          = ABF{Binary}
const SignedBooleanFunction    = ABF{Sign}
const PseudoBooleanFunction    = ABF{Pseudo}

const AbstractVectorialPseudo = Union{AVBF{Sign}, AVBF{Pseudo}}
const AbstractPseudo = Union{ABF{Sign}, ABF{Pseudo}}


# * fallbacks

evaluate(f::AVBF, v) = evaluate(f, convert(vectype(f), v))
(f::AVBF)(v) = evaluate(f, v)

support(f::AVBF) = support(supportw(f))
outdim(f::ABF) = 1

notimplemented() = error("not implemented")

vectype(f::AVBF) = notimplemented()

"`endvect(f)`: last vector for evaluating `f`, e.g. `2^nvars(f)-1` if
    `isa(vectype(f), Integer)` "
endvec(f::AVBF) = notimplemented()

endvar(f::AVBF) = numvars(f) - 1

"""return the number of actual variables of a Boolean function `f`
   (not accounting for "holes", e.g. `numvars(x0+x2) == 3` (`x0, x1, x2`),
   that is the smallest number of variables of a Reed-Muller
   code into which `f` can embed"""
numvars(f::AVBF) = endvar(f) + 1

"give the nvars of the natural Reed-Muller code into which `f` embeds; it should be 𝒪(1), and is an upper-bound of `nvars(f)`"
nvarsmax(f::AVBF) = nvars(code(f))

"return an upper-bound of `numvars` which is fast to compute
      and possibly less than nvarsmax"
nvars(f::AVBF) = numvars(f)

"set up `f` such that it can hold Boolean functions of at least `m` variables"
setnvars!(f::AVBF, m) = notimplemented()

"`assign!(f, g)` sets `f` to be equal to `g` on the smallest `Bₙ` containing `f` and `g`"
assign!(f::AVBF, g::AVBF) = notimplemented()

"give the natural `ReedMuller` code to which `f` belong; it should be 𝒪(1)"
@generated function code(f::AVBF)
    for (i, t) in enumerate(f.types)
        if t === Codes.ReedMuller
            return :(getfield(f, $i))
        end
    end
    return :(ReedMuller(order(f), nvarsmax(f)))
end

"give the order of the natural Reed-Muller code into which `f` embeds; it should be 𝒪(1), and is an upper-bound of `degree(f)`"
order(f::AVBF) = order(code(f))
degree(f::AVBF) = notimplemented()

codelen(f::AVBF) = codelen(code(f))

supportw(f::AVBF) = notimplemented()

"projects `f` on the first m variables (equivalent to evaluating variables m+1, ..., n at 0)"
proj(f::AVBF, m::Int) = notimplemented()
"number of 2-dimensions of the vectorial Boolean function `f` (return 1 for `AbstractBooleanFunction`)"
outdim(f::AVBF) = notimplemented()

isconstant(f::AVBF) = notimplemented()
isconstant(f::ABF)  = degree(f) <= 0
depends(f::AVBF, v::AbstractWord) = supportw(f) & v != 0
depends_only(f::AVBF, v::AbstractWord) = supportw(f) ⪯ v
Words.preceq(f::AVBF, v::AbstractWord) = depends_only(f, v)

"""`f` may have alternative ways of being represented,
   `showmod(f, m)` switches to mode `m`"""
showmod(f::AVBF, m) = notimplemented()

# * views


for (T, A) = [(:PseudoView, :PseudoBooleanFunction),
              (:SignView, :SignedBooleanFunction),
              (:BinaryView, :BooleanFunction)]
    @eval begin
        struct $T{B<:ABF} <: $A
            fun::B
        end

        code(f::$T) = code(f.fun)
        nvars(f::$T) = nvars(f.fun)

        @generated function evaluate(f::$T, x)
            if f <: AbstractPseudo
                if f.types[1] <: BooleanFunction
                    :(ifelse(f.fun(x) == 0 , 1, -1))
                elseif f.types[1] <: SignedBooleanFunction ||
                       f.types[1] <: PseudoBooleanFunction && f == PseudoView
                    :(f.fun(x))
                else
                    quote
                        y = f.fun(x)
                        y != 1 && y != -1 &&
                            error("wrapped function has value $y at $x not in [-1, 1]")
                        return y
                    end
                end
            else # f is Binary
                if f.types[1] <: BooleanFunction
                    :(f.fun(x))
                elseif f.types[1] <: SignedBooleanFunction
                    :((1-f.fun(x))>>1) # ifelse(f.fun(x)==1, 0, 1)
                else
                    y = f.fun(x)
                    y != 1 && y != -1 &&
                        error("wrapped function has value $y at $x not in [-1, 1]")
                    return y
                end
            end
        end
    end
end


# * utils

# computes the nvars from a code length
len2nvars(n::Int) = sizeof(n)<<3 - leading_zeros(n-1)

# * Constant

struct Constant <: BooleanFunction
    constant::Bool
end

evaluate(c::Constant, v) = c.constant
vectype(::Constant) = UInt # not sure what is best here
isconstant(::Constant) = true
degree(c::Constant) = c.constant-1

const bf0 = Constant(0)
const bf1 = Constant(1)

# * Linear & Monomial

using InlineTest, Rand
import Random
using Random: AbstractRNG
export Linear, Monomial

# ** common definitions

for B in [:Linear, :Monomial]
    Bs = "$B generic"
    @eval begin

        struct $B{W<:AbstractWord} <: BooleanFunction
            word::W
        end

        $B(bits::AbstractArray{T}) where {T<:Integer} = $B(bitfield(bits))
        $B(::Type{W}, bits) where {W} = $B(bitfield(W, bits))
        $B(::Type{W}=Word) where {W} = $B(zero(W))

        (f::$B)(v) = evaluate(f, v)

        vectype(::$B{W}) where {W} = W
        vectype(::Type{$B{W}}) where {W} = W

        isconstant(x::$B) = x === $B()

        <<(x::$B, i::Integer) = $B(x.word << i)
        >>(x::$B, i::Integer) = $B(x.word >> i)
        ~(x::$B) = $B(~x.word)
        (&)(x::$B, y::$B) = $B(x.word & y.word)
        (⊻)(x::$B, y::$B) = $B(x.word ⊻ y.word)
        |(x::$B, y::$B) = $B(x.word | y.word)

        Base.isless(x::$B, y::$B) = x.word < y.word # useful for e.g. sorting

        @genrandwrapper $B
        Random.rand(rng::AbstractRNG, ::Random.SamplerType{$B}) = rand(rng, $B{Word})

        support(x::$B) = support(x.word)
        supportw(x::$B) = x.word
        truncate(x::$B, m::Int) = $B(masked(x.word, m))

        nvarsmax(x::$B) = bitsize(x.word)
        endvar(x::$B) = highbit(x.word)

        nvars(x::$B) where {W<:Words.Virtual} = x.word < 0 ? Words.POSINF : endvar(x) + 1

        Base.getindex(x::$B, i) = bit(x.word, i)

        # *** test
        @testset $Bs begin
            for T in [UInt8, UInt, Int]
                l = $B(T(10))
                @test l[1] == l[3] == 1
                @test supportw(l) == 10
                @test support(l) == [1, 3]
                @test vectype(l) == T
                @test nvars(l) == 4
                if $B == Linear
                    @test l(10) == 0
                    @test l(2) == 1
                else
                    @test l(10) == true
                    @test l(2)  == false
                end
                @test l == $B(T, [1, 3])
                T == Word && @test l == $B([1, 3])
                for i in 1:10
                    l = rand($B{T})
                    if T <: Signed
                        l = truncate(l, bitsizeof(T)-1)
                    end
                    @test $B(T, support(l)) == l
                end
            end
            l = Linear(-1)
            @test nvars(l) == endvar(l) == Words.POSINF > 0
        end
    end
end

# ** Linears

+(x::Linear{W}, y::Linear{W}) where {W} = Linear{W}(x.word ⊻ y.word)
Base.zero(::Type{Linear{W}}) where {W} = Linear(W)
iszero(x::Linear) = iszero(x.word)

evaluate(x::Linear{W}, v::W) where {W} = weight2(v & x.word)

order(x::Linear) = 1
degree(x::Linear) = ifelse(iszero(x), -1, 1)

# *** IO
Base.show(io::IO, x::Linear) =
    print(io,
          x.word == 0 ? "0" :
                        join(["x"*string(i) for i in support(x)], " + "))


# ** Monomial

*(x::M, y::M) where {M<:Monomial} = x | y
Base.one(::Type{Monomial{W}}) where {W} = Monomial(W)
Base.one(x::Monomial) = one(typeof(x))

evaluate(x::Monomial{W}, v::W) where {W} = x.word ⪯ v

order(x::Monomial) = nvarsmax(x)
degree(x::Monomial) = weight(x.word)

# *** IO

function Base.show(io::IO, x::Monomial)
    if x == one(x)
        print(io, "Mon(1)")
    else
        print(io, join(["x$i" for i in support(x)]))
    end
end


# * SparseANF

export SparseANF

struct SparseANF{W<:AbstractWord,L<:AbstractVector{Monomial{W}}} <: BooleanFunction
    monomials::L
    # TODO: add "dirty" flag for compact

    SparseANF(ms=Monomial{Word}[]) = new{vectype(eltype(ms)),typeof(ms)}(ms)
end

vectype(f::SparseANF{W}) where {W} = W
support(f::SparseANF) = support(supportw(f))
supportw(f::SparseANF) = mapreduce(supportw, |, compact!(f).monomials,
                                   init=zero(vectype(f)))

nvarsmax(f::SparseANF) = bitsize(vectype(f))
nvars(f::SparseANF) = maximum(nvars, f.monomials, init=0)
endvar(f::SparseANF) = nvars(f)-1

degree(f::SparseANF) = maximum(degree, f.monomials, init=-1)

Base.iszero(f::SparseANF) = isempty(compact!(f).monomials)
Base.copy(f::SparseANF) = SparseANF(copy(f.monomials))

# remove duplicate monomials
function compact!(f::SparseANF)
    ms = f.monomials
    sort!(ms)
    imon = newmon = firstindex(ms)
    lmon = lastindex(ms)
    @inbounds while imon <= lmon
        if imon != lmon && ms[imon] == ms[imon+1]
            imon += 2 # two identical monomials cancel out
        else
            ms[newmon] = ms[imon]
            newmon += 1
            imon += 1
        end
    end
    resize!(ms, newmon-firstindex(ms))
    f
end

function addeq!(x::SparseANF{W}, y::SparseANF{W}) where {W}
    append!(x.monomials, y.monomials)
    x
end

+(x::SparseANF{W}, y::SparseANF{W}) where {W} = addeq!(copy(x), y)

function addeq!(x::SparseANF{W}, y::Monomial{W}) where {W}
    push!(x.monomials, y)
    x
end

+(x::SparseANF{W}, y::Monomial{W}) where {W} = addeq!(copy(x), y)
+(x::Monomial{W}, y::SparseANF{W}) where {W} = y+x
+(x::Monomial{W}, y::Monomial{W}) where {W} = SparseANF([x])+y

function muleq!(x::SparseANF{W}, y::SparseANF{W}) where {W}
    z = x*y
    copy!(x.monomials, z.monomials) # TODO: optimize?
    x
end

function *(x::SparseANF{W}, y::SparseANF{W}) where {W}
    z = SparseANF(Monomial{W}[])
    for m in y.monomials
        addeq!(z, x*m)
    end
    compact!(z)
end

function muleq!(x::SparseANF{W}, y::Monomial{W}) where {W}
    map!(m -> m*y, x.monomials, x.monomials)
    x
end

*(x::SparseANF{W}, y::Monomial{W}) where {W} = muleq!(copy(x), y)
*(x::Monomial{W}, y::SparseANF{W}) where {W} = y*x


function Base.show(io::IO, f::SparseANF)
    if iszero(f) # does compact!
        print(io, "0")
    else
        join(io, sprint.(show, f.monomials), " + ")
    end
end

@testset "SparseANF" begin
    f = SparseANF()
    @test string(f) == "0"
    m = Monomial(UInt[1, 3])
    @test string(f+m) == "x1x3"
    f += m
    @test iszero(f+f)
    @test iszero(f+m)
    f = f+m+m
    compact!(f)
    @test only(f.monomials) == m
    @test support(f) == support(m)

    f = m+m # not compacted
    @test isempty(support(f))
    @test nvarsmax(f) == nvarsmax(m)
    @test nvars(f) == 0
    @test degree(f) == -1

    f = m+Monomial(UInt[4])
    @test string(f) == "x1x3 + x4"
    @test nvars(f) == 5
    @test degree(f) == 2
    @test support(f) == [1, 3, 4]
    @test supportw(f) == 0b11010
end


# * :END:


end # module BooleanFunctions
