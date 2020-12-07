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
