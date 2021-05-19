import Pkg
Pkg.activate(normpath(@__DIR__))

using ProjectMoana
import Images: save
import Base: write  
import ColorTypes: RGB

using ArgParse

function parse_commandline()
    s = ArgParseSettings(description = "This program generates an image of 10 spheres. Try me!",
                               usage = "usage: [--help] [WIDTH] [HEIGHT] [CAMERA] [ANGLE_DEG] [DISTANCE] [FILE_OUT_PFM] [RENDER_ALGORITHM] [A_FACTOR]",
                              epilog = "Let's try again!")

    @add_arg_table s begin
        "WIDTH"
            help = "width of the image"
            required = true
            arg_type = Int
        "HEIGHT"
            help = "height of the image"
            required = true 
            arg_type = Int       
        "CAMERA"
            help = "type of the camera (O, for Orthogonal, or P, for Perspective)"
            required = false
            default = "O"
            arg_type = String
        "ANGLE_DEG"
            help = "angle of the z-axis rotation applied to camera (in degrees)"
            required = false
            default = 0.
            arg_type = Float64
        "DISTANCE"
            help = "distance of a Perspective Camera"
            required = false
            default = 1.
            arg_type = Float64
        "FILE_OUT"
            help = "name of the output file (without extension)"
            required = false
            default = "demo" 
            arg_type = String  
        "RENDER_ALGORITHM"
            help = "type of algortihm to use for render"
            required = false
            default = "on_off" 
            arg_type = String  
        "A_FACTOR"
            help = "a_factor for nomralize image luminosity during the convertion"
            required = false
            default = 1.
            arg_type = Float64
    end

    return parse_args(s)
end

function main()
    params = parse_commandline()

    w = params["WIDTH"]
    h = params["HEIGHT"]
    a = w/h
    d = params["DISTANCE"]
    camera_tr = rotation_z(params["ANGLE_DEG"]*π/180.0) * translation(Vec(-1.0,0.,0.))
    image = HdrImage(w, h)
    file_out_pfm = "images/$(params["FILE_OUT"]).pfm"
    file_out_png = "images/$(params["FILE_OUT"]).png"
    algorithm = params["RENDER_ALGORITHM"]

# Creating WORLD with 10 spheres
    world = World()

    for x in [-0.5, 0.5]
        for y in [-0.5, 0.5]
            for z in [-0.5, 0.5]
                add_shape(world, Sphere(translation(Vec(x, y, z)) * scaling(Vec(0.1, 0.1, 0.1)) ))
            end
        end
    end

    add_shape(world, Sphere(translation(Vec( 0.0, 0.5, 0.0)) * scaling(Vec(0.1,0.1,0.1)) ))
    add_shape(world, Sphere(translation(Vec( 0.0, 0.0,-0.5)) * scaling(Vec(0.1,0.1,0.1)) ))
#    add_shape(world, Plane(rotation_x(π/2.0) * rotation_y(π/3.0) * rotation_z(π/1.2) * translation(Vec( 100.0, 75.0, 50.0)) ))

    println("World objects created.")


# Creating a Perspective of Orthogonal CAMERA
    if params["CAMERA"] == "O"
        camera = OrthogonalCamera(a, camera_tr)
    elseif params["CAMERA"] == "P"
        camera = PerspectiveCamera(a, camera_tr, d)
    end


# Creating an ImageTracer object 
    tracer = ImageTracer(image, camera)

    println("Observer initialized.")

    print("Computing ray intersection ")
    if params["RENDER_ALGORITHM"] == "flat"
        println("using Flat renderer")
        renderer = FlatRenderer(world, background_color=RGB(0.,0.,0.))
    else
        println("using On/off renderer")
        renderer = OnOffRenderer(world, background_color=RGB(0.,0.,0.))
    end

    fire_all_rays(tracer, renderer)

    println("Ray intersections evaluated.")


# Saving the PFM FILE 
    write(file_out_pfm, tracer.image)

    println("$(file_out_pfm) has been written to disk.")


# Automatic CONVERSION TO JPEG FILE 
    normalize_image(tracer.image, params["A_FACTOR"])
    clamp_image(tracer.image)

    matrix_pixels = reshape(tracer.image.pixels, (tracer.image.width, tracer.image.height))
    
    save(file_out_png, matrix_pixels')

    println("$(file_out_png) has been automatically written to disk.")
      
end

main()  

############