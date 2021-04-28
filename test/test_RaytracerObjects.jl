using ProjectMoana
using ColorTypes
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

## TESTING ImageTracer METHODS ###############################################

image = HdrImage(width = 4, height = 2)
camera = PerspectiveCamera(aspect_ratio = 2)
tracer = ImageTracer(image = image, camera = camera)

ray1 = fire_ray(tracer, 0, 0, 2.5, 1.5)
ray2 = fire_ray(tracer, 2, 1, 0.5, 0.5)

fire_all_rays(tracer, ray -> Color(1.0, 2.0, 3.0))

@testset "ImageTracer tests" begin
    @test isapprox(ray1, ray2)
    for row ∈ 1:image.height
        for col ∈ 1:image.width
            @test image.get_pixel(col, row) == Color(1.0, 2.0, 3.0)
    
end