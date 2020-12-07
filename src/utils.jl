function check_parent(c::Code, x)
    base_field(c) == parent(x) || throw(ArgumentError("incompatible fields"))
    nothing
end


vecsimilar(x, m) = _vecsimilar(x, size(x), m)

_vecsimilar(x, (n,)::NTuple{1}, m) = similar(x, m)
_vecsimilar(x, (n, m0)::NTuple{2}, m) = similar(x, _check_one(n), m)

function _check_one(n)
    isone(n) || throw(ArgumentError("expected a 1-dimensional vector"))
    n
end

veclen(x) = _veclen(size(x))

_veclen((n,)::NTuple{1}) = n
_veclen((n, m)::NTuple{2}) = (_check_one(n); m)

const MatrixElem = Union{AbstractMatrix,AbstractAlgebra.MatrixElem}

# TODO: move these methods to AbstractAlgebra.jl and import nrows/ncols from it
nrows(a::MatrixElem) = size(a, 1)
ncols(a::MatrixElem) = size(a, 2)

nrows(m::AbstractAlgebra.MatSpace) = AbstractAlgebra.nrows(m)
ncols(m::AbstractAlgebra.MatSpace) = AbstractAlgebra.ncols(m)

## vectors

"""
    hamming_weight(x)

Return the Hamming weight of vector `x`, i.e. the number of its non-zero coordinates.
"""
hamming_weight(x) = count(!iszero, x)

@testset "hamming_weight" begin
    F = AbstractAlgebra.GF(2)
    x = F[0 0 1 1 0 1]
    @test hamming_weight(x) == 3
    F = AbstractAlgebra.GF(3)
    x = F[0 1 2 2 2]
    @test hamming_weight(x) == 4
    @test hamming_weight(Matrix(x)) == 4
end

"""
    hamming_distance(x, y)

Return the Hamming distance between vectors `x` and `y`, i.e. the number of coordinates
where they differ.
"""
hamming_distance(x, y) = count(xy -> xy[1] != xy[2], zip(x, y))

@testset "hamming_distance" begin
    F = AbstractAlgebra.GF(2)
    @test hamming_distance(F[0 0 1 1 0 1],
                           F[0 1 1 0 0 1]) == 2
    F = AbstractAlgebra.GF(3)
    x = F[0 1 2 2 2]
    y = F[0 2 2 1 0]
    @test hamming_distance(x, y) == 3
    @test hamming_distance(Matrix(x), Matrix(y)) == 3
end


## iteration

### AA galois fields

struct FinFieldIterator{F}
    f::F
    n::Int
end

iterator(f::AbstractAlgebra.FinField) = FinFieldIterator(f, order(f))

Base.length(f::FinFieldIterator) = f.n
Base.eltype(f::FinFieldIterator) = elem_type(f.f)

function Base.iterate(f::FinFieldIterator, state=0)
    state == order(f.f) && return nothing
    f.f(state), state+1
end

### AA matrices

# TODO: compile-inefficient as it's based on Iterators.product, and overflow unchecked

struct MatSpaceIterator{M,I}
    m::M
    iters::I
end

function iterator(m::AbstractAlgebra.MatSpace)
    F = base_ring(m)
    MatSpaceIterator(m,
                     Iterators.product(iterator.(fill(F, nrows(m), ncols(m)))...))
end

Base.length(m::MatSpaceIterator) = length(iterator(base_ring(m.m)))^(nrows(m.m) * ncols(m.m))
Base.eltype(m::MatSpaceIterator) = elem_type(m.m)

function Base.iterate(m::MatSpaceIterator, state...)
    iters = iterate(m.iters, state...)
    iters === nothing && return nothing
    iters, state = iters
    m.m(collect(iters)), state
end
