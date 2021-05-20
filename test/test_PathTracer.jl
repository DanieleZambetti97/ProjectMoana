using ProjectMoana
using ColorTypes

color = RGB(1.0, 2.0, 3.0)
pigment = UniformPigment(color)


image = HdrImage(2, 2)
set_pixel(image, 1, 1, Color(1.0, 2.0, 3.0))
set_pixel(image, 2, 1, Color(2.0, 3.0, 1.0))
set_pixel(image, 1, 2, Color(2.0, 1.0, 3.0))
set_pixel(image, 2, 2, Color(3.0, 2.0, 1.0))

pigment2 = ImagePigment(image)


color1 = RGB(1.0, 2.0, 3.0)
color2 = RGB(10.0, 20.0, 30.0)

pigment3 = CheckeredPigment(color1, color2, 2)

# With num_of_steps == 2, the pattern should be the following:
        #
        #              (0.5, 0)
        #   (0, 0) +------+------+ (1, 0)
        #          |      |      |
        #          | col1 | col2 |
        #          |      |      |
        # (0, 0.5) +------+------+ (1, 0.5)
        #          |      |      |
        #          | col2 | col1 |
        #          |      |      |
        #   (0, 1) +------+------+ (1, 1)
        #              (0.5, 1)


@testset "Test Pigments" begin
    ## testing UniformPigment
    @test get_color(pigment, Vec2D(0.0, 0.0)) ≈ color    
    @test get_color(pigment, Vec2D(1.0, 0.0)) ≈ color
    @test get_color(pigment, Vec2D(0.0, 1.0)) ≈ color
    @test get_color(pigment, Vec2D(1.0, 1.0)) ≈ color

    ## testing ImagePigment
    @test get_color(pigment2, Vec2D(0.0, 0.0)) ≈ RGB(1.0, 2.0, 3.0)
    @test get_color(pigment2, Vec2D(1.0, 0.0)) ≈ RGB(2.0, 3.0, 1.0)
    @test get_color(pigment2, Vec2D(0.0, 1.0)) ≈ RGB(2.0, 1.0, 3.0)
    @test get_color(pigment2, Vec2D(1.0, 1.0)) ≈ RGB(3.0, 2.0, 1.0)

    ## testing CheckeredPigment
    @test get_color(pigment3, Vec2D(0.25, 0.25)) ≈ color1
    @test get_color(pigment3, Vec2D(0.75, 0.25)) ≈ color2
    @test get_color(pigment3, Vec2D(0.25, 0.75)) ≈ color2
    @test get_color(pigment3, Vec2D(0.75, 0.75)) ≈ color1


end


