using ProjectMoana

a = Vec(1.0,2.0,3.0)
b = Vec(4.0,6.0,8.0)

@testset "Geometry Vec operation" begin
    @test isapprox(a,a)
    @test false == isapprox(a,b)
    @test isapprox(a+b ,Vec(5.0,8.0,11.0) )
    @test isapprox(b-a ,Vec(3.0,4.0,5.0) )
    @test isapprox(2*a, Vec(2.0,4.0,6.0))
    @test isapprox(a*b, 40)
    @test isapprox(cross(a,b) , Vec(-2,4,-2))
end