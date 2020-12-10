@testset "Channel: basics" begin
    chan = SymmetricChannel(.3)
    @test error_probability(chan) == 0.3
    @test_throws ArgumentError SymmetricChannel(-0.1)
    @test_throws ArgumentError SymmetricChannel(1.1)

    chan = ErrorChannel((1, 2, 3))
    @test nerror_distribution(chan) == (1, 2, 3)
    chan = ErrorChannel(3)
    @test nerror_distribution(chan) == (3,) # might change, but must always yield 3
    @test_throws ArgumentError ErrorChannel([1.1, 2.2])
end

@testset "ErrorChannel: transmit" begin
    for F = (GF(2), GF(5))
        dim = rand(1:9)
        S = MatrixSpace(F, 1, dim)

        cw = rand(S)
        z = zero(S)

        for i = 0:dim
            chan = ErrorChannel(i)
            @test hamming_distance(cw, transmit(chan, cw)) == i

            # reproducibility
            Random.seed!(0)
            err = transmit(chan, z)
            @test hamming_weight(transmit(chan, z)) == i
            Random.seed!(0)
            @test err == transmit(chan, z)

            # passing an explicit RNG
            chan = ErrorChannel(i, rng=MersenneTwister(0))
            @test err == transmit(chan, z)

            # non-Int passed distribution
            j = rand(0:i)
            chan = ErrorChannel(j:i)
            @test hamming_distance(cw, transmit(chan, cw)) ∈ j:i
        end

        chan = ErrorChannel(dim+rand(1:9))
        @test_throws Exception transmit(chan, cw)
    end
end
