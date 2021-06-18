import Pkg
Pkg.activate(normpath(@__DIR__))

using ProjectMoana
import Images: save
import Base: write  
import ColorTypes: RGB

using ArgParse

function parse_commandline()
    s = ArgParseSettings(description = "This program generates an image of 10 spheres. Try me!",
                               usage = "usage: [--help] [--w WIDTH] [--h HEIGHT] [--camera C] [--angle α] [--distance D] 
                                        [--file_out FILENAME] [--render_alg ALG] [--a A] [--seq S] [--nrays NUM_OF_RAYS]" ,
                              epilog = "Let's try again!")

    @add_arg_table s begin
        "--w"
            help = "width of the image"
            required = false
            default = 640
            arg_type = Int
        "--h"
            help = "height of the image"
            required = false
            default = 480 
            arg_type = Int       
        "--camera"
            help = "type of camera [O, for Orthogonal, or P, for Perspective]"
            required = false
            default = "P"
            arg_type = String
        "--angle"
            help = "angle of the z-axis rotation applied to camera (in degrees)"
            required = false
            default = 0.f0
            arg_type = Float32
        "--dist"
            help = "distance of a Perspective Camera"
            required = false
            default = 1.f0
            arg_type = Float32
        "--file_out"
            help = "name of the output file (without extension)"
            required = false
            default = "demo_out" 
            arg_type = String  
        "--render_alg"
            help = "type of rendering algortihm [O for On-Off, F for Flat, P for Path Tracer]"
            required = false
            default = "P" 
            arg_type = String  
        "--a"
            help = "a_factor for normalizing image luminosity during the convertion"
            required = false
            default = 1.f0
            arg_type = Float32
        "--seq"
            help = "sequence number for PCG generator"
            required = false
            default = 54
            arg_type = Int
        "--nrays"
            help = "Number of rays for antialasing"
            required = false
            default = 3
            arg_type = Int
    end

    return parse_args(s)
end

function main()
    params = parse_commandline()

    w = params["w"]
    h = params["h"]
    a = w/h
    d = params["dist"]
    camera_tr = rotation_z(params["angle"]*π/180.0f0) * translation(Vec(-1.0f0,0.f0,0.f0))
    image = HdrImage(w, h)
    file_out_pfm = "$(params["file_out"]).pfm"
    file_out_png = "$(params["file_out"]).png"
    algorithm = params["render_alg"]
    seq = convert(UInt64, params["seq"])


# Creating WORLD with sky, sun, checkered gorud, Mars, Jupiter and mirror
    world = World()
    WHITE = RGB(1.f0,1.f0,1.f0)
    BLACK = RGB(0.f0,0.f0,0.f0)
    
    sky_color = Material(DiffuseBRDF(UniformPigment(RGB(.1f0,.5f0,.99f0))), UniformPigment(BLACK))
    sky = Plane(translation(Vec(0.f0,0.f0,100.f0)) * rotation_y( pi/6.f0), sky_color)
    add_shape(world, sky)

    sun_color = Material(DiffuseBRDF(UniformPigment(RGB(0.6f0,0.8f0,1.f0))), UniformPigment(WHITE))
    sun = Plane(translation(Vec(-100.f0,0.f0,0.f0)) * rotation_y(pi/2.f0), sun_color )
    add_shape(world, sun)

    ground_color = Material(DiffuseBRDF(CheckeredPigment(RGB(0.7f0,0.3f0,0.1f0), RGB(0.1f0,0.7f0,0.1f0), 10.f0)))
    ground = Plane(translation(Vec(0.f0,0.f0,-2.f0)) * rotation_y(pi/12.f0) * rotation_x(pi/24.f0) * scaling(Vec(10.f0,10.f0,10.f0)), ground_color )
    add_shape(world, ground)

    # mirror_color = Material(SpecularBRDF())
    # mirror = Sphere(translation(Vec(3.f0,2.f0,-1.5f0))*scaling(Vec(1.f0,1.f0,1.f0)), mirror_color)
    # add_shape(world, mirror)

    # planet2_color = Material(DiffuseBRDF(ImagePigment(read_pfm_image("./examples/jupiter_texture.pfm"))))
    # planet2 = Sphere(translation(Vec(6.f0,-2.f0,4.f0)) * scaling(Vec(3.f0,3.f0,3.f0)), planet2_color)
    # add_shape(world, planet2)

    # planet_color = Material(DiffuseBRDF(ImagePigment(read_pfm_image("./examples/mars_texture.pfm"))))
    # planet = Sphere(translation(Vec(2.f0,-2.f0,-2.f0)) * scaling(Vec(1.f0,1.f0,1.f0)), planet_color)
    # add_shape(world, planet)

    println("World objects created.")


# Creating a Perspective of Orthogonal CAMERA
    if params["camera"] == "O"
        camera = OrthogonalCamera(a, camera_tr)
    elseif params["camera"] == "P"
        camera = PerspectiveCamera(a, camera_tr, d)
    end


# Creating an ImageTracer object 
    tracer = ImageTracer(image, camera, params["nrays"])

    println("Observer initialized.")

    print("Computing ray intersection ")
    if params["render_alg"] == "F"
        println("using Flat renderer")
        renderer = Flat_Renderer(world, RGB(0.4f0,0.4f0,0.4f0))
        fire_all_rays(tracer, Flat, renderer)
    elseif params["render_alg"] == "P"
        println("using Path Tracer renderer")
        renderer = PathTracer_Renderer(world; background_color=RGB(0.f0,0.f0,0.f0), pcg=PCG(UInt64(42), seq), num_of_rays=2, max_depth=1, russian_roulette_limit=2)
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

    # print(tracer.image.pixels])


# Automatic CONVERSION TO JPEG FILE 
    # normalize_image(tracer.image, params["a"])
    # clamp_image(tracer.image)

    # matrix_pixels = reshape(tracer.image.pixels, (tracer.image.width, tracer.image.height))
    
    # save(file_out_png, matrix_pixels')

    # println("$(file_out_png) has been automatically written to disk.")
      
end


main()  


############