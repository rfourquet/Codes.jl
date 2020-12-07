@testset "RepetitionCode:basics" begin
    G = GF(3)
    C = RepetitionCode(G, 5)

    @test base_field(C) === G
    @test blocklength(C) == 5
    @test dimension(C) == 1
    @test generator_matrix(C) == G[1 1 1 1 1]
    @test systematic_generator_matrix(C) == G[1 1 1 1 1]
    @test collect(C) == [G[0 0 0 0 0], G[1 1 1 1 1], G[2 2 2 2 2]]

    F = GF(2)
    C = RepetitionCode(F, 5)
    @test check_matrix(C) == F[1 1 0 0 0;
                               1 0 1 0 0;
                               1 0 0 1 0;
                               1 0 0 0 1]'
    @test parity_check_matrix(C) == F[1 1 0 0 0;
                                      1 0 1 0 0;
                                      1 0 0 1 0;
                                      1 0 0 0 1]

    @test collect(C) == [F[0 0 0 0 0], F[1 1 1 1 1]]
end

@testset "RepetitionCode:encode" begin
    G = GF(2)
    C = RepetitionCode(G, 3)
    L = LinearCode(G, generator_matrix(C))

    m = [G(1)]
    w = encode(C, m)
    @test w isa Vector{elem_type(G)}
    @test w == fill(G(1), 3)

    m = G[0;]
    w = encode(C, m)
    @test w isa Generic.MatSpaceElem{elem_type(G)}
    @test w == G[0 0 0]
    @test w == encode(L, m)

    m = G[1;]
    @test encode(C, m) == encode(L, m)

    m = G[0 1]
    @test_throws ArgumentError encode(C, m)
    F = GF(3)
    m = F[0;]
    @test_throws ArgumentError encode(C, m)
end

@testset "RepetitionCode:decode" begin
    G = GF(2)
    C = RepetitionCode(G, 3)

    for (O, I) in ((zero(G), one(G)), (one(G), zero(G)))
        for w0 in ([O O O], [O O I], [O I O], [I O O])
            for (w, m) in (w0 => fill(O, 1, 1), matrix(G, w0) => G[O;])
                @test decode(C, w) == m
            end
        end
    end

    G = GF(3)
    C = RepetitionCode(G, 3)
    a, b, c = G.(0:2)

    for (x, y, z) in ((a, b, c), (a, c, b), (b, a, c), (b, c, a), (c, a, b), (c, b, a))
        for w0 in ([x x x], [x x y], [x x z],
                   [x y x], [x z x],
                   [y x x], [z x x])
            for (w, m) in (w0 => fill(x, 1, 1), matrix(G, w0) => G[x;])
                @test decode(C, w) == m
            end
        end
    end
end
