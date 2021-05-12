import Pkg
Pkg.activate(normpath(@__DIR__))

import ProjectMoana: OrthogonalCamera, PerspectiveCamera, HdrImage, rotation_z, translation, ImageTracer, fire_all_rays, ray_intersection, normalize_image,
       clamp_image, World
import Images: save
import Base: write  

using ArgParse

function parse_commandline()
    s = ArgParseSettings(description = "This program generates an image of 10 spheres. Try me!",
                               usage = "usage: [--help] [WIDTH] [HEIGHT] [DISTANCE] [CAMERA] [ANGLE_DEG] [FILE_OUT_PFM]",
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
        "DISTANCE"
            help = "distance of a Perspective Camera"
            required = false
            arg_type = Float64
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
        "FILE_OUT_PFM"
            help = "name of the output PFM file"
            required = false
            default = "out.pfm" 
            arg_type = String       
    end

    return parse_args(s)
end

function main()
    params = parse_commandline()

    w = params["WIDTH"]
    h = params["HEIGHT"]
    a = w/h
    d = params["DISTANCE"]
    camera_tr = rotation_z(params["ANGLE_DEG"]*360/2π) * translation(Vec(-1.0, 0.0, 0.0))
    image = HdrImage(w, h)
    file_out_pfm = params["FILE_OUT_PFM"]

# inizializzare World con 10 sfere
    world = World()

    add_shape(world, Spehe(translation(Vec( 0.5, 0.5, 0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec(-0.5, 0.5, 0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec( 0.5,-0.5, 0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec( 0.5, 0.5,-0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec(-0.5,-0.5, 0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec(-0.5, 0.5,-0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec(-0.5,-0.5, 0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec(-0.5,-0.5,-0.5) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec( 0.0, 0.5, 0.0) * scaling(0.1,0.1,0.1) )))
    add_shape(world, Spehe(translation(Vec( 0.0, 0.0,-0.5) * scaling(0.1,0.1,0.1) )))

# creare oggetto Orthogonal o Perspective camera a scelta dell'utente
    if params["CAMERA"] == "O"
        camera = OrthogonalCamera(a, camera_tr)
    elseif params["CAMERA"] == "P"
        camera = PerspectiveCamera(a, camera_tr, d)
    end

# creare ImageTracer
    tracer = ImageTracer(image, camera)

    function on_off()
        if ray_intersection(world, ray) == nothing
            return RGB(1., 1., 1.)
        else
            return RGB(0., 0., 0.)
        end
    end

    fire_all_rays(tracer, on_off())

# salvare PFM
    write(tracer.image, file_out_pfm)

    println("$(file_out_pfm) has been wrtitten correctly to disk.")

# convertire automaticamente in PNG con valori arbitrari di tone mapping

    normalize_image(tracer.image, 1)
    clamp_image(tracer.image)

    image = reshape(tracer.image.pixels, (tracer.image.width, tracer.image.height))
    
    save("demo.png", tracer.image')

    println("File demo.png has been automatically written to disk.")
      
end

main()