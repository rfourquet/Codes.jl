# * :BEGIN:

module TruthTables

export TruthTable, PseudoTable, truthtable

using BooleanFunctions
import BooleanFunctions: nvars, evaluate, code, vectype, assign!, endvec

using Utils, Words, Codes, InlineTest

using Random


# * AbstractTruthTable (if it was possible...)

macro generatetablemethods(T)
    @eval begin
        Base.length(tt::$T) = length(tt.vec)
        vectype(::$T) = Int
        endvec(tt::$T) = tt.endvec
        nvars(tt::$T) = tt.m
        code(tt::$T) = ReedMuller(nvars(tt))
        evaluate(tt::$T, x::Int) = @inbounds return tt.vec[1+ x & tt.endvec]
        Base.getindex(tt::$T, x::Int) = tt.vec[1+x]
        Base.setindex!(tt::$T, v, x::Int) = tt.vec[1+x] = v

        function Base.setindex!(tt::$T, f::supertype($T), r::AbstractArray{<:Integer})
            0 <= minimum(r) && maximum(r) <= lastindex(tt) ||
                error("out of bounds indexing range")
            for x in r
                @inbounds tt[x] = f(x)
            end
            tt
        end

        Base.setindex!(tt::$T, f::supertype($T), ::Colon) = tt[0:end] = f
        Base.setindex!(tt::$T, f::supertype($T)) = tt[0:end] = f

        Base.lastindex(tt::$T) = endvec(tt)

        Random.rand!(rng::AbstractRNG, tt::$T) = (rand!(rng, tt.vec); tt)
        Random.rand!(tt::$T) = rand!(Random.GLOBAL_RNG, tt)

        function assign!(tt::$T, f::supertype($T))
            nvars(f) > nvars(tt) &&
                error("trying to assign a function ($f) which has more variables than $tt")
            # TODO: optimize by calling f only once on similar values when
            # nvars(f) < nvars(tt)
            tt[] = f
            tt
        end

        $T(f::supertype($T), m=nvars(f)) = assign!($T(m), f)
    end
end

# * TruthTable

struct TruthTable <: BooleanFunction
    m::Int
    endvec::Int
    vec::BitVector

    function TruthTable(m::Int, init=falses)
        len = codelen(ReedMuller(m))
        t =
            if init == falses
                falses(len)
            elseif init == trues
                trues(len)
            elseif init == undef
                BitVector(undef, len)
            else
                error("invalid TruthTable initialization mode")
            end
        new(m, len-1, t)
    end

end

function TruthTable(v::BitVector)
    ispow2(length(v)) ||
        throw(ArgumentError("BitVector's length (got $(length(v))) must be a power of 2"))
    t = TruthTable(ilog2(length(v)), undef)
    @assert length(v) == length(t.vec)
    copy!(t.vec, v)
    t
end

@generatetablemethods(TruthTable)


# ** Tests

@testset "TruthTable" begin
    t = TruthTable(4)
    @test nvars(t) == 4
    @test codelen(t) == 16
    @test length(t) == 16
    l = Linear(0x9)
    t = TruthTable(l)
    @test findall(t.vec) .- 1 == support(0b0101010110101010)
    assign!(t, l)
    @test findall(t.vec) .- 1 == support(0b0101010110101010)
end

# ** Array stuff

function Base.vcat(tts::TruthTable...)
    len0 = sum(map(length, tts))
    len = nextpow(2, len0)
    rem = falses(len-len0)
    TruthTable(vcat([tt.vec for tt in tts]..., rem))
end

# ** IO

SHOWMOD = :bit # :hex, :bit

"""`showmod(t::TruthTable, mode=:bit)`:
   `mode` can be `:hex` or `:bit`
"""
function showmod(::Type{TruthTable}, mode)
    !(mode in [:hex, :bit]) && error("showmod(::TruthTable): mode must be `:bit` or `:hex`")
    global SHOWMOD = mode
end



Base.summary(tt::TruthTable) = "Binary TruthTable in $(nvars(tt)) variables"

function Base.show(io::IO, ::MIME"text/plain", tt::TruthTable)
    println(io, summary(tt))
    show(io, tt)
end


function Base.show(io::IO, tt::TruthTable)
    if SHOWMOD == :hex && get(io, :compact, false) == false
        print(io, "0x")
    end
    print(io, "|")
    if SHOWMOD == :bit
        for x=1:length(tt)
            print(io, tt.vec[x] ? 1 : 0)
        end
    elseif SHOWMOD == :hex
        if length(tt) < Sys.WORD_SIZE
            print(io, string(tt.vec.chunks[1], base=16, pad=Int(length(tt)/4)))
        else
            for c in reverse(tt.vec.chunks)
                print(io, string(c, base=16, pad=Int(Sys.WORD_SIZE/4)))
            end
        end
    end
    print(io, "|")
end

# * PseudoTable

# note: if N > 1, this sould be PseudoVectorialBooleanFunction
# but there is currently no way to set it to PseudoBooleanFunction
# automatically when N==1
# this will be used first mainly with N==1

# struct PseudoTable{T, N} <: PseudoBooleanFunction

struct PseudoTable{T} <: PseudoBooleanFunction
    m::Int
    endvec::Int
    vec::Vector{T}

    function PseudoTable{T}(m::Int) where {T}
        len = codelen(ReedMuller(m))
        new(m, len-1, zeros(T, len))
    end
end

PseudoTable(m) = PseudoTable{Int}(m)

@generatetablemethods(PseudoTable)


# ** IO

Base.summary(tt::PseudoTable) = "Pseudo TruthTable in $(nvars(tt)) variables"

function Base.show(io::IO, ::MIME"text/plain", tt::PseudoTable)
    println(io, summary(tt))
    show(io, tt)
end

function Base.show(io::IO, tt::PseudoTable)
    print(io, "|")
    for x=1:length(tt)
        print(io, tt.vec[x], ' ')
    end
    print(io, "|")
end


# * generic constructor

truthtable(f::BooleanFunction, m=nvars(f)) = TruthTable(f, m)

truthtable(f::PseudoBooleanFunction, m=nvars(f)) = PseudoTable(f, m)

truthtable(f::SignedBooleanFunction, m=nvars(f)) = SignView(truthtable(BinaryView(f), m))


# * :END:

end # module
