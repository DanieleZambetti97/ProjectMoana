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
            default = "O"
            arg_type = String
        "--angle"
            help = "angle of the z-axis rotation applied to camera (in degrees)"
            required = false
            default = 0.
            arg_type = Float64
        "--distance"
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
            help = "type of algortihm to use for render [on_off, flat, path_tracer]"
            required = false
            default = "flat" 
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
    d = params["distance"]
    camera_tr = rotation_z(params["angle"]*π/180.0) * translation(Vec(-1.0,0.,0.))
    image = HdrImage(w, h)
    file_out_pfm = "$(params["file_out"]).pfm"
    file_out_png = "$(params["file_out"]).png"
    algorithm = params["render_alg"]

# Creating WORLD with 10 spheres
    material1 = Material(DiffuseBRDF(UniformPigment(RGB(0.7, 0.3, 0.2))))
    material2 = Material(DiffuseBRDF(CheckeredPigment(RGB(0.2, 0.7, 0.3), RGB(0.3, 0.2, 0.7), 8)))

    sphere_texture = HdrImage(2, 2)
    set_pixel(sphere_texture, 1, 1, RGB(0.1, 0.2, 0.3))
    set_pixel(sphere_texture, 1, 2, RGB(0.2, 0.1, 0.3))
    set_pixel(sphere_texture, 2, 1, RGB(0.3, 0.2, 0.1))
    set_pixel(sphere_texture, 2, 2, RGB(0.3, 0.1, 0.2))

    material3 = Material(DiffuseBRDF(ImagePigment(sphere_texture)))
    world = World()

    for x in [-0.5, 0.5]
        for y in [-0.5, 0.5]
            for z in [-0.5, 0.5]
               add_shape(world, Sphere(translation(Vec(x, y, z)) * scaling(Vec(0.1, 0.1, 0.1)), material1 ))
            end
        end
    end

   add_shape(world, Sphere(translation(Vec( 0.0, 0.5, 0.0)) * scaling(Vec(0.1, 0.1, 0.1)), material2 ))
   add_shape(world, Sphere(translation(Vec( -0.5, 0.0,-0.5)) * scaling(Vec(.1,.1,.1)), material3 ))

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
    if params["render_alg"] == "flat"
        println("using Flat renderer")
        renderer = Flat_Renderer(world, RGB(0.4,0.4,0.4))
        fire_all_rays(tracer, Flat, renderer)
    else
        println("using On/Off renderer")
        renderer = OnOff_Renderer(world)
        fire_all_rays(tracer, OnOff, renderer)
    end

    println("Ray intersections evaluated.")


# Saving the PFM FILE 
    write(file_out_pfm, tracer.image)

    println("$(file_out_pfm) has been written to disk.")


# Automatic CONVERSION TO JPEG FILE 
    # normalize_image(tracer.image, params["a"])
    # clamp_image(tracer.image)

    # matrix_pixels = reshape(tracer.image.pixels, (tracer.image.width, tracer.image.height))
    
    # save(file_out_png, matrix_pixels')

    # println("$(file_out_png) has been automatically written to disk.")
      
end

main()  

############