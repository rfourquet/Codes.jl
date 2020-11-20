@testset "RepetitionCode:basics" begin
    G = GF(3)
    C = RepetitionCode(G, 5)

    @test blocklength(C) == 5
    @test dimension(C) == 1
end
