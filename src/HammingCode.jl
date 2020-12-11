struct HammingCode{F,M<:MatrixElem} <: AbstractGeneratorCode{F,M}
    field::F
    order::Int
    genmat::M
    checkmat::M

    function HammingCode(field, r::Integer)
        q = order(field)
        r = Int(r)
        n = (q^r-1) ÷ (q-1)
        k = n-r
        H = hamming_check_matrix(field, r, n)
        k, G = left_kernel(H)
        code = new{typeof(field),typeof(H)}(field, r, G, H)

        # sanity checks
        @assert blocklength(code) == n
        @assert dimension(code) == k

        code
    end
end

maybe_minimum_distance(::HammingCode) = 3

function hamming_check_matrix(F, r, n)
    H = zero_matrix(F, n, r)
    H[1, 1] = one(F)
    lead = 1
    for i=2:n
        carry = true
        for j=1:lead-1
            x = H[i-1, j]
            if carry
                x += one(F)
                if !iszero(x)
                    carry = false
                end
            end
            H[i, j] = x
        end
        if carry
            # H[i, lead] = zero(F) # automatic via zero_matrix above
            lead += 1
        end
        H[i, lead] = one(F)
    end
    @assert lead == r
    @assert isone(H[end, end])
    maxF = zero(F)-one(F)
    for j=1:r-1
        @assert H[end, j] == maxF
    end
    H
end
