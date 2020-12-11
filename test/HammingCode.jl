@testset "HammingCode ($F)" for (F, nkd) = (GF(2) => [7, 4, 3],
                                            GF(3) => [13, 10, 3])

    H = HammingCode(F, 3)
    @testset "basics" begin
        @test Codes.params(H) == nkd
        @test base_field(H) == F
        @test rand(H) in H
        if order(F) == 2
            Helts = collect(H)
            @test length(Helts) == 2^4
        end
    end

    @testset "encode & decode" begin
        S = message_space(H)
        chan = ErrorChannel((0, 1, 1, 1))
        ndec = NearestNeighborDecoder(H)
        sdec = SyndromeDecoder(H, 1)
        for _=1:10
            msg = rand(S)
            cw = encode(H, msg)
            rw = transmit(chan, cw)
            for dec = (ndec, sdec)
                @test cw == decode(dec, rw)
            end
        end
    end
end
