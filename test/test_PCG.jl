using ProjectMoana

pcg = PCG()

@testset "PCG generator" begin
    @test pcg.state == 1753877967969059832
    @test pcg.inc == 109

    for expected in [2707161783, 2068313097, 3122475824, 2211639955, 3215226955, 3421331566]
        @test expected == pcg_rand(pcg)
    end

end