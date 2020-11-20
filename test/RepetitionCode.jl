@testset "RepetitionCode:basics" begin
    G = GF(3)
    C = RepetitionCode(G, 5)

    @test blocklength(C) == 5
    @test dimension(C) == 1
end

@testset "RepetitionCode:encode" begin
    G = GF(2)
    C = RepetitionCode(G, 3)

    m = [G(1)]
    w = encode(C, m)
    @test w isa Vector{elem_type(G)}
    @test w == fill(G(1), 3)

    m = G[0;]
    w = encode(C, m)
    @test w isa Generic.MatSpaceElem{elem_type(G)}
    @test w == G[0 0 0]

    m = G[0 1]
    @test_throws ArgumentError encode(C, m)
    F = GF(3)
    m = F[0;]
    @test_throws ArgumentError encode(C, m)
end
