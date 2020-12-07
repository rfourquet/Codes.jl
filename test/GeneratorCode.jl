@testset "GeneratorCode: basics" begin
    F = GF(3)
    G = F[0 1 2;
          1 1 0]
    for C = (GeneratorCode(F, G),
             LinearCode(F, G))

        @test base_field(C) === F
        @test generator_matrix(C) === G
        @test check_matrix(C) == F[2 1 1]'
        @test parity_check_matrix(C) == F[2 1 1]
        @test dimension(C) == 2
        @test blocklength(C) == 3
    end

    for D = (GeneratorCode(F, check_matrix=F[2 1 1]'),
             LinearCode(F, check_matrix=F[2 1 1]'))

        @test rref(generator_matrix(D)) == rref(G)
    end

    H = F[1 1 0;
          2 0 1]'
    E = GeneratorCode(F, check_matrix=H)
    @test base_field(E) == F
    @test check_matrix(E) === H
    @test dimension(E) == 1
    @test blocklength(E) == 3
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
