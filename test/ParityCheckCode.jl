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
