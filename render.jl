import Pkg
Pkg.activate(normpath(@__DIR__))

using ProjectMoana
using ArgParse
import Images: save
import Base: write  
import ColorTypes: RGB


function parse_commandline()
    s = ArgParseSettings(
        description = "This program generates an image reading a scene from a input file. Try me!",
        usage = "usage: [--help] [--scene SCENE_FILE] [--anim_var ANIMATION_VAR] [--w WIDTH] [--h HEIGHT]
       [--file_out FILENAME] [--render_alg ALG] [--seq S] [--nrays NUM_OF_RAYS]",
        epilog = "Let's try again!"
        )

    @add_arg_table s begin
        "--scene"
            help = "Name of the input scene file where you can define the Shapes whit their materials and positions options and the observer's Camera whit its options"
            required = false
            default = "scene1.txt"
            arg_type = String
        "--anim_var"
            help = "Declare a variable usefull for animation. The syntax is «--declare-float=VAR:VALUE». Example: --declare-float=clock:150"
            required = false
            default = "€"
            arg_type = String
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
        "--file_out"
            help = "name of the output file (without extension)"
            required = false
            default = "demo_out" 
            arg_type = String  
        "--render_alg"
            help = "type of rendering algortihm \n [O for On-Off,\nF for Flat,\nP for Path Tracer]"
            required = false
            default = "P" 
            arg_type = String  
        "--seq"
            help = "sequence number for PCG generator"
            required = false
            default = 54
            arg_type = Int
        "--nrays"
            help = "Number of rays for antialasing"
            required = false
            default = 9
            arg_type = Int
    end

    return parse_args(s)
end

function build_variable_table(definitions::String)

    variables = Dict{String, Float32}()

    if definitions == "€" ######default option, return empty dictionary
        return variables
    end

    for declaration in definitions
        parts = split(declaration, ":")
        if length(parts) != 2
            println("error, the definition «$declaration» does not follow the pattern NAME:VALUE")
            exit(1)
        end

        name, value = parts
        try
            value = Float32(value)
        catch e
            println("invalid floating-point value «$value» in definition «$declaration»")

        variables[name] = value
        end
    end

    return variables
end

function main()

# Initialize command line args 
    params = parse_commandline()

    w = params["w"]
    h = params["h"]
    file_out_pfm = "$(params["file_out"]).pfm"
    file_out_png = "$(params["file_out"]).png"
    algorithm = params["render_alg"]
    seq = convert(UInt64, params["seq"])
    scene_file = params["scene"]
    samples_per_pixel = params["nrays"]
    variables = build_variable_table("$(params["anim_var"])")

    samples_per_side = sqrt(samples_per_pixel)
    if samples_per_side^2 != samples_per_pixel
        println("Error, the number of rays per pixel ($samples_per_pixel) must be a perfect square")
        return
    end

# Parsing scene file
    input_file = open(scene_file, "r")
    scene = parse_scene(InputStream(input_file,SourceLocation(scene_file)), variables)
    println("Observer's Camera and World objects created.")

# Creating an ImageTracer object 
    image = HdrImage(w, h)
    println("Generating a $w×$h image")
    tracer = ImageTracer(image, scene.camera, samples_per_pixel)

# Computing ray intersection
    print("Computing ray intersection ")
    if params["render_alg"] == "F"
        println("using Flat algorithm")
        renderer = Flat_Renderer(scene.world, RGB(0.4f0,0.4f0,0.4f0))
        fire_all_rays(tracer, Flat, renderer)
    elseif params["render_alg"] == "P"
        println("using Path Tracer algorithm")
        renderer = PathTracer_Renderer(scene.world; background_color=RGB(0.f0,0.f0,0.f0), pcg=PCG(UInt64(42), seq),
                                       num_of_rays=2, max_depth=3, russian_roulette_limit=2)
        fire_all_rays(tracer, PathTracer, renderer)
    else
        println("using On/Off algorithm")
        renderer = OnOff_Renderer(scene.world)
        fire_all_rays(tracer, OnOff, renderer)
    end
    println("\nRay intersections evaluated.")


# Saving the PFM FILE 
    write(file_out_pfm, tracer.image)
    println("$(file_out_pfm) has been written to disk.")
      
end


main()