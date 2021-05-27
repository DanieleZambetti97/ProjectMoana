import Pkg
Pkg.activate(normpath(@__DIR__))

using ProjectMoana
import Images: save
import Base: write  
import ColorTypes: RGB

using ArgParse

function parse_commandline()
    s = ArgParseSettings(description = "This program generates an image of 10 spheres. Try me!",
                               usage = "usage: [--help] [--width W] [--height H] [--camera C] [--angle α] [--distance D] [--file_out FILENAME] [--render_alg ALG] [--a A]",
                              epilog = "Let's try again!")

    @add_arg_table s begin
        "--width"
            help = "width of the image"
            required = true
            arg_type = Int
        "--height"
            help = "height of the image"
            required = true 
            arg_type = Int       
        "--camera"
            help = "type of the camera [O, for Orthogonal, or P, for Perspective]"
            required = false
            default = "P"
            arg_type = String
        "--angle"
            help = "angle of the z-axis rotation applied to camera (in degrees)"
            required = false
            default = 0.
            arg_type = Float64
        "--dist"
            help = "distance of a Perspective Camera"
            required = false
            default = 1.
            arg_type = Float64
        "--file_out"
            help = "name of the output file (without extension)"
            required = false
            default = "demo" 
            arg_type = String  
        "--render_alg"
            help = "type of algortihm to use for render [O for On-Off, F for Flat, P for Path Tracer]"
            required = false
            default = "P" 
            arg_type = String  
        "--a"
            help = "a_factor for nomralize image luminosity during the convertion"
            required = false
            default = 1.
            arg_type = Float64
    end

    return parse_args(s)
end

function main()
    params = parse_commandline()

    w = params["width"]
    h = params["height"]
    a = w/h
    d = params["dist"]
    camera_tr = rotation_z(params["angle"]*π/180.0) * translation(Vec(-1.0,0.,0.))
    image = HdrImage(w, h)
    file_out_pfm = "$(params["file_out"]).pfm"
    file_out_png = "$(params["file_out"]).png"
    algorithm = params["render_alg"]

# Creating WORLD with 10 spheres
    world = World()
    sky_color = Material(DiffuseBRDF(UniformPigment(RGB(0.4, 0.8, 1.))), UniformPigment(RGB(0.,0.,0.)))
    sky = Sphere(scaling(Vec(1000.,1000.,1000.)), sky_color )
    add_shape(world, sky)

    sun_color = Material(DiffuseBRDF(UniformPigment(RGB(1.,1.,1.))), UniformPigment(RGB(1.,1.,1.)))
    sun = Sphere(translation(Vec(-300,-450,350))*scaling(Vec(100.,100.,100.)), sun_color )
    add_shape(world, sun)

    material1 = Material(DiffuseBRDF(UniformPigment(RGB(0.1, 0.0, 0.0))))
    ball = Sphere(translation(Vec(3,-1.5,0.))*scaling(Vec(1.,1.,1.)), material1 )
    add_shape(world, ball)

#    ground_color = Material(DiffuseBRDF(CheckeredPigment(RGB(0.,0.7,0.2), RGB(0., 0.2,0.8), 10)))
    ground_color = Material(DiffuseBRDF(UniformPigment(RGB(0.,0.7,0.2))))
    ground = Plane(translation(Vec(1.1,0.,-1.5)), ground_color )
#    add_shape(world, ground)

    mirror_color = Material(SpecularBRDF())
    mirror = Sphere(translation(Vec(3,1.5,0))*scaling(Vec(1.,1.,1.)), mirror_color)
    add_shape(world, mirror)

    println("World objects created.")


# Creating a Perspective of Orthogonal CAMERA
    if params["camera"] == "O"
        camera = OrthogonalCamera(a, camera_tr)
    elseif params["camera"] == "P"
        camera = PerspectiveCamera(a, camera_tr, d)
    end


# Creating an ImageTracer object 
    tracer = ImageTracer(image, camera)

    println("Observer initialized.")

    print("Computing ray intersection ")
    if params["render_alg"] == "F"
        println("using Flat renderer")
        renderer = Flat_Renderer(world, RGB(0.4,0.4,0.4))
        fire_all_rays(tracer, Flat, renderer)
    elseif params["render_alg"] == "P"
        println("using Path Tracer renderer")
        renderer = PathTracer_Renderer(world; background_color=RGB(0.,0.,0.), pcg=PCG(), num_of_rays=2, max_depth=10, russian_roulette_limit=4)
        fire_all_rays(tracer, PathTracer, renderer)
    else
        println("using On/Off renderer")
        renderer = OnOff_Renderer(world)
        fire_all_rays(tracer, OnOff, renderer)
    end

    println("\nRay intersections evaluated.")


# Saving the PFM FILE 
    write(file_out_pfm, tracer.image)

    println("$(file_out_pfm) has been written to disk.")


# Automatic CONVERSION TO JPEG FILE 
    normalize_image(tracer.image, params["a"])
    clamp_image(tracer.image)

    matrix_pixels = reshape(tracer.image.pixels, (tracer.image.width, tracer.image.height))
    
    save(file_out_png, matrix_pixels')

    println("$(file_out_png) has been automatically written to disk.")
      
end

main()  

############