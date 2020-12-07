@testset "GeneratorCode: basics" begin
    G = GF(3)
    genmat = G[0 1 2;
               1 1 0]
    C = GeneratorCode(G, genmat)

    @test base_field(C) === G
    @test generator_matrix(C) === genmat
    @test check_matrix(C) == G[2 1 1]'
    @test dimension(C) == 2
    @test blocklength(C) == 3
end

@testset "GeneratorCode: encode" begin
    G = GF(3)
    genmat = G[0 1 2;
               1 1 0]
    C = GeneratorCode(G, genmat)
    M = MatrixSpace(G, 1, 2) # message space

    @test encode(C, G[0 0]) == G[0 0 0]
    @test encode(C, G[1 2]) == G[2 0 2]

    for _=1:5
        @test iszero(encode(C, rand(M)) * check_matrix(C))
    end
end
