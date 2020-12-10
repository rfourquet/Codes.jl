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
        end

        chan = ErrorChannel(dim+rand(1:9))
        @test_throws Exception transmit(chan, cw)
    end
end
