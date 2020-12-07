@testset "ParityCheckCode: basics" begin
    F = GF(3)
    C = ParityCheckCode(F, 3)
    @test blocklength(C) == 4
    @test dimension(C) == 3

    G = F[1 0 0 2
          0 1 0 2
          0 0 1 2]

    @test generator_matrix(C) == G
    @test systematic_generator_matrix(C) == G
    @test parity_check_matrix(C) == F[1 1 1 1]
end

@testset "ParityCheckCode: encode" begin
    F = GF(3)
    C = ParityCheckCode(F, 3)
    @test encode(C, F[2 2 2]) == F[2 2 2 0]
    @test encode(C, F[1 0 1]) == F[1 0 1 1]

    for _=1:5
        msg = rand(message_space(C))
        cw = encode(C, msg)
        for i=1:3
            @test msg[1, i] == cw[1, i]
            @test cw[1, end] == -sum(msg)
        end
    end
    for cw in C
        @test iszero(sum(cw))
    end
end
