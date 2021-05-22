using ProjectMoana

sphere = Sphere(translation(Vec(2, 0, 0)) * scaling(Vec(0.2, 0.2, 0.2)), Material(DiffuseBRDF(UniformPigment(RGB(1.,1.,1.)))) )
image = HdrImage(3, 3)
camera = OrthogonalCamera()
tracer = ImageTracer(image, camera)
world = World()

add_shape(world, sphere)

fire_all_rays(tracer, OnOff_renderer, world)

@testset "Renderer: Test OnOff renderer" begin
#    @test image.pixels[get_pixel(image,1, 1)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 1)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,3, 1)]≈RGB(0.,0.,0.)

    @test image.pixels[get_pixel(image,1, 2)]≈RGB(0.,0.,0.)
#    @test image.pixels[get_pixel(image,2, 2)]≈RGB(1.,1.,1.)
    @test image.pixels[get_pixel(image,3, 2)]≈RGB(0.,0.,0.)

    @test image.pixels[get_pixel(image,1, 3)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 3)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,3, 3)]≈RGB(0.,0.,0.)
end

sphere_color = RGB(1.0, 2.0, 3.0)
sphere = Sphere(translation(Vec(2, 0, 0)) * scaling(Vec(0.2, 0.2, 0.2)), Material(DiffuseBRDF(UniformPigment(sphere_color))))
image = HdrImage(3, 3)
camera = OrthogonalCamera()
tracer = ImageTracer(image, camera)
world = World()
add_shape(world, sphere)
fire_all_rays(tracer, Flat_renderer, world)

@testset "Renderer: Test Flat renderer " begin
    @test image.pixels[get_pixel(image,1, 1)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 1)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,3, 1)]≈RGB(0.,0.,0.)

    @test image.pixels[get_pixel(image,1, 2)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 2)]≈sphere_color
    @test image.pixels[get_pixel(image,3, 2)]≈RGB(0.,0.,0.)

    @test image.pixels[get_pixel(image,1, 3)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 3)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,3, 3)]≈RGB(0.,0.,0.)
end