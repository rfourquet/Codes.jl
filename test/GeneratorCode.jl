@testset "GeneratorCode: basics" begin
    F = GF(3)
    G = F[0 1 2;
          1 1 0]
    for C = (GeneratorCode(F, G),
             LinearCode(F, G))

        @test base_field(C) === F
        @test generator_matrix(C) === G
        @test systematic_generator_matrix(C) == F[1 0 1; 0 1 2]
        @test check_matrix(C) == F[2 1 1]'
        @test parity_check_matrix(C) == F[2 1 1]
        @test dimension(C) == 2
        @test blocklength(C) == 3
        @test minimum_distance(C) == 2

        @test rand(C) in C
        @test all(in(C), rand(rng, C, 10))
    end

    for D = (GeneratorCode(F, check_matrix=F[2 1 1]'),
             LinearCode(F, check_matrix=F[2 1 1]'))

        @test rref(generator_matrix(D)) == rref(G) == (2, F[1 0 1; 0 1 2])
    end

    H = F[1 1 0;
          2 0 1]'
    E = GeneratorCode(F, check_matrix=H)
    @test base_field(E) == F
    @test check_matrix(E) === H
    @test dimension(E) == 1
    @test blocklength(E) == 3
    @test minimum_distance(E) == 3

    @test rand(E) in E
    @test all(in(E), rand(rng, E, 10))
end

@testset "GeneratorCode: iteration" begin
    F = GF(2)
    H = F[1 0 1 0; 1 1 0 1]'
    C = LinearCode(F, check_matrix=H)
    @test collect(C) == [F[0 0 0 0], F[1 1 1 0], F[0 1 0 1], F[1 0 1 1]]
end

@testset "GeneratorCode: encode" begin
    F = GF(3)
    G = F[0 1 2;
          1 1 0]
    C = GeneratorCode(F, G)
    M = message_space(C)

    @test encode(C, F[0 0]) == F[0 0 0]
    @test encode(C, F[1 2]) == F[2 0 2]

    for _=1:5
        @test iszero(encode(C, rand(M)) * check_matrix(C))
    end

    D = GeneratorCode(F, check_matrix=F[2 1 1]')
    for _=1:5
        @test iszero(encode(D, rand(M)) * check_matrix(D))
    end
end

@testset "GeneratorCode: decode" begin
    for F = (GF(2), GF(3))
        G = F[0 0 0 1 1 1 1;
              0 1 1 0 0 1 1;
              1 0 1 0 1 0 1]
        C = LinearCode(F, G) # [4-7]-HammingCode
        ndec = NearestNeighborDecoder(C)
        sdec = SyndromeDecoder(C, 1)
        for _=1:5
            msg = rand(message_space(C))
            cw = encode(C, msg)
            # 1 error
            for pos = 1:blocklength(C)
                word = copy(cw)
                word[1, pos] += F(1)
                @test decode(ndec, word) == cw
                @test decode(sdec, word) == cw
                word[1, pos] += F(1)
                @test decode(ndec, word) == cw
                @test decode(sdec, word) == cw
                if order(F) == 3
                    word[1, pos] += F(1)
                    @test decode(ndec, word) == cw
                    @test decode(sdec, word) == cw
                end
                @test word == cw # in any case
            end
        end
    end
end
