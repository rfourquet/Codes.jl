# MacWilliams & Sloane: The theory of error correcting codes

const F2 = GF(2)
const F3 = GF(3)

@testset "example codes MacWilliams & Sloane" begin
    H1 = F2[0 1 1 1 0 0;
            1 0 1 0 1 0;
            1 1 0 0 0 1]
    C1 = LinearCode(F2, check_matrix=H1')
    @test Codes.params(C1, true) == [6, 3, 3]

    H2 = F2[1 1 0 0 0;
            1 0 1 0 0;
            1 0 0 1 0;
            1 0 0 0 1]
    C2 = LinearCode(F2, check_matrix=H2')
    @test Codes.params(C2, true) == [5, 1, 5]
    @test collect(C2) == [F2[0 0 0 0 0], F2[1 1 1 1 1]]

    H3 = F2[1 1 1 1]
    C3 = LinearCode(F2, check_matrix=H3')
    @test Codes.params(C3, true) == [4, 3, 2]
    # TODO: add isless & eachrow for AA matrices/AA field elements (?)
    @test Set(C3) ==
        Set([ F2[0 0 0 0],
              F2[0 0 1 1],
              F2[0 1 0 1],
              F2[1 0 0 1],
              F2[0 1 1 0],
              F2[1 0 1 0],
              F2[1 1 0 0],
              F2[1 1 1 1] ])

    H4a = F2[1 0 1 0;
             1 1 0 1]
    H4b = F2[0 1 1 1;
             1 1 0 1]
    C4a = LinearCode(F2, check_matrix=H4a')
    C4b = LinearCode(F2, check_matrix=H4b')
    @test Set(C4a) == Set(C4b)
    @test systematic_generator_matrix(C4a) == F2[1 0 1 1;
                                                 0 1 0 1]
    @test Codes.params(C4a) == [4, 2]

    H5 = F2[0 1 1 1 1 0 0;
            1 0 1 1 0 1 0;
            1 1 0 1 0 0 1]

    H6 = F3[1 1 1 0;
            1 2 0 1]
    C6 = LinearCode(F3, check_matrix=H6')
    @test Codes.params(C6, true) == [4, 2, 3]
    @test Set(C6) == Set([ F3[0 0 0 0],
                           F3[0 1 2 1],
                           F3[0 2 1 2],
                           F3[1 0 2 2],
                           F3[1 1 1 0],
                           F3[1 2 0 1],
                           F3[2 0 1 1],
                           F3[2 1 0 2],
                           F3[2 2 2 0] ])
end
