using ProjectMoana
## TESTING RAY METHODS ###############################################

ray1 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
ray2 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
ray3 = Ray(Point(5.0, 1.0, 4.0), Vec(3.0, 9.0, 4.0))

ray4 = Ray(Point(1.0, 2.0, 4.0), Vec(4.0, 2.0, 1.0))

@testset "Ray tests" begin
    @test isapprox(ray1, ray2)
    @test isapprox(ray1, ray3) == false
    @test isapprox(at(ray4, 0.0), ray4.origin)
    @test isapprox(at(ray4, 1.0), Point(5.0, 4.0, 5.0))
    @test isapprox(at(ray4, 2.0), Point(9.0, 6.0, 6.0))
end