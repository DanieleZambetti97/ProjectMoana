using ProjectMoana
using ColorTypes

world = World()
add_shape(world, Sphere(translation(Vec(2., 0., 0.)) * scaling(Vec(0.1, 0.1, 0.1))))

image = HdrImage(3, 3)
camera = PerspectiveCamera()
tracer = ImageTracer(image, camera)
renerer = OnOff_Renderer(world)

fire_all_rays(tracer, OnOff, renerer)

@testset "Renderer: Test OnOff renderer                  " begin
    for i ∈ 1:3
        for j ∈ 1:3
            image.pixels[get_pixel(image, i, j)] == RGB(1.,1.,1.)
        end
    end

    @test image.pixels[get_pixel(image,1, 1)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 1)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,3, 1)]≈RGB(0.,0.,0.)

    @test image.pixels[get_pixel(image,1, 2)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 2)]≈RGB(1.,1.,1.)
    @test image.pixels[get_pixel(image,3, 2)]≈RGB(0.,0.,0.)

    @test image.pixels[get_pixel(image,1, 3)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,2, 3)]≈RGB(0.,0.,0.)
    @test image.pixels[get_pixel(image,3, 3)]≈RGB(0.,0.,0.)
end

world = World()
sphere_color = RGB(1.0, 2.0, 3.0)
sphere =Sphere(translation(Vec(2, 0, 0)) * scaling(Vec(0.2, 0.2, 0.2)), Material(DiffuseBRDF(UniformPigment(sphere_color))))
add_shape(world, sphere)

image = HdrImage(3, 3)
camera = OrthogonalCamera()
tracer = ImageTracer(image, camera)
renderer = Flat_Renderer(world)

fire_all_rays(tracer, Flat, renderer)

@testset "Renderer: Test Flat renderer                   " begin
    @test image.pixels[get_pixel(image,1, 1)]≈RGB(0.0,0.0,0.0)
    @test image.pixels[get_pixel(image,2, 1)]≈RGB(0.0,0.0,0.0)
    @test image.pixels[get_pixel(image,3, 1)]≈RGB(0.0,0.0,0.0)

    @test image.pixels[get_pixel(image,1, 2)]≈RGB(0.0,0.0,0.0)
    @test image.pixels[get_pixel(image,2, 2)]≈sphere_color
    @test image.pixels[get_pixel(image,3, 2)]≈RGB(0.0,0.0,0.0)

    @test image.pixels[get_pixel(image,1, 3)]≈RGB(0.0,0.0,0.0)
    @test image.pixels[get_pixel(image,2, 3)]≈RGB(0.0,0.0,0.0)
    @test image.pixels[get_pixel(image,3, 3)]≈RGB(0.0,0.0,0.0)
end



@testset "Renderer: Furnace test for Path Tracer renderer" begin
    pcg = PCG()

    for i in range(1, length=5):
        world = World()

        emitted_radiance = pcg_randf(pcg)
        reflectance = pcg_randf(pcg)
        enclosure_material = Material( DiffuseBRDF(UniformPigment(Color(1.0, 1.0, 1.0) * reflectance)), UniformPigment(Color(1.0, 1.0, 1.0) * emitted_radiance))

        world.add(Sphere(Transformation(), enclosure_material))

        path_tracer = PathTracer_Renderer(world, pcg=pcg, num_of_rays=1, max_depth=100, russian_roulette_limit=101)

        ray = Ray(Point(0, 0, 0), Vec(1, 0, 0))
        color = path_tracer(ray)

        expected = emitted_radiance / (1.0 - reflectance)
        @test approx(expected, color.r, atol=1e-3)
        @test approx(expected, color.g, atol=1e-3)
        @test approx(expected, color.b, atol=1e-3)
    end
    
end