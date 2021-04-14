using ProjectMoana

## TESTING GEOMETRY METHODS ###############################################

a = Point(1.0, 2.0, 3.0)
b = Point(4.0, 6.0, 8.0)

@testset "Point tests" begin
        @test isapprox(a,a) == true
        @test isapprox(a,b) == false
end


@testset "Point operations tests" begin
        @test isapprox((a * 2.), Point(2.0, 4.0, 6.0)) == true
        @test isapprox((a + b), Point(5.0, 8.0, 11.0)) == true
        #@test isapprox((b - a), Vec(3.0, 4.0, 5.0)) == true #uncomment when adding Vec - Vec method
end
