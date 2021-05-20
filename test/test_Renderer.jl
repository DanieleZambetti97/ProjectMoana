using ProjectMoana

## TESTING RENDERER METHODS ###############################################

@testset "UniformPigment tests" begin
    color = RGB(1.,2.,3.)
    pigment = UniformPigment(color)

    @test get_color(pigment, Vec2D(0.0, 0.0))≈color
    @test get_color(pigment, Vec2D(1.0, 0.0))≈color
    @test get_color(pigment, Vec2D(0.0, 1.0))≈color
    @test get_color(pigment, Vec2D(1.0, 1.0))≈color
end
