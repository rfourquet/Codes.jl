# * :BEGIN:
module FFT

export fft2!, Recursive, Iterative

using Utils: ilog2
using Iter, InlineTest

# * types
abstract type Traversal end
struct Recursive <: Traversal end
struct Iterative <: Traversal end

# * fft_step!
@inline function fft_step!(F, half, k)
    @inbounds for j in 1+k:half+k
        a, b = F[j], F[j + half]
        F[j], F[j + half] = a + b, a - b
    end
end

@inline function fft_step0!(F, half)
    for j in 1:half
        a, b = F[j], F[j + half]
        F[j], F[j + half] = a + b, a - b
    end
end

# * iterative

function fft2!(::Iterative, F::AbstractArray{T}, m::Int, shift::Int) where {T<:Number}
    Fp = Iter.citer(F) + shift
    for h in geom2n(1, m),
        k in 0 : h<<1 : 1<<m -1
            fft_step0!(Fp+k, h)
    end
    F
    # Below: too slow :(
    # for i = 1 : m,
    #     k = 0 : 1 << (m-i) -1
    #        fft_step!(F, 1<<(i-1), k<<i +shift)
    # end
end

# * recursive
const RECURSIVE_LIMIT = open("/sys/devices/system/cpu/cpu0/cache/index2/size") do x
    ksize = parse(Int, split(read(x, String), "K")[1])
    return 10 + # 1 K = 2^10 B
           ndigits(ksize, base=2) - 1
end

reclimit(::Type{T}) where {T} = RECURSIVE_LIMIT - ilog2(sizeof(T))

function fft2!(::Recursive, F::AbstractArray{T}, m::Int, shift::Int) where {T<:Number}
    m <= max(reclimit(T), 1) && return fft2!(Iterative(), F, m, shift)
    fft2!(Recursive(), F, m-1, shift)
    fft2!(Recursive(), F, m-1, shift + 1<<(m-1))
    fft_step!(F, 1<<(m-1), shift)
    F
end

# * public API

function fft2!(::M, F::AbstractArray{T}, m::Int) where {T<:Number, M<:Traversal}
    length(F) < 1<<m && throw(BoundsError())
    fft2!(M(), F, m, 0)
end


fft2!(F::AbstractArray{T}, m::Int) where {T<:Number} = fft2!(Recursive(), F, m)

fft2(::M, F::AbstractArray{T}, m::Int) where {T<:Number, M<:Traversal} = fft2!(M(), copy(F), m)
fft2(F::AbstractArray{T}, m::Int) where {T<:Number} = fft2!(copy(F), m)

# * tests

@testset "fft2!" begin
    f = [1, 1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, 1, -1, -1, -1]
    t = [0, 0, 8, 8, 0, 0, 0, 0, 4, -4, 4, -4, -4, 4, 4, -4]
    @test fft2(f, 4) == t
    @test fft2!(copy(f), 4) == t
    for T in (Iterative, Recursive)
        @test fft2(T(), f, 4) == t
        @test fft2!(T(), copy(f), 4) == t
    end
    @test_throws BoundsError fft2(f, 5)
    @test_throws BoundsError fft2([1, 2, 3], 2)
end

# * :END:

end # module FFT
