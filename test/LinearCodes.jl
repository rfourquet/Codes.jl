@testset "LinearCode:basics" begin
    G = GF(3)
    genmat = G[0 1 2;
               1 1 0]
    C = GeneratorCode(G, genmat)

    @test base_field(C) === G
    @test generator_matrix(C) === genmat
    @test dimension(C) == 2
    @test blocklength(C) == 3
end

@testset "LinearCode:encode" begin
    G = GF(3)
    genmat = G[0 1 2;
               1 1 0]
    C = GeneratorCode(G, genmat)

    @test encode(C, G[0 0]) == G[0 0 0]
    @test encode(C, G[1 2]) == G[2 0 2]
end
