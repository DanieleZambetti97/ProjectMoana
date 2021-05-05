    using ProjectMoana
using ColorTypes
## TESTING RAY METHODS ###############################################

@testset "Ray tests   " begin
    ray1 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
    ray2 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
    ray3 = Ray(Point(5.0, 1.0, 4.0), Vec(3.0, 9.0, 4.0))
    ray4 = Ray(Point(1.0, 2.0, 4.0), Vec(4.0, 2.0, 1.0))
    
    @test isapprox(ray1, ray2)
    @test isapprox(ray1, ray3) == false
    @test isapprox(at(ray4, 0.0), ray4.origin)
    @test isapprox(at(ray4, 1.0), Point(5.0, 4.0, 5.0))
    @test isapprox(at(ray4, 2.0), Point(9.0, 6.0, 6.0))

end

@testset "Camera tests" begin

    ray = Ray( Point(1.0, 2.0, 3.0), Vec(6.0, 5.0, 4.0))
    transformation = translation( Vec(10.0, 11.0, 12.0) ) * rotation_x(pi/2.0)
    transformed = transformation * ray
    
    @test isapprox( Point(11.0, 8.0, 14.0), transformed.origin)
    @test isapprox( Vec(6.0, -4.0, 5.0), transformed.dir)

    camera = OrthogonalCamera(2.0)
    ray1 = fire_ray(camera, 0.0, 0.0)
    ray2 = fire_ray(camera, 1.0, 0.0)
    ray3 = fire_ray(camera, 0.0, 1.0)
    ray4 = fire_ray(camera, 1.0, 1.0)

    @test isapprox( 0.0, squared_norm(cross(ray1.dir,ray2.dir)) )
    @test isapprox( 0.0, squared_norm(cross(ray1.dir,ray3.dir)) )
    @test isapprox( 0.0, squared_norm(cross(ray1.dir,ray4.dir)) )

    @test isapprox( at(ray1,1.0), Point(0.0, 2.0, -1.0) )
    @test isapprox( at(ray2,1.0), Point(0.0, -2.0, -1.0) )
    @test isapprox( at(ray3,1.0), Point(0.0, 2.0, 1.0) )
    @test isapprox( at(ray4,1.0), Point(0.0, -2.0, 1.0 ))

    cam = OrthogonalCamera( translation(Vec(0.0,-1.0,0.0)*2.0)*rotation_z(pi/2.0) )
    ray = fire_ray(cam, 0.5, 0.5)

    @test isapprox( at(ray, 1.0), Point(0.0, -2.0, 0.0))
end

## TESTING ImageTracer METHODS ###############################################

image = HdrImage(4, 2)
camera = PerspectiveCamera(2)
tracer = ImageTracer(image, camera)

ray1 = fire_ray(tracer, 0, 0, 2.5, 1.5)
ray2 = fire_ray(tracer, 2, 1, 0.5, 0.5)

fire_all_rays(tracer, ray -> Color(1.0, 2.0, 3.0))

top_left_ray = fire_ray(tracer, 0, 0, 0.0, 0.0)

@testset "ImageTracer tests" begin
    @test isapprox(ray1, ray2)
    for row ∈ 1:image.height
        for col ∈ 1:image.width
            @test image.get_pixel(col, row) == Color(1.0, 2.0, 3.0)
        end
    end
    @test isapprox(at(top_left_ray, 1.0), Point(0.0, 2.0, 1.0))
end