module Utils

export logsizeof, divsizeof, floorsizeof, mulsizeof, ilog2, iexp2,
       bitsizeof, bitprecision

# * Archi

const Archi = UInt64 == UInt ? 64 : 32

# * bitsizeof / bitprecision

bitsizeof(::Type{T}) where {T} = 8*sizeof(T)
bitsizeof(x::T) where {T} = bitsizeof(T)

"`bitprecision(T)` returns the maximum numbers of bits which can
be used to encode a non-negative integer of type `T`:
```
@assert bitprecision(Int64) == 63
@assert bitprecision(UInt64) == 64
@assert bitprecision(BigInt) == typemax(Int)
```"
bitprecision(::Type{T}) where {T<:Signed} = bitsizeof(T) - 1
bitprecision(::Type{T}) where {T<:Unsigned} = bitsizeof(T)
bitprecision(::Type{BigInt}) = typemax(Int)


# * integer log2 (on constants and variables)

checked_ilog2(n::Integer) = Int(log2(n))

# probably slower than using `log2` directly
function ilog2(n::Integer)
    m = 0
    while n >> m != 0
        m += 1
    end
    m-1
end

ilog2(n::Base.BitInteger) = bitsizeof(n) - leading_zeros(n) - 1


# * integer (or float) exp2

iexp2(::Type{T}, m) where {T<:Integer} = one(T) << m
iexp2(m) = 1 << m

function checked_iexp2(::Type{T}, m) where {T<:Integer}
    m < bitprecision(T) || throw(OverflowError("2^$m too big for type $T"))
    iexp2(T, m)
end

checked_iexp2(m) = checked_iexp2(Int, m)

# * logsizeof

logsizeof(::Type{T}) where {T} = ilog2(sizeof(T))

# ** tests

@assert logsizeof(Int8)   == 0
@assert logsizeof(Int16)  == 1
@assert logsizeof(Int32)  == 2
@assert logsizeof(UInt64) == 3
@assert logsizeof(Int128) == 4

# * divsizeof

divsizeof(::Type{T}, x::Integer) where {T} = x >> logsizeof(T)

@assert divsizeof(Int64, 15) == 1
@assert divsizeof(UInt128, 1023) == 0b111111

# * roundsizeof

# floorsizeof(T, x) == divsizeof(T, x) << logsizeof(T, x)
floorsizeof(::Type{T}, x::Integer) where {T} = x & -sizeof(T)

@assert floorsizeof(Int32, 15) == 12
@assert floorsizeof(UInt128, 15) == 0

# * mulsizeof

mulsizeof(::Type{T}, x::Integer) where {T} = x << logsizeof(T)

@assert mulsizeof(Int, 12345) == 12345*sizeof(Int)


# * :END:

end # Utils
